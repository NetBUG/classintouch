#!/usr/bin/env python
# coding=utf-8
# Main ClassInTouch application backeng
# Created on 22.10.2015 by Oleg Urzhumtsev

import os.path, os
import ujson as json

from flask import Flask, make_response, url_for, redirect, render_template, request
from flask_mail import Mail
from flask_user import current_user, UserManager, SQLAlchemyAdapter
import pytz
#import yaml
#import redis
#import requests

from classes import blueprint as classes_blueprint
from discussion import blueprint as discussion_blueprint
from user import blueprint as user_blueprint
from models import *

# Use a Class-based config to avoid needing a 2nd file
# os.getenv() enables configuration through OS environment variables
class ConfigClass(object):
    # Flask settings
    SECRET_KEY = os.getenv('SECRET_KEY', 'lWxOiKqKPNwJmSldbiSkEbkNjgh2uRSNAb+SK00P3R')
    SQLALCHEMY_DATABASE_URI = "sqlite:///app.db"
    # SQLALCHEMY_ECHO = True  # print all SQL requests
    CSRF_ENABLED = True
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Flask-Mail settings
    MAIL_USERNAME = os.getenv('MAIL_USERNAME', 'reg@skuuper.com')
    MAIL_PASSWORD = os.getenv('MAIL_PASSWORD', 'SophisticatedRegistrator69')
    MAIL_DEFAULT_SENDER = os.getenv('MAIL_DEFAULT_SENDER', '"ClassInTouch" <reg@skuuper.com>')
    MAIL_SERVER = os.getenv('MAIL_SERVER', 'smtp.zone.ee')
    MAIL_PORT = int(os.getenv('MAIL_PORT', '465'))
    MAIL_USE_SSL = int(os.getenv('MAIL_USE_SSL', True))

    # Flask-User settings
    USER_APP_NAME = 'ClassInTouch'  # Used in email templates
    UPLOAD_FOLDER = '/tmp'

    # Custom variables
    DATABASE_TYPE = "sqlite3"
    SESSION_DURATION = 86400
    BONUS_TIMEOUT = 115200


def create_app():
    """ Flask application factory """
    app = Flask(__name__)
    app.config.from_object(__name__ + '.ConfigClass')
    app.config.update(
        DEBUG=True,
        FILES_ROOT='.',
    )
    app.register_blueprint(discussion_blueprint)
    app.register_blueprint(classes_blueprint)
    app.register_blueprint(user_blueprint)

    db.app = app
    db.init_app(app)
    db.create_all()

    # Setup Flask-User
    db_adapter = SQLAlchemyAdapter(db, User)  # Register the User model
    user_manager = UserManager(db_adapter, app)  # Initialize Flask-User
    db.session.commit()
    return app


app = create_app()
mail = Mail(app)

def change_tz(user, time):
    tz = pytz.timezone(current_user.timezone)
    return time.replace(tzinfo=pytz.timezone('UTC')).astimezone(tz)


@app.route('/')
def main():
    resp = make_response(render_template('index.html'))
    # track all users
    cookie = request.cookies.get("token", None)
    if not cookie:
        resp.set_cookie("token", generate_token())
    resp.set_cookie("anonymous", str(get_user_state()))
    return resp


if __name__ == '__main__':
    # Create all database tables
    # print app.url_map  # some debug
    app.run(host='0.0.0.0', port=5100, debug=True)
