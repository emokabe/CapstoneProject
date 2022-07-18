# Emily's Capstone Project

## Description

This iOS app is a course collaboration tool where students can interact with each other's posts about course-related topics. Many of my core features will revolve around the Facebook SDK.

To log into my app, the user will need to first log into their Facebook account or sign up for a new Facebook account to log in with. Upon login, the user will see a feed of posts for the current course that they are viewing. All posts to the app are stored in a common Facebook Group, where each post is mapped to a course through a database. In the database, there will be a mapping between each post id (obtained through the Facebook API) and a course id, where each course is assigned to a unique course id.

The user is able to switch between viewing different courses on their app, and the course that they had been viewing during their last session will be stored locally so that its feed appears upon login. Internally, all posts in the Facebook group that are mapped to the corresponding course id will be displayed.

Finally, the user is able to compose a post in the selected course. Composing a post will cause a new post to pop up on the feed, and will also publish the post on the common Facebook group mentioned previously. The new post's id will be mapped to the course id.


## Wireframe

<a href="https://ibb.co/RzXBCf8"><img src="https://i.ibb.co/RzXBCf8/Updated-wireframe.jpg" alt="Updated-wireframe" border="0"></a>


## MVP Features
- [X] Sign up with a new user profile through Facebook
- [X] Log in/out of app using Facebook credentials 
- [ ] Animation of screen filling up with objects (e.g. coins, stars) as user interaction with app increases (a gamification of the app)
- [ ] Show a progress SVG (using external library) while the feed loads
- [ ] Select a course from a list to view its feed
- [X] Display the user feed
- [ ] Upon login, display the feed for course that was viewed last during previous login session
- [X] Compose a post and update the corresponding course feed
- [ ] Tap gesture on screen to toggle on-screen keyboard


## Possible Stretch Features
- [ ] Liking and unliking posts
- [X] If a valid session already exists, take the user straight to the home feed without logging in
- [ ] Selecting posts to put on a personal ToDo list
- [ ] Comment on posts by mapping each Facebook post to an array of comments using a database
- [ ] Let user search for new courses to join, so that not all courses in the database are automatically added to the user's course list


## Edit Log

----- Thursday, July 14 -----



----- Friday, July 15 -----



----- Monday, July 17 -----

 
 
## Credits

- Facebook SDK


## License

Emily Okabe, 2022
