#!/usr/bin/env python

#1) Create a basic API in Azure (as we did in class) that tells you how to access the different endpoints when you go
#   to the home page. 

#import necessary libraries
#pip install flask  
#export FLASK_APP=flask-app
from flask import Flask, json, render_template, request, send_file
import os

#create instance of Flask app
app = Flask(__name__)

#decorator
@app.route("/")
def tutorial():
    tutorial_url = os.path.join(app.static_folder,"","tutorial.html")
    return send_file(tutorial_url)

#1a) A /all endpoint that displays all of the nobel.json data
@app.route("/all")
def all():
    json_url = os.path.join(app.static_folder,"","nobel.json")
    data_json = json.load(open(json_url))
    #render_template is always looking in templates folder
    return render_template('index.html',data=data_json)


#1b and c
#Adding an endpoint for the form
@app.route("/form_add")
def form():
    form_url = os.path.join(app.static_folder,"","post.html")
    return send_file(form_url)

#code for adding year endpoing with POST and GET methods
@app.route("/<year>", methods = ['POST', 'GET'])
def handle_year(year):
    if request.method == 'POST':
        new_year = request.form['year']
        new_cat = request.form['category']
        new_laur = []
        nl_id1 = request.form['id1']
        nl_id2 = request.form['id2']
        nl_id3 = request.form['id3']
        nl_fn1 = request.form['firstname1']
        nl_fn2 = request.form['firstname2']
        nl_fn3 = request.form['firstname3']
        nl_sn1 = request.form['surname1']
        nl_sn2 = request.form['surname2']
        nl_sn3 = request.form['surname3']
        nl_m1 = request.form['motivation1']
        nl_m2 = request.form['motivation2']
        nl_m3 = request.form['motivation3']
        nl_s1 = request.form['share1']
        nl_s2 = request.form['share2']
        nl_s3 = request.form['share3']
        if nl_id1 != '':
            nl = {"id": nl_id1, "firstname": nl_fn1, "surname":
            nl_sn1, "motivation": nl_m1, "share": nl_s1}
            new_laur.append(nl)
        if nl_id2 != '':
            nl = {"id": nl_id2, "firstname": nl_fn2, "surname":
            nl_sn2, "motivation": nl_m2, "share": nl_s2}
            new_laur.append(nl)
        if nl_id3 != '':
            nl = {"id": nl_id3, "firstname": nl_fn3, "surname":
            nl_sn3, "motivation": nl_m3, "share": nl_s3}
            new_laur.append(nl)
        new_prize = {"year": new_year, "category": new_cat,
         "laureates":new_laur}

        json_url = os.path.join(app.static_folder,"","nobel.json")
        with open(json_url) as f:
            data_json = json.load(f)
        data_json['prizes'].append(new_prize)
        with open(json_url, "w") as f:
            json.dump(data_json, f)
        
        #Adding text
        text_success = "Data successfully added: " + str(new_prize)
        return render_template('index.html',data = text_success)

    #If data is not being added, we will just read from the json file and return info from the year of interest
    else:
        json_url = os.path.join(app.static_folder,"","nobel.json")
        data_json = json.load(open(json_url))
        data = data_json['prizes']
        year = request.view_args['year']
        output_data = [x for x in data if x['year']==year]
        #render_template is always looking in templates folder
        return render_template('index.html',data=output_data)

# Reset back to original nobel.json, getting rid of data added through post
@app.route("/reset")
def reset_data():
    original_json_url = os.path.join(app.static_folder,"","original_nobel.json")
    json_url = os.path.join(app.static_folder,"","nobel.json")
    with open(original_json_url) as f:
        data_json = json.load(f)
    with open(json_url, "w") as f:
        json.dump(data_json, f)
    return render_template('index.html',data="Data reset to original")

if __name__ == "__main__":
    app.run(debug=True)


'''API stands for "application programming interface". A key feature is that APIs utilize
the cloud. This allows a company access to more resources. They can allow for the transfer 
of data (as we did here; in this homework, we created a website with information about 
the nobel prize data and allowed for that data to a) be accessed and b) be added to.)
APIs do much more than just serving as a manner to share and connect to data sources. 
As the name implies, they also serve as a way to connect various products and software 
based services to one another. The structure of APIs also mean that it can be easier and
more simple to integrate new components into existing framework. They can help companies 
quickly adapt and push out new services as needed. They can also be useful for internal 
company needs, such as connecting various internal services and data.

APIs can be public, private, or hybrid/partner. Private APIs are only used internally within
a company. Public APIs are available to anyone. Partner or hybrid APIs are shared with 
specific groups of people (perhaps business partners) only.

Generally, APIs are classified as SOAP (simple object access protocol)  which receive 
information from HTTP (or SMTP) requests. They are useful when dealing with different 
software environments which may be written in different languages. SOAP is a protocol.
REST (representation state transfer) is an actual software architectural style while SOAP
 is a set of protocols. REST is often easier to impliment and are much simpler than SOAP.
 There are currently no strict definitions or standards for REST but there have been 
 some recent efforts to standardize. '''

 