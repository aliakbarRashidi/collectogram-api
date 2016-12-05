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

## What I Did
I split the application into two parts; a frontend and a backend.  

The Backend:

- Runs Rails in API mode (no views, etc.)
- Uses PostgreSQL for the database
- Has two models: Collections and Cards
    - Collections have a Name, Tag, StartDate, EndDate, and Visibility
    - Cards belong to collections, and have all of the Image/User Data
- Uses RSpec, FactoryGirl, WebMock, and Faker for testing
- Deployed to Heroku

The Frontend:

- Runs React, Webpack, ES6 (Babel)
- No Redux/Immutable.js (kept it as simple as possible)
- App is broken down into Components, Containers, and Views
    - Components are basic (Buttons, Toggles, etc.)
    - Containers represent Models (Collections, Cards)
    - Views represent Pages (Home, Create, etc.)
- Deployed as a static site to Amazon S3


## Some Interesting Choices I Made


## Some Improvements I Would Like To Make

There are a few improvements that I would like to make to the application.

The first is on the Frontend. I set up a datepicker component, but had not had time to build or pull in a third party datepicker function. Right now, the datepicker is essentially a textfield with some extra validation. It would be a great improvement to the user experience, without requiring too much extra work.

The second is on the Backend. Right now, the pagination process relies on Limit+Offset calls. While this is a simple and easy implementation of pagination, it adds some restrictions to the application. On the "Collection List" page, I am forced to order the collections from oldest to newest. This is because of the issues with Limit+Offset. Suppose two users are using the application at one time (A and B). A is on the 3rd page of the Collection List. B creates a new collection. If we order by most recent collection, then B's new collection is added to the top of A's list. When A goes to the next page, the list will be updated, and "bumped" down by one. Because the offset does not take this account, we will see the last item of the 3rd page twice. Ideally, we would solve this in a similar manner to how the Instagram API works - the json response would need to provide the id for the first collection on the next page.

Lastly, I would like to improve the API by adding some asynchronous API calls. Right now, the app "gets more data when it needs it". If the users requests page 4 of a collection's cards, but those cards are not stored in the database, then the app fetches the next page (which slows down the user while they wait for Instagram's API to responsd). It would be great if we could always prepeare data for one or two pages in advance, as it would make the frontend experience feel a lot more fluid.


If I had more time, I would focus on making the backend as stable as possible by improving the fault tolerence and security.

## Conclusion

Collectogram was an interesting project to work on, and I had a great time building it up. While there are lots of areas for improvement, I'm very happy with the current state of the application, and I feel that it is a good reflection of my programming abilities.

If you would like to learn more about the development of Collectogram, please check out my "[Development Walkthrough](https://mackie.io/posts/collectogram_part_1_-_design.html)". I provide some insight into my design considerations, and show how testing helped drive parts of the development process.
<br>
If you have any other questions, you can always email me at: [scott@mackie.io](scott@mackie.io).
