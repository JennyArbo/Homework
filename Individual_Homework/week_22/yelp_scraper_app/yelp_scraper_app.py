#!/usr/bin/env python

#1) Create a basic API in Azure (as we did in class) that tells you how to access the different endpoints when you go
#   to the home page. 

#import necessary libraries
#pip install flask  
#export FLASK_APP=flask-app
from flask import Flask, json, render_template, request, send_file
import os
import pandas as pd
from bs4 import BeautifulSoup as bs
import requests
import time

#create instance of Flask app
app = Flask(__name__)

#Scraper function
def yelp_scraper(new_info):
    all_restaurants = []
    user_input_type = new_info["type"]
    user_input_location = new_info["location"]
    get_address_details = new_info["get_address_details"]

    for i in range(0,5):

        if i == 0:
            url_build = f'https://www.yelp.com/search?cflt={user_input_type}&find_loc={user_input_location}'
        else:
            url_build = f'https://www.yelp.com/search?cflt={user_input_type}&find_loc={user_input_location}&start={i*10}' 


        response = requests.get(url_build)

        soup = bs(response.text, 'html.parser')

        time.sleep(5)
        
        all_info = soup.find_all('div',class_='arrange__09f24__1Vghi border-color--default__09f24__3Epto')


 

        for i in all_info:
            try:
                #To find the name of each restaurant
                info_element = i.find('h4',class_='css-1l5lt1i')
                if info_element is None:
                    continue
                name_url_element = info_element.find('a', href=True)
                name_url = name_url_element['href']
                if name_url.startswith('/adredir'):
                    continue
                name=name_url_element['name']
        
                #To find the number of reviews for each restaurant
                num_review_element = i.find('span', class_='reviewCount__09f24__3GsGY css-e81eai')
                num_review = num_review_element.text
        
                #To find the average rating for each restaurant
                star_rating_element = i.find('div', class_='i-stars__09f24___sZu0')
                star_rating = star_rating_element['aria-label']
        
                #To find price category tag
                price_cat_element = i.find('span', class_='priceRange__09f24__2GspP css-e81eai')
                if price_cat_element is None:
                    price_cat = 'undefined'
                else:
                    price_cat = price_cat_element.text
            
            
                #Couldn't test because Yelp IP banned me (but it was working on it's own prior to ban)
                
                #print(site)
                if get_address_details == 'yes':
                    
                    url2 = 'https://yelp.com' + name_url
                    #browser.visit(url2)
                    #soup = bs(browser.html, 'html.parser')
                    #print(soup)
                    response = requests.get(url2)
                    #print(response)
                    soup = bs(response.text, 'html.parser')
                    
                    time.sleep(5)
    
                    addresses = soup.find('address')
                    if addresses is None:
                        #print(site)
                        print(soup)
                    all_addresses = addresses.find_all('p')
    

                    #for a in all_addresses:
                    # restaurant_address = a.find('span', class_='raw__373c0__3-nUb')
                    street_address = all_addresses[0].text
                    city_address = all_addresses[1].text
                    #address_dict = {'street': street_address, 'city': city_address}
                    #address_list.append(address_dict)
                    #street_address_list.append(street_address)
                
                else:
                    street_address = 'did not fetch'
                    city_address = 'did not fetch'
                #End Yelp nonsense
                
                rest_dict = {'restaurant_name': name,
                            'restaurant_rating': star_rating,
                            'restaurant_number_reviews': num_review,
                            'restaurant_price_range':price_cat,
                            'street_address': street_address,
                            'city_address': city_address}
   
                all_restaurants.append(rest_dict)
    
            except AttributeError as e:
                print(e)
                #print(info_element)
    return all_restaurants

#decorator
@app.route("/")
def tutorial():
    tutorial_url = os.path.join(app.static_folder,"","yelp_scraper_tutorial.html")
    return send_file(tutorial_url)

#Need to change this-put in my python function here???
#1a) A /all endpoint that displays all of the yelp.json data
@app.route("/all")
def all():
    json_url = os.path.join(app.static_folder,"","yelp_scraper.json")
    data_json = json.load(open(json_url))
    #render_template is always looking in templates folder
    return render_template('index.html',data=data_json)


#Adding an endpoint for the form
@app.route("/form_add")
def form():
    form_url = os.path.join(app.static_folder,"","restaurant_post.html")
    return send_file(form_url)

#code for adding year endpoing with POST and GET methods
@app.route("/business_info", methods = ['POST'])
def handle_info():
    if request.method == 'POST':
        new_type = request.form['type']
        new_location = request.form['location']
        get_address_details = request.form['get_address_details']
        new_info = {"type": new_type, "location": new_location, 
            "get_address_details": get_address_details}


        new_restaurant_pull = yelp_scraper(new_info)


        json_url = os.path.join(app.static_folder,"","yelp_scraper.json")
        with open(json_url) as f:
            data_json = json.load(f)
        new_data_json = data_json + new_restaurant_pull
        with open(json_url, "w") as f:
            json.dump(new_data_json, f)
        
        #Adding text
        text_success = "Data successfully added." 
        return render_template('index.html',data = text_success)


# Reset back to original nobel.json, getting rid of data added through post
@app.route("/reset")
def reset_data():
    original_json_url = os.path.join(app.static_folder,"","original_yelp_scraper.json")
    json_url = os.path.join(app.static_folder,"","yelp_scraper.json")
    with open(json_url, "w") as f:
        json.dump('', f)
    return render_template('index.html',data="File reset")

if __name__ == "__main__":
    app.run(debug=True)



 