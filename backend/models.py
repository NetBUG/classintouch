import ujson as json
from datetime import datetime
from uuid import uuid4

from flask.ext.sqlalchemy import SQLAlchemy
from flask_user import UserMixin


db = SQLAlchemy()


# generate a big random token for user cookies and sessions
def generate_token():
    return str(uuid4())[:50]

# Define the User data model. Make sure to add flask.ext.user UserMixin !!!
class User(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    oauth_id = db.Column(db.Integer, default=-1)
    token = db.Column(db.String(100), unique=True)  # special session and oauth cookie

    # User authentication information
    username = db.Column(db.String(50), nullable=False, unique=True)  # TODO: remove or get username from other services
    password = db.Column(db.String(255), nullable=False, server_default='')
    reset_password_token = db.Column(db.String(100), nullable=False, server_default='')

    # User email information
    email = db.Column(db.String(255), nullable=False, unique=True)
    confirmed_at = db.Column(db.DateTime())

    # User information
    active = db.Column('is_active', db.Boolean(), nullable=False, server_default='1')
    first_name = db.Column(db.String(100), nullable=False, server_default='')
    last_name = db.Column(db.String(100), nullable=False, server_default='')
    timezone = db.Column(db.String(100), nullable=True, server_default='UTC')
    max_score = db.Column(db.Integer, default=0)

    # implement this method in all helper models (not for storing user data)
    def create_from_dict(self, data):
        self.oauth_id = data["oauth_id"]
        self.token = generate_token()
        self.username = data["username"]
        self.email = data["email"]
        self.confirmed_at = datetime.utcnow()
        self.active = True
        self.first_name = data["first_name"]
        self.last_name = data["last_name"]
        super(User, self).__init__()

    def get_code(self):
        return self.oauth_id


# Define the Word Game data model.
class GameStatsWordOrder(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    user = db.relationship('User', backref=db.backref('gamestatswordorders', lazy='dynamic'))
    ts = db.Column(db.DateTime())  # Session start time
    accuracy = db.Column(db.VARCHAR)  # json with accuracy by lang
    score = db.Column(db.Float)  # TODO: change to INT ???
    time = db.Column(db.Integer)  # Session duration
    ip_addr = db.Column(db.String(16))
    country = db.Column(db.String(40))

    def __init__(self, user_id, ts, time, accuracy, score=0):
        self.ts = ts
        self.user_id = user_id
        self.time = time
        self.accuracy = accuracy
        self.score = score

    def __repr__(self):
        return '<Session %r_%r>' % (self.user_id, self.ts)


class GameSessionsWordOrder(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    user = db.relationship('User', backref=db.backref('gamesessionswordorders', lazy='dynamic'))
    ts = db.Column(db.DateTime)
    sentence_id = db.Column(db.Integer, db.ForeignKey('sentence.id'))
    session_id = db.Column(db.Integer, db.ForeignKey('game_stats_word_order.id'), nullable=True)
    proposed = db.Column(db.String(255))  # For sentences with user input and assessed via LM, we should keep it to assess later
    result = db.Column(db.Boolean)  # result = true for correct sent
    evaluation = db.Column(db.Float)  # TODO: change to INT ???

    def __init__(self, user_id, src_id, result, ev=0):
        self.ts = datetime.utcnow()
        self.user_id = user_id
        self.sentence_id = src_id
        self.session_id = None
        self.result = result
        self.evaluation = ev

    def __repr__(self):
        return '<Session %r>' % self.user_id


# Used for storage of sentences proposed while gaming, including counting additional options
class GameProposals(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    sentence_id = db.Column(db.Integer, db.ForeignKey('sentence.id'))
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    proposed = db.Column(db.String(255))  # For sentences with user input and assessed via LM, we should keep it to assess later
    count = db.Column(db.Integer)


# Used for storage of data about certain variants popularity
class GamePrefs(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    sentence_id = db.Column(db.Integer, db.ForeignKey('sentence.id'))
    count = db.Column(db.Integer)


class AchievementType(db.Model):
    __tablename__ = 'achievementtype'
    id = db.Column(db.Integer, primary_key=True)
    url_pic = db.Column(db.String(40))
    name = db.Column(db.String(30))
    comment = db.Column(db.String(40))
    type = db.Column(db.String(15), default='medal')  # ['medal', 'character', 'commercial']

    # implement this method in all helper models (not for storing user data)
    def create_from_dict(self, data):
        self.url_pic = data["url_pic"]
        self.name = data["name"]
        self.comment = data["comment"]
        self.type = data["type"]
        super(AchievementType, self).__init__()

    def get_code(self):
        return self.name

    def to_json(self):
        return {
            "id": self.id,
            "url_pic": self.url_pic,
            "name": self.name,
            "comment": self.comment,
            "type": self.type
        }


class Achievements(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    ach_id = db.Column(db.Integer, db.ForeignKey('achievementtype.id'))
    ach = db.relationship('AchievementType', backref=db.backref('achievements', lazy='dynamic'))

    is_active = db.Column(db.Boolean, default=False)
    progress = db.Column(db.Integer, default=0)  # used for "X in row" metrics control
    ts = db.Column(db.DateTime)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    user_comm = db.Column(db.String(20), nullable=True)  # May be used for user comment
    reason = db.Column(db.String(15), default='won')  # ['won', 'purchased', 'specials']
    value = db.Column(db.Integer, default=0)  # May be used for multipliers
    comm = db.Column(db.String(20), nullable=True)  # May be used for additional data - languages etc


class Language(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    code = db.Column(db.String(2))
    title = db.Column(db.String(15))
    localtitle = db.Column(db.String(15))

    def __repr__(self):
        return self.title

    # implement this method in all helper models (not for storing user data)
    def create_from_dict(self, data):
        self.code = data["code"]
        self.title = data["name"]
        self.localtitle = data["localname"]
        super(Language, self).__init__()

    def get_code(self):
        return self.code


class Topic(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    code = db.Column(db.String(2), nullable=True)
    name = db.Column(db.String(15))
    localname = db.Column(db.VARCHAR())

    def __repr__(self):
        return self.title

    # implement this method in all helper models (not for storing user data)
    def create_from_dict(self, data):
        self.code = data["code"]
        self.name = data["name"]
        self.localname = json.dumps(data["localname"])
        super(Topic, self).__init__()

    def get_code(self):
        return self.code


class Level(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    number = db.Column(db.String(2))
    title = db.Column(db.String(25))
    inttitle = db.Column(db.String(25))

    def __repr__(self):
        return self.title

    def get_name(self):
        if self.inttitle:
            return self.inttitle
        return self.title

    # implement this method in all helper models (not for storing user data)
    def create_from_dict(self, data):
        self.number = data["code"]
        self.title = data["name"]
        self.inttitle = data["localname"]
        super(Level, self).__init__()

    def get_code(self):
        return self.number


class Sentence(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    lang_id = db.Column(db.Integer, db.ForeignKey('language.code'))
    translation_of = db.Column(db.Integer, db.ForeignKey('sentence.id'))
    level = db.Column(db.String(), db.ForeignKey('level.number'))
    topic = db.Column(db.Integer, db.ForeignKey('topic.code'))
    correct = db.Column(db.String(255))
    disabled = db.Column(db.Boolean, default=False)

    def __init__(self, sent, lang, lvl=1, t_of=False, topic=""):
        self.correct = sent
        self.lang_id = lang
        self.level = lvl
        self.topic = topic
        if t_of:
            self.translation_of = t_of

    def __repr__(self):
        return self.correct

    def find_refs(self):
        out = [self.id]
        # query 
        return out


class Chunk(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    sentence_id = db.Column(db.Integer, db.ForeignKey('sentence.id'))
    # lang_id derived from Sentence
    order = db.Column(db.Integer)
    text = db.Column(db.String(35))
    fixed = db.Column(db.Boolean)
    fixed_prev = db.Column(db.Boolean)

    def __init__(self, txt, sent, order, fixed_prev=False, fixed=False):
        self.text = txt
        self.sentence_id = sent
        self.order = order
        self.fixed = fixed
        self.fixed_prev = fixed_prev

    def __repr__(self):
        return self.text


# TODO: add func to create all tables
