define({ "api": [  {    "type": "get",    "url": "/classnearby.json?lon=50.1&lat=55.210021",    "title": "Get class nearby",    "name": "Classes_Nearby",    "group": "Classes",    "version": "0.1.1",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "<p>Integer</p> ",            "optional": false,            "field": "lon",            "description": "<p>Location - longitude of the user</p> "          },          {            "group": "Parameter",            "type": "<p>Integer</p> ",            "optional": false,            "field": "lat",            "description": "<p>Location - longitude of the user</p> "          }        ]      }    },    "success": {      "fields": {        "Success 200": [          {            "group": "Success 200",            "type": "<p>String</p> ",            "optional": false,            "field": "class_name",            "description": "<p>Outputs a list of classes that is around this location at this time.</p> "          }        ]      }    },    "filename": "./classes.py",    "groupTitle": "Classes",    "sampleRequest": [      {        "url": "http://classintouch.me/classnearby.json?lon=50.1&lat=55.210021"      }    ]  },  {    "type": "post",    "url": "/createclass.json?lat=50.1&lon=55.2&name=Physics%20101",    "title": "Create the new class right here, right now",    "name": "Create_Class",    "group": "Classes",    "version": "0.1.2",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "<p>Integer</p> ",            "optional": false,            "field": "lon",            "description": "<p>Location - longitude of the user</p> "          },          {            "group": "Parameter",            "type": "<p>Integer</p> ",            "optional": false,            "field": "lat",            "description": "<p>Location - longitude of the user</p> "          },          {            "group": "Parameter",            "type": "<p>String</p> ",            "optional": false,            "field": "name",            "description": "<p>New class name (e.g. Physics 101)</p> "          }        ]      }    },    "success": {      "fields": {        "Success 200": [          {            "group": "Success 200",            "type": "<p>String</p> ",            "optional": false,            "field": "JSON",            "description": "<p>with class id and name</p> "          }        ]      }    },    "filename": "./classes.py",    "groupTitle": "Classes",    "sampleRequest": [      {        "url": "http://classintouch.me/createclass.json?lat=50.1&lon=55.2&name=Physics%20101"      }    ]  },  {    "type": "post",    "url": "/joinclass.json?uid=1&class_id=1",    "title": "Join the class",    "name": "Join_Class",    "group": "Classes",    "version": "0.1.1",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "<p>Integer</p> ",            "optional": false,            "field": "class",            "description": "<p>Input the class id of the user</p> "          },          {            "group": "Parameter",            "type": "<p>Integer</p> ",            "optional": false,            "field": "uid",            "description": "<p>Input the id of the user</p> "          }        ]      }    },    "success": {      "fields": {        "Success 200": [          {            "group": "Success 200",            "type": "<p>Boolean</p> ",            "optional": false,            "field": "status",            "description": "<p>Output if joining is successful</p> "          }        ]      }    },    "filename": "./classes.py",    "groupTitle": "Classes",    "sampleRequest": [      {        "url": "http://classintouch.me/joinclass.json?uid=1&class_id=1"      }    ]  },  {    "type": "get",    "url": "/myclass.json?uid=123",    "title": "Get my classes",    "name": "My_Classes",    "group": "Classes",    "version": "0.1.1",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "<p>Integer</p> ",            "optional": false,            "field": "uid",            "description": "<p>Input the id of the user</p> "          }        ]      }    },    "success": {      "fields": {        "Success 200": [          {            "group": "Success 200",            "type": "<p>String</p> ",            "optional": false,            "field": "classlist",            "description": "<p>Outputs a list of classes that the user is a part of.</p> "          }        ]      }    },    "filename": "./classes.py",    "groupTitle": "Classes",    "sampleRequest": [      {        "url": "http://classintouch.me/myclass.json?uid=123"      }    ]  },  {    "type": "get",    "url": "/getdiscussion.json?class_id=152",    "title": "Get discussion from a class",    "name": "Discussions_List",    "group": "Discussions",    "version": "0.1.1",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "<p>Integer</p> ",            "optional": false,            "field": "class_id",            "description": "<p>Input class the user selected</p> "          }        ]      }    },    "success": {      "fields": {        "Success 200": [          {            "group": "Success 200",            "type": "<p>Discussion</p> ",            "optional": false,            "field": "discussion_ob",            "description": "<p>Outputs a discussion object that is under the class.</p> "          }        ]      }    },    "filename": "./discussion.py",    "groupTitle": "Discussions",    "sampleRequest": [      {        "url": "http://classintouch.me/getdiscussion.json?class_id=152"      }    ]  },  {    "type": "get",    "url": "/getdiscussionpost.json?discussion_id=151",    "title": "Get a list of posts from the discussion.",    "name": "Get_Discussion_Post",    "group": "Discussions",    "version": "0.1.1",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "<p>Integer</p> ",            "optional": false,            "field": "discussion_id",            "description": "<p>Input class the user selected</p> "          }        ]      }    },    "success": {      "fields": {        "Success 200": [          {            "group": "Success 200",            "type": "<p>Post</p> ",            "optional": false,            "field": "postlist",            "description": "<p>Outputs a list of posts that is under the discussion.</p> "          }        ]      }    },    "filename": "./discussion.py",    "groupTitle": "Discussions",    "sampleRequest": [      {        "url": "http://classintouch.me/getdiscussionpost.json?discussion_id=151"      }    ]  },  {    "type": "post",    "url": "/likepost.json?uid=1&post_id=121",    "title": "Like a post",    "name": "Like_a_post",    "group": "Discussions",    "version": "0.1.1",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "<p>Integer</p> ",            "optional": false,            "field": "post_id",            "description": "<p>Input the post id of the user's post</p> "          },          {            "group": "Parameter",            "type": "<p>Integer</p> ",            "optional": false,            "field": "uid",            "description": "<p>User id</p> "          }        ]      }    },    "success": {      "fields": {        "Success 200": [          {            "group": "Success 200",            "type": "<p>Post</p> ",            "optional": false,            "field": "json",            "description": "<p>Outputs a post object.</p> "          }        ]      }    },    "filename": "./discussion.py",    "groupTitle": "Discussions",    "sampleRequest": [      {        "url": "http://classintouch.me/likepost.json?uid=1&post_id=121"      }    ]  },  {    "type": "post",    "url": "/posting.json?uid=1&post_id=13&title=question&text=text",    "title": "Create a new post",    "name": "Post_Message",    "group": "Discussions",    "version": "0.1.1",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "<p>Integer</p> ",            "optional": false,            "field": "discussion_id",            "description": "<p>Input the post id of the user's post to reply in the discussion</p> "          },          {            "group": "Parameter",            "type": "<p>Integer</p> ",            "optional": false,            "field": "class_id",            "description": "<p>OR Class id to initiate new thread in class</p> "          },          {            "group": "Parameter",            "type": "<p>String</p> ",            "optional": false,            "field": "title",            "description": "<p>Post title by user (no more than 60 characters!)</p> "          },          {            "group": "Parameter",            "type": "<p>String</p> ",            "optional": false,            "field": "text",            "description": "<p>Post content (no more than 500)</p> "          }        ]      }    },    "success": {      "fields": {        "Success 200": [          {            "group": "Success 200",            "type": "<p>Post</p> ",            "optional": false,            "field": "post_ob",            "description": "<p>Outputs a post object.</p> "          }        ]      }    },    "filename": "./discussion.py",    "groupTitle": "Discussions",    "sampleRequest": [      {        "url": "http://classintouch.me/posting.json?uid=1&post_id=13&title=question&text=text"      }    ]  },  {    "type": "get",    "url": "/profile.json&token=XYZ&user_id=152",    "title": "Get my profile",    "name": "Get_Profile",    "group": "UserAPI",    "version": "0.1.1",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "<p>String</p> ",            "optional": true,            "field": "token",            "defaultValue": "smth",            "description": "<p>Secret used for authentication</p> "          },          {            "group": "Parameter",            "type": "<p>Integer</p> ",            "optional": true,            "field": "id",            "defaultValue": "1",            "description": "<p>User_id</p> "          }        ]      }    },    "success": {      "fields": {        "Success 200": [          {            "group": "Success 200",            "type": "<p>Integer</p> ",            "optional": false,            "field": "user_id",            "description": "<p>Outputs user id for a newly registered user</p> "          },          {            "group": "Success 200",            "type": "<p>String</p> ",            "optional": false,            "field": "fb_name",            "description": "<p>Outputs user name for this user on facebook</p> "          }        ]      }    },    "filename": "./user.py",    "groupTitle": "UserAPI",    "sampleRequest": [      {        "url": "http://classintouch.me/profile.json&token=XYZ&user_id=152"      }    ]  },  {    "type": "post",    "url": "/logout.json",    "title": "Log out",    "name": "Logout",    "group": "UserAPI",    "version": "0.1.1",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "<p>String</p> ",            "optional": false,            "field": "access_token",            "description": "<p>Input from facebook</p> "          }        ]      }    },    "success": {      "fields": {        "Success 200": [          {            "group": "Success 200",            "type": "<p>Redirect</p> ",            "optional": false,            "field": "none",            "description": "<p>Redirects to main page</p> "          }        ]      }    },    "filename": "./user.py",    "groupTitle": "UserAPI",    "sampleRequest": [      {        "url": "http://classintouch.me/logout.json"      }    ]  },  {    "type": "post",    "url": "/register.json&access_token=XYZ",    "title": "Register into the game",    "name": "Register",    "group": "UserAPI",    "version": "0.1.1",    "parameter": {      "fields": {        "Parameter": [          {            "group": "Parameter",            "type": "<p>String</p> ",            "optional": false,            "field": "access_token",            "description": "<p>Input from facebook</p> "          }        ]      }    },    "success": {      "fields": {        "Success 200": [          {            "group": "Success 200",            "type": "<p>Integer</p> ",            "optional": false,            "field": "user_id",            "description": "<p>Outputs user id for a newly registered user</p> "          },          {            "group": "Success 200",            "type": "<p>String</p> ",            "optional": false,            "field": "fb_name",            "description": "<p>Outputs user name for this user on facebook</p> "          }        ]      }    },    "filename": "./user.py",    "groupTitle": "UserAPI",    "sampleRequest": [      {        "url": "http://classintouch.me/register.json&access_token=XYZ"      }    ]  },  {    "success": {      "fields": {        "Success 200": [          {            "group": "Success 200",            "optional": false,            "field": "varname1",            "description": "<p>No type.</p> "          },          {            "group": "Success 200",            "type": "<p>String</p> ",            "optional": false,            "field": "varname2",            "description": "<p>With type.</p> "          }        ]      }    },    "type": "",    "url": "",    "version": "0.0.0",    "filename": "./apidoc/main.js",    "group": "_Users_ourzhumt_projects_classintouch_backend_apidoc_main_js",    "groupTitle": "_Users_ourzhumt_projects_classintouch_backend_apidoc_main_js",    "name": ""  }] });