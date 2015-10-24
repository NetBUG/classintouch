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

class Classes(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    uni = db.Column(db.Integer, db.ForeignKey('university.id'), nullable=True)
    lat = db.Column(db.Float)
    lon = db.Column(db.Float)
    time = db.Column(db.Integer)        # from day beginning, UTC, seconds 
    name = db.Column(db.String(35))
    day = db.Column(db.Integer)         # 0 for Sunday etc

    def __init__(self, name, lat, lon, time, day):
        self.name = name
        self.lat = lat
        self.lon = lon
        self.time = time
        self.day = day

    def __repr__(self):
        return self.name

class Post(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    class_id = db.Column(db.Integer, db.ForeignKey('classes.id'))
    parent = db.Column(db.Integer, db.ForeignKey('post.id'), nullable=True)
    title = db.Column(db.String(60))        # from day beginning, UTC, seconds 
    text = db.Column(db.String(500))
    ts = db.Column(db.DateTime)         # 0 for Sunday etc

    def __init__(self, classid, title, text):
        self.classid = classid
        self.title = title
        self.text = text
        self.ts = datetime.utcnow()

    def __repr__(self):
        return self.name

class University(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(60))        # from day beginning, UTC, seconds 

    def __init__(self, title, lat, lon):
        self.title = title
        self.lat = lat
        self.lon = lon

    def __repr__(self):
        return self.name
class Like(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    post_id = db.Column(db.Integer, db.ForeignKey('post.id'))
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))

class UserClasses(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    post_id = db.Column(db.Integer, db.ForeignKey('post.id'))
    class_id = db.Column(db.Integer, db.ForeignKey('classes.id'))


# TODO: add func to create all tables
