# Collectogram Backend

This is the backend for the Collectogram application.
You can view the frontend by clicking [here](https://github.com/MacroMackie/collectogram-web). 
<br>
## Online Demo
You can view an online demo by clicking [here](http://collectogram-web.s3-website-us-west-2.amazonaws.com/#/home).
<br>
## Running the Application Locally
First, clone the repo.
```bash
git clone https://github.com/MacroMackie/collectogram-api.git
cd collectogram-api
```

Next, set up the local postgres database:
```ruby
bin/rails db:create
bin/rails db:migrate
```

Lastly, start the webserver
```ruby
bin/rails s
```

Now, follow the setups steps on on the [Frontend GitHub Page](https://github.com/MacroMackie/collectogram-web). After that, it should be up and running.
<br>
<br>
<br>
<br>
# Collectogram
## Project Overview

The goal of Collectogram was to build a web application that takes a hashtag, start date, and end date, and collects any matching submissions from Instragram, arranging them into a "Collection". You can view the full project guidelines here: [Project Overview](http://localhost/mackie/website/assets/posts/files/collectogram-project-guidelines.pdf)

A quick summary of the objectives:

- The web app must have a web interface and backend api
- The user must be able to create new collections through the website by providing a hashtag, start_date, and end_date
- The user must be able to view their collection

I decided to extend this a little bit further, and add three more objectives

- The user should be able to specify whether they want their collection to be public or private
- Users should be able to view a list of all public collections
- Users should be able to share their collections with a uniquely generated URL

To simplify the project, I decided against building in a user-signup-login model. This makes the application more accessible for new users, and makes it simple for users to share their collections with others.
