"""
@api {get} /sent.json?lang=:lang&topic=:topic&level=:level&count=:count Get sentence from the game
@apiName GetSentence
@apiGroup GameBackend
@apiVersion 0.1.1

@apiParam {Integer, Interger} user_location Input the location of the user
@apiParam {Integer} user_time Input the time of the user (probably not)

@apiSuccess {String*} class_name Outputs a list of classes that is around this location at this time.

"""
@blueprint.route('/classnearby.json')
@cross_origin()
def class_nearby():
	pass

"""
@api {get} /sent.json?lang=:lang&topic=:topic&level=:level&count=:count Get sentence from the game
@apiName GetSentence
@apiGroup GameBackend
@apiVersion 0.1.1

@apiParam {Integer} class_id Input the time of the user (probably not)

@apiSuccess {String*} class Outputs a list of classes that is around this location at this time.

"""
@blueprint.route('/joinclass.json')
@cross_origin()
def class_join():
	pass

"""
@api {get} /sent.json?lang=:lang&topic=:topic&level=:level&count=:count Get sentence from the game
@apiName GetSentence
@apiGroup GameBackend
@apiVersion 0.1.1

@apiParam {Integer} user_id Input the id of the user

@apiSuccess String*} class Outputs a list of classes that the user is a part of.

"""
@blueprint.route('/myclass.json')
@cross_origin()
def class_mine():
	pass