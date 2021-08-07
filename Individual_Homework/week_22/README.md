# Week 22 Webscraping Homework README

### Question 1
I created a Python function stored in a .py file to find 50 nearby restaurants in my yelp_scraper_app folder. 
I pulled: restaurant name, location, average review, number of reviews, and price range.
I used beautiful woup and tried both with and without the Chrome driver. Sadly, every single electronic device in our house was banned from Yelp as a result. Everything was working in Jupyter Notebook before the ban and I was finalizing testing from VS Code. I added in sleep times each time I pull data from Yelp so hopefully that may help avoid getting banned in the future. I have attached a jupyter file showing a working dataframe (minus the addresses-I had them working but didn't save in the dataframe before I was banned). This is in my week_22 folder on my Github repo.

### Question 2
I set up a local API to write to a json file using my function. Using the /all endpoint after the code has run will return the details for each field mentioned in Question 1. I also created a tutorial html file to explain how to best use my app (POST endpoint for pulling and adding data, /all, and /form_add endpoints are discussed). As part of this, I created a new form which asks for business type (for now, will only work for restaurant), location (input as city, state OR 5-digit zip code), and a yes/no option for pulling address details (I believe this is the step that caused me to get banned so theoretically everything except for those details could be pulled hopefully without poor consequences).

I did not have time to try deploying to Azure as trying to deal with my Yelp ban to access the data took all of the "extra" time I had set aside.

### Question 3
Webscraping is a programmatic way to systematically extract specific information/data from websites. It can have a variety of uses, some of which are more potentially nefarious than others (can be used to look at weather forecasts, business details/listings --ex. Yelp, Google reviews, even Airbnb etc, find the best product prices, etc).

Webscraping offers access to an astounding amount of data. It can be used to access data allowing for monitoring of compliance, analyzing customer sentiment, analyzing popular news sites, looking at market trends, provide training data for machine learning models, etc. Basically, the wide range of types and amounts of data make webscraping an appealing option for a vast number of fields. With that said, there is a lot of moral (and legal!) grey area and webscraping should be approached carefully.

Typically, obtaining the data is not considered illegal, but it may be against terms of service (see my Yelp ban for an example) and what you DO with the data can be illegal. Examples of illegal use could be doing anything that causes the original company harm by selling their data, taking credit for someone else's work as your own, etc. Scraping can also overwhelm servers creating issues for the sites being scraped. There is a lot of legal grey area in the world of webscraping and care should be taken both when scraping the data and deciding how or if to use it. 

