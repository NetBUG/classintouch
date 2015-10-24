#coding=utf-8
from flask import Blueprint, url_for, render_template, render_template_string, redirect, request, current_app, send_from_directory
from flask_cors import cross_origin

blueprint = Blueprint('discussion', __name__)

"""
@api {get} /getdiscussion.json&class_id=152 Get discussion from a class
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
@api {get} /getdiscussionpost&discussion_id=151 Get a list of posts from the discussion.
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
@api {post} /posting.json&post_id=1212&Title=question&text=text Create a new post
@apiName Discussions
@apiGroup ClassInTouch
@apiVersion 0.1.1

@apiParam {Integer} post_id Input the post id of the user's post
@apiParam {String} title Post title by user (no more than 60 characters!)
@apiParam {String} text Post content (no more than 500)

@apiSuccess {Post} post_ob Outputs a post object. 
"""
@blueprint.route('/posting.json')
@cross_origin()
def discussion_createpost():
	pass

"""
@api {get} /likepost.json&post_id=121 Like a post
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