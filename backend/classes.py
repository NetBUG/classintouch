#coding=utf-8
from flask import Blueprint, url_for, render_template, render_template_string, redirect, request, current_app, send_from_directory
from flask_cors import cross_origin
from datetime import datetime
import ujson as json

blueprint = Blueprint('classes', __name__)

accuracy_geo = 0.05	# degrees, TODO make a normal geo distance!
accuracy_time = 3600 # an hour in both directions

"""
@api {get} /classnearby.json&lon=100&lat=100&class_name=phy Get class nearby
@apiName Classes
@apiGroup ClassInTouch
@apiVersion 0.1.1

@apiParam {Integer} lon Location - longitude of the user
@apiParam {Integer} lat Location - longitude of the user

@apiSuccess {String} class_name Outputs a list of classes that is around this location at this time.

"""
@blueprint.route('/classnearby.json')
@cross_origin()
def class_nearby():
	time = datetime.utcnow()
	# dayTime = 
	# dayOfWeek = 
	out = [{"name": "Physics 121", "id": "1", "uni": "Caltech", "dist": "7000"}, {"name": "Cantonese 101", "id": "5", "uni": "HKUST", "dist": "30"}]
	# Querying classes within range
	return json.dumps(out)

"""
@api {post} /joinclass.json&class_id=152 Join the class
@apiName Classes
@apiGroup ClassInTouch
@apiVersion 0.1.1

@apiParam {Integer} class_id Input the class id of the user 

@apiSuccess {Boolean} Output if joining is successful

"""
@blueprint.route('/joinclass.json')
@cross_origin()
def class_join():
	pass

"""
@api {get} /myclass.json&user_id=123 Get my classes
@apiName Classes
@apiGroup ClassInTouch
@apiVersion 0.1.1

@apiParam {Integer} user_id Input the id of the user

@apiSuccess {String} class Outputs a list of classes that the user is a part of.

"""
@blueprint.route('/myclass.json')
@cross_origin()
def class_mine():
	pass