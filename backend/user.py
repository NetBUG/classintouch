#coding=utf-8
from flask import Blueprint, url_for, render_template, render_template_string, redirect, request, current_app, send_from_directory, make_response
from flask_cors import cross_origin

blueprint = Blueprint('user', __name__)


# TODO: move this auth-API to class
def get_new_token(code):
    return requests.post(
        "http://api.skuuper.com/oauth/token",
        data={
            "client_id": conf["APP_ID"],
            "client_secret": conf["APP_SERCRET"],
            "redirect_uri": "http://gw.skuuper.com/finish_login",
            "grant_type": "authorization_code",
            "code": code
        })


def refresh_token(rf_token=None):
    if not rf_token:
        rf_token = request.cookies.get("refresh_token", None)
    if rf_token:
        return requests.post(
            "http://api.skuuper.com/oauth/token",
            data={
                "client_id": conf["APP_ID"],
                "client_secret": conf["APP_SERCRET"],
                "redirect_uri": "http://gw.skuuper.com/finish_login",
                "grant_type": "refresh_token",
                "refresh_token": rf_token
            })
    else:
        return None


def about_me(ac_token=None):
    if ac_token:
        access_token = ac_token
    else:
        access_token = request.cookies.get("access_token", None)
    if access_token:
        headers = {
            "Authorization": "Bearer {0}".format(access_token)
        }
        return requests.get("http://api.skuuper.com/users/me", headers=headers).json()
    else:
        return {}


def get_user_state():
    """
    :returns 1: user is anonymous
             0: user is logged in
    """
    user_id = check_id(request)
    state = db.session.query(User).filter_by(id=user_id)
    if state.count() > 0:
        if state.first().oauth_id == -1:
            return 1
        else:
            return 0
    else:
        return 1


def process_login(resp, data):
    resp.set_cookie("access_token", data["access_token"])
    if "refresh_token" in data:
        resp.set_cookie("refresh_token", data["refresh_token"])

    # get data about new user
    token = request.cookies.get("token", None)
    if not token:
        token = generate_token()

    about = about_me(data["access_token"])
    print "About:\n", about, "\n---------"
    about = about["user"]

    # load current role (from out OAuth provider)
    try:
        rn = about["role_names"][0]
    except IndexError:
        rn = "user"
    try:
        r = db.session.query(Role).filter_by(name=rn).first()
    except Exception as e:
        print "Unknown role query exception:", e
        r = db.session.query(Role).filter_by(name="user").first()

    # load real user (from out OAuth provider)
    real_user = db.session.query(User).join(User.role).filter(User.email==about["email"])
    if not real_user or real_user.count() == 0:
        tz = get_timezone(request)
        # create absolutely new user with another token
        s = User(oauth_id=about["id"], token=generate_token(), username=about["email"], email=about["email"],
                 first_name=about["given_name"], last_name=about["family_name"], role_id=r.id,
                 timezone=tz, confirmed_at=datetime.now(), active=True)
        db.session.add(s)
        db.session.commit()
        real_user = db.session.query(User).join(User.role).filter(User.email==about["email"])

    real_user = real_user.first()
    resp.set_cookie("token", real_user.token)

    # check & update user role
    if real_user.role.name != rn:
        real_user.role_id = r.id

    if not real_user.is_active:
        real_user.is_active = True

    # merge data from temporary to real user
    tmp_usr = User.query.filter(User.token == token, User.email != about["email"])  # load temporary user, not real
    if tmp_usr and tmp_usr.count() == 1:
        tmp_usr = tmp_usr.first()
        if tmp_usr.max_score > real_user.max_score:
            real_user.max_score = tmp_usr.max_score

        db.session.query(GameStatsWordOrder).filter_by(user_id=tmp_usr.id).update({"user_id": real_user.id})
        db.session.query(Achievements).filter_by(user_id=tmp_usr.id).update({"user_id": real_user.id})

        # remove temporary user
        db.session.delete(tmp_usr)
        db.session.commit()
    return resp


"""
@api {post} /register.json&access_token=XYZ Register into the game
@apiName Register
@apiGroup UserAPI
@apiVersion 0.1.1

@apiParam {String} access_token Input from facebook

@apiSuccess {Integer} user_id Outputs user id for a newly registered user
@apiSuccess {String} fb_name Outputs user name for this user on facebook

"""
@blueprint.route('/register.json')
@cross_origin()
def user_register():
	pass

"""
@api {post} /info.json&fb_id=XYZ Register into the game
@apiName Profile
@apiGroup Bluemix
@apiVersion 0.1.1

@apiParam {Integer} fb_id Facebook ID of the user

@apiSuccess {String} interests List of user features (key-value)
@apiSuccess {String} fb_name Outputs user name for this user on facebook

"""
@blueprint.route('/info.json')
@cross_origin()
def user_get_info_bluemix():
	pass

"""
@api {get} /profile.json&token=XYZ&user_id=152 Get my profile
@apiName Get Profile
@apiGroup UserAPI
@apiVersion 0.1.1

@apiParam {String} [token=smth] Secret used for authentication
@apiParam {Integer} [id=1] User_id

@apiSuccess {Integer} user_id Outputs user id for a newly registered user
@apiSuccess {String} fb_name Outputs user name for this user on facebook

"""
@blueprint.route('/profile.json')
@cross_origin()
def user_profile():
	pass



@blueprint.route('/finish_login')
def finish_login():
    resp = make_response(redirect(url_for("main")))
    resp.mimetype="application/json"
    code = request.args.get("code", None)
    if code:
        resp.set_cookie("code", code)
        r = get_new_token(code)
        try:
            data = r.json()
            print "DATA=", data
            resp = process_login(resp, data)
        except Exception as e:
            print "Exc:", e, "| refreshing token..."
            r = refresh_token()
            data = r.json()
            print "DATA=", data
            resp = process_login(resp, data)
    return resp


"""
@api {post} /logout.json Log out
@apiName Logout
@apiGroup UserAPI
@apiVersion 0.1.1

@apiParam {String} access_token Input from facebook

@apiSuccess {Redirect} none Redirects to main page

"""
# change cookie and logout user from our system
@blueprint.route('/logout')
def log_out():
    resp = make_response(redirect("http://api.skuuper.com/users/sign_out?redirect_url=http://gw.skuuper.com/"))
    resp.set_cookie("token", generate_token())
    return resp


@blueprint.route('/check_user.json')
def check_user():
    return json.dumps({"anonymous": get_user_state()})


# test Rails data
@blueprint.route('/test')
def ttt():
    return json.dumps(about_me())


