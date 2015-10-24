#coding=utf-8
from flask import Blueprint, url_for, render_template, render_template_string, redirect, request, current_app, send_from_directory
from flask_cors import cross_origin

blueprint = Blueprint('classes', __name__)

"""
@api {get} /sent.json?lang=:lang&topic=:topic&level=:level&count=:count Get sentence from the game
@apiName Discussions
@apiGroup ClassInTouch
@apiVersion 0.1.1

@apiParam {Integer} class_id Input class the user selected

@apiSuccess {Discussion} discussion_ob Outputs a discussion object that is under the class. 

"""
@blueprint.route('/getdiscussion.json')
@cross_origin()
def discussion_get():
	pass

"""
@api {get} /sent.json?lang=:lang&topic=:topic&level=:level&count=:count Get sentence from the game
@apiName Discussions
@apiGroup ClassInTouch
@apiVersion 0.1.1

@apiParam {Integer} discussion_id Input class the user selected

@apiSuccess {Discussionpost} discussionpost_ob Outputs a discussion post object that contains a list of posts under the discussion. 

"""
@blueprint.route('/getdiscussionpost.json')
@cross_origin()
def discussion_getpost():
	pass

"""
@api {get} /sent.json?lang=:lang&topic=:topic&level=:level&count=:count Get sentence from the game
@apiName Discussions
@apiGroup ClassInTouch
@apiVersion 0.1.1

@apiParam {Integer} discussion_id Input class the user selected
@apiParam {Integer} post_id Input the post id of the user's post

@apiSuccess {Post} post_ob Outputs a post object. 
"""
@blueprint.route('/posting.json')
@cross_origin()
def discussion_createpost():
	pass

"""
@api {get} /sent.json?lang=:lang&topic=:topic&level=:level&count=:count Get sentence from the game
@apiName Discussions
@apiGroup ClassInTouch
@apiVersion 0.1.1

@apiParam {Integer} post_id Input the post id of the user's post

@apiSuccess {Post} post_ob Outputs a post object. 
"""
@blueprint.route('/likepost.json')
@cross_origin()
def discussion_likepost():
	pass