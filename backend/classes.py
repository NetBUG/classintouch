#coding=utf-8
from flask import Blueprint, url_for, render_template, render_template_string, redirect, request, current_app, send_from_directory
from flask_cors import cross_origin
from datetime import datetime, time
from geopy.distance import vincenty
import ujson as json

from models import *

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
	iLat = float(request.args.get('lat'))
	iLon = float(request.args.get('lon'))
 	iTime = datetime.utcnow()
	dayTime = (iTime - datetime.combine(iTime.date(), time(0))).total_seconds()
	dayOfWeek = datetime.today().weekday()
	# Querying classes within range
	cList = Classes.query.filter(Classes.lat > iLat - accuracy_geo, Classes.lat < iLat + accuracy_geo,\
		Classes.lon > iLon - accuracy_geo, Classes.lon < iLon + accuracy_geo, \
		Classes.time > dayTime - accuracy_time, Classes.time < dayTime + accuracy_time, Classes.day == dayOfWeek)
	for chunk in cList:
		out += {"name": chunk.name, "id": chunk.id, "uni": "", "dist": vincenty((chunk.lat, chunk.lon), (iLat, iLon)).miles}
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
def class_join(form):
	classid = request.form.get('class')
	gs = GameSessionsWordOrder(user_id=user_id, src_id=sent_id, result=res, ev=calculated_score)
	db.session.add(gs)
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
	#raw = Classes.query.filter_by(id=sent)[0]
	synth = ''
	#chks = Chunk.query.filter_by(lat=stats.id)
	pass