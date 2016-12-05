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
    - Collections have a Name, Tag, StartDate, EndDate, and Visibility (Public vs. Private)
    - Cards belong to collections, and have all of the Image/User Data
- Has a single Collections controller with create, show, index
    - Create: creates a new collection and gets the first page of matching photos from instagram
    - Show: returns a collection's data along with the card data
    - Index: returns a list of all public collections
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

There are a few interesting choices I made that helped shape the final application.

I chose to add a "Collection List" page which would show a list of all public collections. This introduced a third endpoint into the mix, and required a few more components for the frontend. While it was a bit more work, I feel that it greatly enhances the user experience, and allows users to take a look at a few Collections before having to create their own.

I chose to avoid using a 'user' model, and instead gave each collection a unique_url. This avoided a lot of work developing login/signup pages, and made the application more approachable. As well, it allows anyone to easily share public collections by sharing the url ([Example](http://collectogram-web.s3-website-us-west-2.amazonaws.com/#/collections/VDRhi-fQ-zdSk3va74XNePcP1WI3qHRn)). I decided to use a unique_url (rather than just share the id) to give some privacy to users who wish to make their collections "private".

I chose to pull all of the Instagram-related logic into a seperate module. This makes the Collection model's methods seem almost a little too "magical", but it also greatly improved the readibility of the file.

I chose to add some error response codes when the API is unable to complete certain operations. In the case where the user selects a tag and time period, but there are no images matching those criteria, the API returns {error: 1001} (Rather than creating an empty collection.) There is another, more frustrating case to consider. Instagram's API does not allow you to request specific time periods, and always returns data as a form of "linked lists of pages", starting with the most recent page of images. This is fine when you are searching for recent images, but in the case where you want to find #nofilter images from 6 months ago, I would have to paginate through the Instagram API endpoint thousands of times. Because of instagram's API limiting, I can only make a certain amount of requests each hour. In order to reduce the chance of hitting that cap, I limit the image-gather function to make only 25 requests at one time. In the case where a user wants to create a collection that is far back in time, but hits the rate limit, I respond with {error: 1002}. Specifying these error codes allows my to present the user with much more helpful information on the frontend.

I chose to build out a test suite with Webmock, which allowed me to test against a fake Instagram server. This was extremely helpful when initially working on the Instagram module.

## Some Improvements I Would Like To Make

There are a few improvements that I would like to make to the application.

The first is on the Frontend. I set up a datepicker component, but had not had time to build or pull in a third party datepicker function. Right now, the datepicker is essentially a textfield with some extra validation. It would be a great improvement to the user experience, without requiring too much extra work.

The second is on the Backend. Right now, the pagination process relies on Limit+Offset calls. While this is a simple and easy implementation of pagination, it adds some restrictions to the application. On the "Collection List" page, I am forced to order the collections from oldest to newest. This is because of the issues with Limit+Offset. Suppose two users are using the application at one time (A and B). A is on the 3rd page of the Collection List. B creates a new collection. If we order by most recent collection, then B's new collection is added to the top of A's list. When A goes to the next page, the list will be updated, and "bumped" down by one. Because the offset does not take this account, we will see the last item of the 3rd page twice. Ideally, we would solve this in a similar manner to how the Instagram API works - the json response would need to provide the id for the first collection on the next page.

The third is that I would like to improve the way we get tagged images from the Instagram API. Some context for the issue; The image-gather function has two phases. In the first phase, it finds the first image in the set of matching images. In the second phase, it iterates over matching images, until it passes the end date. Right now, there is an error when encountering a specific corner case with comments. The error happens because my image-gather function looks exclusively at the "captioned-time" when it is looking for the very first matching image. In the case that the very first matching tagged image is tagged in a comment, the function will skip over it by accident. (Note that once the first image is found, the function starts considering comments as well - it is only in the first case that we have an issue). The reason that I decided to make it skip over looking at comments before the first match is that, in the case where there are hundreds of images before the first match, I might have to unnecessarily search through 1000s of comments looking for the first matching one. If I had more time, I would add some "look-back" functionality, which would backtrack from the first matching image and see if there were any prior images where the comment times matched.

Lastly, I would like to improve the API by adding some asynchronous API calls. Right now, the app "gets more data when it needs it". If the users requests page 4 of a collection's cards, but those cards are not stored in the database, then the app fetches the next page (which slows down the user while they wait for Instagram's API to responsd). It would be great if we could always prepeare data for one or two pages in advance, as it would make the frontend experience feel a lot more fluid.

If I had even more time, I would focus on making the backend as stable as possible by improving the fault tolerence and security.

## Conclusion

Collectogram was an interesting project to work on, and I had a great time building it up. While there are lots of areas for improvement, I'm very happy with the current state of the application, and I feel that it is a good reflection of my programming abilities.

If you would like to learn more about the development of Collectogram, please check out my "[Development Walkthrough](https://mackie.io/posts/collectogram_part_1_-_design.html)". I provide some insight into my design considerations, and show how testing helped drive parts of the development process.
<br>
If you have any other questions, you can always email me at: [scott@mackie.io](scott@mackie.io).
