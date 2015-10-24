# coding=utf-8

import ujson as json
import os.path
from random import shuffle
import math
from functools import wraps

from flask import Blueprint, url_for, render_template, render_template_string, redirect, request, current_app, send_from_directory
from flask_cors import cross_origin
from flask_user import current_user
from werkzeug.utils import secure_filename
from sqlalchemy.sql.expression import func

from models import *
from profile import check_id, clean_sessions
from achievements import ACHIEVS, ACHIEVS_ID_LIST


blueprint = Blueprint('sentstorage', __name__)


sentdb_menu = " &nbsp; | &nbsp; <a href='/sentdb'>Manage game</a>"
punct = set(u'.,!?;:')

LOGIN_URL = "http://api.skuuper.com/oauth/authorize?client_id=8844cf307ec322e40d7168a1150411940ede6d4625179edffaa340992d54f322&response_type=code&redirect_uri=http://gw.skuuper.com/finish_login"

# decorator to protect some service views
def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        user_id = check_id(request)
        if user_id is None:
            return redirect(LOGIN_URL)
        usr = db.session.query(User).join(User.role).filter(User.id==user_id)
        if usr.count() == 1:
            cur_usr = usr.first()
            if cur_usr.role.name == "admin" and cur_usr.is_active:
                return f(*args, **kwargs)
            elif not cur_usr.is_active:
                return redirect(LOGIN_URL)
        return redirect(url_for('main'))
    return decorated_function


def clean_sent(sent):
    for char in (list(punct) + ['_', '[', ']']):
        sent = sent.replace(char, u' ')
    while sent.count('  '):
        sent = sent.replace('  ', u' ')
    return sent.strip()


def break_sent(sent):
    out = []
    append = out.append
    sent = unicode(sent).replace(u'\t', u' ').replace(u'\n', u'').replace(u'\r', u'')
    for pm in punct:
        sent = sent.replace(u' ' + pm, pm).replace(pm + u' ', pm).replace(pm, pm + u' ')
    sent = sent.replace(u'_', u' _')
    for word in sent.split(u' '):
        fixed = False
        fix_prev = False
        if len(word) < 1:
            continue
        if word[0] == u'_':
            word = word.replace(u'_', '')
            fix_prev = True
        elif word[0] == u'[':
            word = word.replace(u'[', '').replace(u']', '')
            fixed = True
        append({'word': word, 'fixed': fixed, 'fixed_prev': fix_prev})
    return out


def find_sent(ssent):
    src = clean_sent(ssent.strip().decode('utf-8'))
    for sent in Sentence.query:
        corr = clean_sent(sent.correct.strip())
        if corr == src:
            print (u'"' + corr + u'" vs "' + src + u'"').encode('utf-8')
            return True
    return False


def query_sentences(form):
    lang = form.get('lang')
    lvl = form.get('lvl')
    topic = form.get('topic')
    query = Sentence.query
    if lang:
        query = query.filter(Sentence.lang_id.in_(str(lang).split(',')))
    if lvl:
        query = query.filter(Sentence.level.in_(str(lvl).split(',')))
    if topic:
        query = query.filter(Sentence.topic.in_(str(topic).split(',')))
    return query


@blueprint.route('/sentdb/')
@admin_required
def sentdb():
    # parsing params for filtering -- NOT UNIQUE!
    sents = query_sentences(request.args)
    msg = ""
    if sents.count() < 1:
        msg = "No sentences matching your query have been found! <a href=\"/sentdb\">Try without filters?</a>"
    return render_template('dashboard/sentlist.html', sents=sents, datalang=request.args.get('lang', ''),
                           datalevel=request.args.get('lvl', ''), datatopic=request.args.get('topic', ''), msg=msg)


@blueprint.route('/sentdb/new')
@admin_required
def new_form():
    return render_template_string(u"""
        {% extends "base.html" %}
        {% block content %}
          <h2 style="float: left; height: 100%; display: inline-block;">&nbsp;<a href="/sentdb">←</a>&nbsp;</h2>
          <div style="display: inline-block;">
            <h2>Add sentence</h2>
            <form method="post" action="#">
           Input sentence from GDIF line: <input type="text" name="sent" placeholder="Sample_sentence in_GDIF." size=100 />
           <p>Language: <select name="lang" id="select_language"></select></p>
           <p>Level: <select name="lvl" id="select_level"></select></p>
           <p>Topic: <select name="topic" id="select_topic"></select></p>
           <input type="submit" value="Add!" />
            </form>
           </div> 
            <script src="{{ url_for('static', filename='js/editr.js') }}"></script>
        {% endblock %}
""", menu=sentdb_menu)


@blueprint.route('/sentdb/import')
@admin_required
def import_form():
    return render_template_string(u"""
        {% extends "base.html" %}
        {% block content %}
          <h2 style="float: left; height: 100%; display: inline-block;">&nbsp;<a href="/sentdb">←</a>&nbsp;</h2>
          <div style="display: inline-block;">
            <h2>Import</h2>
            <form method="post" action="#" enctype="multipart/form-data">
           <p><a href="https://docs.google.com/document/d/14vjZPYTtzFbxSYfZHdxmtffxKY3wVEpzOnj2kAoNUv0">GDIF</a> file: <input type="file" name="gdif"/></p>
           <p>Language: <select name="lang" id="select_language" multiple="true"></select> Note: select multiple for multi-language GDIF file!</p>
           <p>Level: <select name="lvl" id="select_level"></select></p>
           <p>Topic: <select name="topic" id="select_topic"></select></p>
           <input type="submit" value="Add!" />
            </form>
          </div>  
            <script src="{{ url_for('static', filename='js/editr.js') }}"></script>
        {% endblock %}
""", menu=sentdb_menu)


@blueprint.route('/sentdb/import', methods=['POST'])
@admin_required
def import_accept():
    up_file = request.files['gdif']
    lang = request.form.get('lang')
    lvl = request.form.get('lvl')
    topic = request.form.get('topic')
    duplicates = []
    if up_file:
        newpath = os.path.join(current_app.config['UPLOAD_FOLDER'], secure_filename(up_file.filename))
        up_file.save(newpath)
        with open(newpath, 'r') as r:
            fn = secure_filename(up_file.filename)
            for [id, line] in enumerate(r):
                line = line.strip()
                if len(line) < 2 or line[0] == '#':
                    continue
                duplicates.append(
                    {'text': line.strip().decode('utf-8'), 'id': fn + "_" + str(id), 'dupe': find_sent(line)})
    return render_template_string(u"""
        {% extends "base.html" %}
        {% block content %}
          <h2 style="float: left; height: 100%; display: inline-block;">&nbsp;<a href="/sentdb">←</a>&nbsp;</h2>
          <div style="display: inline-block;">
            <h2> Import complete!</h2>
            <div id="params" style="display:none;" data-lang="{{ lang }}" data-lvl="{{ lvl }}" data-topic="{{ topic }}"></div>
            {% if duplicates %}
            <form method="post" action="#">
            <div style="margin-bottom: 6Pt;"><span class="fix200">Select all</span> <input type="checkbox" onclick="$(document).find(':checkbox').prop('checked', $(this).prop('checked'));" /></div>
            {% for duplicate in duplicates %}
            <div class="sent"><span class="fix200">{% if duplicate['dupe'] %} Duplicate: {% endif %}</span> <input type="checkbox" {% if not duplicate['dupe'] %}checked{% endif %} /> <span class="sent_text" id="">{{ duplicate['text'] }} </span></div>
            {% endfor %}
            <input type="button" value="Add!" onclick="addsents()" />
            </form>
            {% endif %}
            <script src="{{ url_for('static', filename='js/editr.js') }}"></script>
          </div>
        {% endblock %}
""", menu=sentdb_menu, duplicates=duplicates, lang=lang, lvl=lvl, topic=topic)


@blueprint.route('/sentdb/del')
@admin_required
def delete():
    sent_id = request.args.get('id', '')
    Chunk.query.filter_by(sentence_id=sent_id).delete()
    Sentence.query.filter_by(id=sent_id).delete()
    db.session.commit()
    return redirect('/sentdb')


@blueprint.route('/sentdb/new', methods=['POST'])
@admin_required
def new_accept():
    sent = request.form.get('sent').encode('utf-8').strip()
    srcid = request.form.get('src_id')
    lang = request.form.get('lang')
    lvl = request.form.get('lvl')
    topic = request.form.get('topic')
    if sent == None:
        return "Sentence cannot be empty!"
    words = break_sent(str(sent).decode('utf-8'))
    s = Sentence(sent.decode('utf-8'), lang, lvl, srcid, topic)
    db.session.add(s)
    db.session.flush()
    db.session.refresh(s)
    for [num, word] in enumerate(words):
        wc = Chunk(word['word'], s.id, num, word['fixed_prev'], word['fixed'])
        db.session.add(wc)
    db.session.commit()
    return "Making new sentence: " + str(words) + "!"


@blueprint.route('/sentdb/<sent>')
@admin_required
def sent_view(sent):
    stats = Sentence.query.filter_by(id=sent)[0]
    synth = ''
    chks = Chunk.query.filter_by(sentence_id=stats.id)
    for chunk in chks:
        synth += chunk.text + " "
    return render_template('dashboard/sentedit.html', menu=sentdb_menu, sent=stats, chunks=chks)


@blueprint.route('/sentdb/<sent>', methods=['POST'])
@admin_required
def sent_save(sent):
    lang = request.form.get('lang')
    level = request.form.get('level')
    topic = request.form.get('topic')
    chk = None  # so what? it requires checkup after try-catch-block
    try:
        chk = Sentence.query.filter_by(id=sent)[0]
    except:
        return json.dumps({u'status': u'error', u'code': '-1', u'message': u'Sentence not found'})
    chk.lang_id = lang if not lang == '-' else chk.lang_id
    chk.level = level if not level == '-' else chk.level
    chk.topic = topic if not topic == '-' else chk.topic
    db.session.add(chk)
    db.session.commit()
    return json.dumps({u'status': u'ok', u'lang': str(chk.lang_id), u'lvl': str(chk.level), u'topic': str(chk.topic)})


@blueprint.route('/chunks/<chunk>', methods=['POST'])
@admin_required
def chunk_save(chunk):
    fix = request.form.get('fixed')
    prefix = request.form.get('prefixed')
    chk = None
    try:
        chk = Chunk.query.filter_by(id=chunk)[0]
    except:
        return json.dumps({u'status': u'error', u'code': '-1', u'message': u'Chunk not found'})
    chk.fixed = True if fix == 'True' else False
    chk.fixed_prev = True if prefix == 'True' else False
    db.session.add(chk)
    db.session.commit()
    return json.dumps({u'status': u'ok', u'fix': str(chk.fixed), u'prefix': str(chk.fixed_prev), })


@blueprint.route('/game')
@admin_required
def test_game():
    return render_template('dashboard/game.html')


@blueprint.route('/stats')
@admin_required
def show_stats():
    return render_template('dashboard/stats.html')


@blueprint.route('/members')
@admin_required
def members_page():
    if not current_user.is_authenticated():
        return render_template_string("""
            {% extends "dashboard/base.html" %}
            {% block content %}
                <h2>Members page</h2>
                <p>This page can only be accessed by authenticated users.</p><br/>
                <p><a href={{ url_for('main') }}>Home page</a> (anyone)</p>
                <p><a href={{ url_for('members_page') }}>Members page</a> (login required)</p>
            {% endblock %}
""")
    else:
        return render_template_string("""
            {% extends "dashboard/base.html" %}
            {% block content %}
                <h2>Members page</h2>
                <p>Some member content...</p>
            {% endblock %}
""")


# ==== docs show-hack begin ====

@blueprint.route("/docs")
@admin_required
def show_docs():
    return send_from_directory("doc", "index.html")


@blueprint.route("/vendor/<path:filename>")
@admin_required
def send_vendor(filename):
    return send_from_directory("doc/vendor/", filename)


@blueprint.route("/css/<path:filename>")
@admin_required
def send_css(filename):
    return send_from_directory("doc/css/", filename)


@blueprint.route("/<path:filename>")
@admin_required
def send_etc(filename):
    return send_from_directory("doc/", filename)

# ==== docs show-hack end  ====


"""
@api {get} /languages.json Get language list for the game and sentdb
@apiName GetLanguages
@apiGroup ClassInTouch
@apiVersion 0.1.1

"""
@blueprint.route('/languages.json')
@cross_origin()
def get_languages():
    out = []
    append = out.append
    data = Language.query.all()
    for item in data:
        append({
            "code": item.code,
            "name": item.title,
            "localname": item.localtitle
        })
    return json.dumps(out)


# TODO: must be in turn updated in CAT backend ia corpora list
"""
@api {get} /topics.json Get topic list for the game and sentdb
@apiName GetTopics
@apiGroup ClassInTouch
@apiVersion 0.1.1

"""
@blueprint.route('/topics.json')
@cross_origin()
def get_topics():
    out = []
    append = out.append
    data = Topic.query.all()
    for item in data:
        append({
            "code": item.code,
            "name": item.name,
            "localname": item.localname
        })
    return json.dumps(out)


"""
@api {get} /levels.json Get levels for the game and sentdb
@apiName GetLevels
@apiGroup ClassInTouch
@apiVersion 0.1.1

"""
@blueprint.route('/levels.json')
@cross_origin()
def get_levels():
    out = []
    append = out.append
    data = Level.query.all()
    for item in data:
        append({
            "code": item.number,
            "name": item.title,
            "localname": item.inttitle
        })
    return json.dumps(out)


"""
@api {get} /sent.json?lang=:lang&topic=:topic&level=:level&count=:count Получение предложения для игры
@apiName GetSentence
@apiGroup ClassInTouch
@apiVersion 0.1.1

@apiParam {Language} [lang=en] Язык, на котором выдаются предложения. Может представлять список через запятую: en,et,ru
@apiParam {Integer} [level=1] Уровень
@apiParam {String} [topic=""] Тематика. По умолчанию пустая
@apiParam {Integer} [count=1] Количество. По умолчанию равно 1, необходимо для оффлайновой игры

"""
@blueprint.route('/sent.json')
@cross_origin()
def get_sent_new():
    out = []
    append = out.append
    try:
        count = int(request.args.get('count', 1))
    except Exception:
        count = 1
    try:
        sid = int(request.args.get('id', ''))
        sents = Sentence.query.filter_by(id=sid).limit(count)
    except Exception:
        sents = query_sentences(request.args).filter_by(disabled=False).order_by(func.random()).limit(count)
    for sent in sents:
        chunks = []
        mix = []
        for chunk in Chunk.query.filter_by(sentence_id=sent.id):
            if chunk.fixed_prev:
                chunks[len(chunks) - 1]['word'] += ' ' + chunk.text
                continue
            chunks.append({'word': chunk.text, 'fixed': str(bool(chunk.fixed))})
            if not chunk.fixed:
                mix.append(len(chunks) - 1)
        oldmix = list(mix)
        shuffle(mix)
        chunks1 = list(chunks)
        for [i, a] in enumerate(mix):
            chunks1[oldmix[i]] = chunks[a]
        append({
            "id": sent.id,
            # "sent": sent.correct,
            "lang": sent.lang_id,
            "level": sent.level,
            "complexity": len(sent.correct.split(" ")),
            "topic": sent.topic,
            "chunks": chunks1
        })
    return json.dumps(out)


"""
@api {get} /verify.json Verify sentence when user submits it, calculate score and update current game session
@apiName GetVerification
@apiGroup ClassInTouch
@apiVersion 0.1.1
@apiParam {Integer} [id=579] Sentence ID that is verified
@apiParam {String} [sent=Hello%world!] Sentence itself from user's input

"""
@blueprint.route('/verify.json')
@cross_origin()
def verify_sentence():
    user_id = check_id(request)
    sent_id = request.args.get('id', '')
    sent = request.args.get('sent', '')
    src = Sentence.query.filter_by(id=sent_id)
    if src.count() == 0:
        return json.dumps({"id": sent_id, "result": False})
    src_text = src[0].correct
    res = clean_sent(sent) == clean_sent(src_text)
    # save score if not an anonymous user
    comm = ""
    calculated_score = 0
    achievement_allerts = []
    if user_id:
        # TODO: make LM query and assess from 0 to 1
        if res:
            comm += "Saving a proposal; "
            # Don't save into sessions, save into variants!
            s = GameProposals(user_id=user_id, sentence_id=sent_id, proposed=sent, count=1)
            db.session.add(s)
            db.session.flush()
            db.session.refresh(s)

        message = clean_sessions(user_id=user_id)
        print "/verify.json session cleanup:", message
        try:
            # use "sess_query" to count score!
            sess_query = GameSessionsWordOrder.query\
                .filter_by(user_id=user_id)\
                .order_by(GameSessionsWordOrder.ts.desc()).first()
            if (datetime.utcnow() - sess_query.ts).total_seconds() < 1:
                # min timeout between sessions
                return json.dumps({"error": "That's weird, too fast submitting"})
            t = current_app.config["BONUS_TIMEOUT"] - (datetime.utcnow() - sess_query.ts).total_seconds()
            if t < 0:
                t = 0
            complexity = 0.6 + len(src_text.split(" "))/10.0
            calculated_score = int(math.floor(15 * complexity * (1 + t)))
            # score = int(request.args.get('score', ''))
            # print score, " | ", calculated_score, " | time =", t, " | ", src_text.split(" ")
            comm += "score: {0}".format(calculated_score)
        except Exception as e:  # find it
            print "/verify.json exception caught:", e  # ts = None
        # save new object to measure timedelta next time
        gs = GameSessionsWordOrder(user_id=user_id, src_id=sent_id, result=res, ev=calculated_score)
        db.session.add(gs)

        # pre-create all complex in-game achievements, e.g "X in a row"
        user_ach = db.session.query(Achievements.ach_id).filter_by(user_id=user_id).all()
        for a_id in ACHIEVS_ID_LIST:
            if (a_id, ) not in user_ach:
                new_a = Achievements(ach_id=a_id, ts=datetime.utcnow(), user_id=user_id, progress=0,
                            user_comm=ACHIEVS[a_id]["user_comm"], reason=ACHIEVS[a_id]["reason"],
                            value=ACHIEVS[a_id]["value"], comm=ACHIEVS[a_id]["comm"])
                db.session.add(new_a)

        # update progress on achievements
        append = achievement_allerts.append
        user_ach = db.session.query(Achievements)\
            .join(Achievements.ach)\
            .filter(Achievements.user_id == user_id, Achievements.is_active == False)
        # print "Found {0} unfinished achievements".format(user_ach.count())
        for achiev in user_ach.all():
            sent_par = {
                "lang": src[0].lang_id,
                "level": src[0].level,
                "topic": src[0].topic
            }
            rules = ACHIEVS[int(achiev.ach_id)]["rules"]
            if rules["type"] == "in_row":
                r = 1
                for key in sent_par.keys():
                    if rules[key] and rules[key] == sent_par[key]:
                        r *= 1
                    elif rules[key] and rules[key] != sent_par[key]:
                        r *= 0
                if r == 1 and res:
                    print "Row rules - OK for \"{0}\"".format(achiev.ach.name)
                    achiev.progress += 1
                    if achiev.progress == rules["progress"]:
                        achiev.ts = datetime.utcnow()  # completion time
                        achiev.is_active = True
                        print "Got ach:", achiev.ach.to_json()
                        append(achiev.ach.to_json())
                elif r == 0:
                    print "Row rules failed for \"{0}\"".format(achiev.ach.name)
                    achiev.progress = 0
                db.session.add(achiev)
            elif rules["type"] == "in_time":
                pass
            elif rules["type"] == "score":
                pass
        db.session.commit()
    response = {
        "id": sent_id,
        "result": res,
        "comment": comm,
        "score": calculated_score
    }
    if len(achievement_allerts) > 0:
        response.update({"achievements": achievement_allerts})
    return json.dumps(response)
