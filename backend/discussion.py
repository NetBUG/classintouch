#coding=utf-8
from flask import Blueprint, url_for, render_template, render_template_string, redirect, request, current_app, send_from_directory, make_response
from flask_cors import cross_origin
from models import *
from sqlalchemy import or_

blueprint = Blueprint('discussion', __name__)

"""
@api {get} /getdiscussion.json?class_id=152 Get discussion from a class
@apiName Discussions List
@apiGroup Discussions
@apiVersion 0.1.1

@apiParam {Integer} class_id Input class the user selected

@apiSuccess {Discussion} discussion_ob Outputs a discussion object that is under the class. 

"""
@blueprint.route('/getdiscussion.json')
@cross_origin()
def discussion_get():
	class_id = request.args.get('class_id')
	raw = Post.query.filter(Post.class_id == class_id, Post.parent == None)
	synth = []
	for post in raw:
		cls = Like.query.filter_by(post_id=post.id)
		synth.append({"id": post.id, "title": post.title, "text": post.text, "likes": cls.count()})
	resp = make_response(json.dumps(synth))
	resp.mimetype="application/json"
	return resp

"""
@api {get} /getdiscussionpost.json?discussion_id=151 Get a list of posts from the discussion.
@apiName Get Discussion Post
@apiGroup Discussions
@apiVersion 0.1.1

@apiParam {Integer} discussion_id Input class the user selected

@apiSuccess {Post} postlist Outputs a list of posts that is under the discussion. 

"""
@blueprint.route('/getdiscussionpost.json')
@cross_origin()
def discussion_getpost():
	thread_id = request.args.get('discussion_id')
	raw = Post.query.filter(or_(Post.parent == thread_id, Post.id == thread_id))
	synth = []
	for post in raw:
		cls = Like.query.filter_by(post_id=thread_id)
		synth.append({"id": post.id, "title": post.title, "text": post.text, "likes": cls.count(), "user": post.user_id})
	resp = make_response(json.dumps(synth))
	resp.mimetype="application/json"
	return resp

"""
@api {post} /posting.json?uid=1&post_id=13&title=question&text=text Create a new post
@apiName Post Message
@apiGroup Discussions
@apiVersion 0.1.1

@apiParam {Integer} discussion_id Input the post id of the user's post to reply in the discussion
@apiParam {Integer} class_id OR Class id to initiate new thread in class
@apiParam {String} title Post title by user (no more than 60 characters!)
@apiParam {String} text Post content (no more than 500)

@apiSuccess {Post} post_ob Outputs a post object. 
"""
@blueprint.route('/posting.json', methods=['POST'])
@cross_origin()
def discussion_createpost():
	resp = make_response(json.dumps({"status": False, "message": "Parameters error, probably no user ID (uid)!"}))
	try:
		title = request.args.get('title')
		text = request.args.get('text')
		user_id = int(request.args.get('uid'))
		class_id = request.args.get('class_id')
		thread_id = request.args.get('discussion_id')
		if thread_id != None:
			thread_id = int(thread_id.strip())
			class_id = None
		else:
			class_id = int(class_id.strip())
		post = Post(class_id, title, text, thread_id)
		post.parent = thread_id
		post.class_id = class_id
		post.user_id = user_id
		db.session.add(post)
		db.session.commit()
		resp = make_response(json.dumps({"status": True, "user": user_id, "id": post.id, "title": post.title, "text": post.text, "likes": 0}))
	except:
		pass
	resp.mimetype="application/json"
	return resp

"""
@api {post} /likepost.json?uid=1&post_id=121 Like a post
@apiName Like a post
@apiGroup Discussions
@apiVersion 0.1.1

@apiParam {Integer} post_id Input the post id of the user's post
@apiParam {Integer} uid User id

@apiSuccess {Post} json Outputs a post object. 
"""
@blueprint.route('/likepost.json', methods=['POST'])
@cross_origin()
def discussion_likepost():
	resp = make_response(json.dumps({"status": False, "message": "Parameters error!"}))
	try:
		post_id = int(request.args.get('post_id'))
		user_id = int(request.args.get('uid'))
		# TODO: implement no more than single like!
		like = Like()
		like.post_id = post_id
		like.user_id = user_id
		db.session.add(like)
		db.session.commit()
		resp = make_response(json.dumps({"status": True}))
	except:
		pass
	resp.mimetype="application/json"
	return resp