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

def getTimeParams():
	iTime = datetime.utcnow()
	dayTime = (iTime - datetime.combine(iTime.date(), time(0))).total_seconds()
	dayOfWeek = datetime.today().weekday()
	return dayTime, dayOfWeek

"""
@api {get} /classnearby.json?lon=50.1&lat=55.210021 Get class nearby
@apiName Classes Nearby
@apiGroup Classes
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
 	dayTime, dayOfWeek = getTimeParams()
	# Querying classes within range
	cList = Classes.query.filter(Classes.lat > iLat - accuracy_geo, Classes.lat < iLat + accuracy_geo,\
		Classes.lon > iLon - accuracy_geo, Classes.lon < iLon + accuracy_geo, \
		Classes.time > dayTime - accuracy_time, Classes.time < dayTime + accuracy_time, Classes.day == dayOfWeek)
	out = []
	for chunk in cList:
		out += {"name": chunk.name, "id": chunk.id, "uni": "", "dist": vincenty((chunk.lat, chunk.lon), (iLat, iLon)).miles}
 	return json.dumps(out)

"""
@api {post} /createclass.json?lat=50.1&lon=55.2&name=Physics%20101 Create the new class right here, right now
@apiName Create Class
@apiGroup Classes
@apiVersion 0.1.2

@apiParam {Integer} lon Location - longitude of the user
@apiParam {Integer} lat Location - longitude of the user
@apiParam {String} name Input the class id of the user 

@apiSuccess {String} JSON with class id and name

"""
@blueprint.route('/createclass.json', methods=['POST'])
@cross_origin()
def class_create():
	user_id = request.args.get('uid')
	name = request.args.get('name')
	lat = float(request.args.get('lat'))
	lon = float(request.args.get('lon'))
	dayTime, dayOfWeek = getTimeParams()
	gs = Classes(name, lat, lon, dayTime, dayOfWeek)
	db.session.add(gs)
	db.session.commit()
	created = Classes.query.filter(Classes.lat == lat, Classes.lon == lon, Classes.time == dayTime, Classes.day == dayOfWeek)[0]
	return json.dumps({"name": created.name, "id": created.id})

"""
@api {post} /joinclass.json?class_id=152 Join the class
@apiName Join Class
@apiGroup Classes
@apiVersion 0.1.1

@apiParam {Integer} class Input the class id of the user 
@apiParam {Integer} uid Input the id of the user 

@apiSuccess {Boolean} status Output if joining is successful

"""
@blueprint.route('/joinclass.json', methods=['POST'])
@cross_origin()
def class_join():
	user_id = request.args.get('uid')
	classid = request.args.get('class')
	gs = UserClasses(user_id=user_id, class_id=classid)
	db.session.add(gs)
	db.session.commit()
	return json.dumps({"status": True})

"""
@api {get} /myclass.json?user_id=123 Get my classes
@apiName My Classes
@apiGroup Classes
@apiVersion 0.1.1

@apiParam {Integer} uid Input the id of the user

@apiSuccess {String} classlist Outputs a list of classes that the user is a part of.

"""
@blueprint.route('/myclass.json')
@cross_origin()
def class_mine():
	user_id = request.form.get('uid')
	#raw = Classes.query.filter_by(id=sent)[0]
	synth = []
	#chks = Chunk.query.filter_by(lat=stats.id)
	return json.dumps(synth)