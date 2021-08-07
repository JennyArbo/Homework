from flask import Flask, render_template, request, send_file
import os
import pandas as pd
import requests
import time
import datetime
from flask_pymongo import PyMongo


app = Flask(__name__)

#setup mongo connection
app.config["MONGO_URI"] = "mongodb://localhost:27017/shows_db"
mongo = PyMongo(app)

#connect to collection
tv_shows = mongo.db.tv_shows

#READ
@app.route("/")
def index():
    #find all items in db and save to variable
    all_shows = list(tv_shows.find())
    print(all_shows)

    return render_template("index.html",data=all_shows)

#decorator
@app.route("/tutorial")
def tutorial():
    tutorial_url = os.path.join(app.static_folder,"","mongo_template_tv.html")
    return send_file(tutorial_url)


#incorporating new info form and insert_one to add new information to the db
@app.route("/create", methods = ['POST', 'GET'])
def update_info():
    if request.method == 'GET':
        form_url = os.path.join(app.static_folder,"","new_info_form.html")
        return send_file(form_url)
    
    elif request.method == 'POST':
        
        new_name = request.form['name']
        new_seasons = request.form['seasons']
        new_duration = request.form['duration']
        new_year = request.form['year']
        new_date_added = datetime.datetime.utcnow()
        new_show_info = {"name": new_name, "seasons": new_seasons,
                        "duration":new_duration, "year":new_year,
                        "new_date_added": new_date_added}

        tv_shows.insert_one(new_show_info)
 
        #Adding text
        #text_success = "Data successfully added." 
        #
        cursor = tv_shows.find()
        response_string = "The data has been added. "
        print("The data has been added.")
       # for record in cursor:
            #response_string = response_string + record
        #all_shows = list(tv_shows.find())
        #response_string = response_string + str(all_shows)
        return render_template('index_plain.html',data = response_string)

    else:
        error_message = "That is an invalid input. Please enter valid input then try again."
        return render_template('index_plain.html', data = error_message)

#incorporating  update form and insert_one to update db
@app.route("/update", methods = ['POST', 'GET'])
def handle_info():
    if request.method == 'GET':
        form_url = os.path.join(app.static_folder,"","update_form.html")
        return send_file(form_url)
    
    elif request.method == 'POST':
        
        update_name = request.form['name']
        update_seasons = request.form['seasons']
        update_duration = request.form['duration']
        update_year = request.form['year']
   
        filter = {'name': update_name}
        update_show_info ={}
        if update_seasons != '':
            update_show_info['seasons'] = update_seasons
        if update_duration != '':
            update_show_info['duration'] = update_duration
        if update_year != '':
            update_show_info['year'] = update_year
        print(update_show_info)

        update_values = { "$set": update_show_info }

        tv_shows.update_one(filter, update_values)
 
        #Adding text
        text_success = "Data successfully updated." 
        return render_template('index_plain.html',data = text_success)

    else:
        error_message = "That is an invalid input. Please enter valid input then try again."
        return render_template('index_plain.html', data = error_message)


#incorporating new info form and insert_one to add new information to the db
@app.route("/delete", methods = ['POST', 'GET'])
def delete_info():
    if request.method == 'GET':
        form_url = os.path.join(app.static_folder,"","delete_form.html")
        return send_file(form_url)
    
    elif request.method == 'POST':
        
        delete_name = request.form['name']
  
        delete_show_info = {"name": delete_name}

        tv_shows.delete_one(delete_show_info)
 
        #Adding text
        response_string = "The data has been deleted."
        print(response_string)
        return render_template('index_plain.html',data = response_string)

    else:
        error_message = "That is an invalid input. Please enter valid input then try again."
        return render_template('index_plain.html', data = error_message)

if __name__ == "__main__":
    app.run(debug=True)

