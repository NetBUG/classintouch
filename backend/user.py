#coding=utf-8
from flask import Blueprint, url_for, render_template, render_template_string, redirect, request, current_app, send_from_directory

"""
@api {get} /sent.json?lang=:lang&topic=:topic&level=:level&count=:count Get sentence from the game
@apiName GetSentence
@apiGroup GameBackend
@apiVersion 0.1.1

@apiParam {Language} [lang=en] Language in list: en,et,ru
@apiParam {Integer} [level=1] Level
@apiParam {String} [topic=""] Topic: empty by defautl
@apiParam {Integer} [count=1] Count : used for offline

@apiSuccess {Integer} user_id Outputs user id for a newly registered user
@apiSuccess {String} fb_name Outputs user name for this user on facebook

"""
@blueprint.route('/register.json')
@cross_origin()
def user_register():
	pass

"""
@api {get} /sent.json?lang=:lang&topic=:topic&level=:level&count=:count Get sentence from the game
@apiName GetSentence
@apiGroup GameBackend
@apiVersion 0.1.1

@apiParam {String} [secret=smth] Secret used for authentication
@apiParam {Integer} [id=1] User_id

@apiSuccess {Integer} user_id Outputs user id for a newly registered user
@apiSuccess {String} fb_name Outputs user name for this user on facebook

"""
@blueprint.route('/profile.json')
@cross_origin()
def user_profile():
	pass




