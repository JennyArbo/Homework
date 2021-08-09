#!/usr/bin/env python

#1) Create a basic API in Azure (as we did in class) that tells you how to access the different endpoints when you go
#   to the home page. 

#import necessary libraries
#pip install flask  
#export FLASK_APP=flask-app
from flask import Flask, json, render_template, request
import os

#create instance of Flask app
app = Flask(__name__)

#decorator
@app.route("/")
def echo_hello():
    return "<p>Tutorial!<p>"

#1a) A /all endpoint that displays all of the nobel.json data
@app.route("/all")
def all():
    json_url = os.path.join(app.static_folder,"","nobel.json")
    data_json = json.load(open(json_url))
    #render_template is always looking in templates folder
    return render_template('index.html',data=data_json)

@app.route("/all/<year>")
def all_year(year):
    json_url = os.path.join(app.static_folder,"","nobel.json")
    data_json = json.load(open(json_url))
    data = data_json('prizes')
    year = request.view_args['year']
    output_data = [x for x in data if x['year']==year]
    #render_template is always looking in templates folder
    return render_template('index.html',data=output_data)

if __name__ == "__main__":
    app.run(debug=True)