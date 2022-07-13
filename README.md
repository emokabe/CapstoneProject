# Emily's Capstone Project

## Description

This iOS app is a course collaboration tool where students can interact with each other's posts about course-related topics. Many of my core features will revolve around the Facebook SDK.

To log into my app, the user will need to first log into their Facebook account or sign up for a new Facebook account to log in with through OAuth. Upon login, the user will see a feed of posts for the current course that the user is viewing. All posts to the app are stored in a common Facebook Group, where each post is mapped to a course through a database. In the database, there will be a mapping between each post id (obtained from the Facebook API) and a course id, where each course has a unique course id.

The user is able to switch between viewing different courses on their app, and the course that they had been viewing during their last session will be stored locally so that its feed appears upon login. Internally, all posts in the Facebook group that have the corresponding course id will be displayed.

Finally, the user is able to compose a post in the selected course. Composing a post will cause a new post to pop up on the feed, and will also cause the post to be posted on the corresponding Facebook group as mentioned before.


## Wireframe



## MVP Features
- [X] Sign up with a new user profile through Facebook
- [X] Log in/out of app using Facebook credentials 
- [ ] Fade in/out animation when logging in/out
- [ ] Show a progress SVG (using external library) while the feed loads
- [ ] Select a course from a list to view its feed
- [X] Display the course post feed from the corresponding Facebook group
- [ ] Upon login, display feed for course that was viewed last during last login session
- [X] Compose a post and update the feed and corresponding Facebook group
- [ ] Tap gesture on screen to toggle on-screen keyboard


## Possible Stretch Features
- [ ] Liking and unliking posts
- [ ] Selecting posts to put on a personal ToDo list
- [ ] Comment on posts (Note: This is only possible with Facebook Pages, which may or may not be possible to use depending on permissions.)
- [ ] A gamification of the app (e.g. the user gets points for each interaction they make with the app)
 
 
## Credits

- Facebook SDK


## License

Emily Okabe, 2022
