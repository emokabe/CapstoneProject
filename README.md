# Emily's Capstone Project

## Description

This iOS app is a course collaboration tool where students can interact with each other's posts about course-related topics. Many of my core features will revolve around the Facebook SDK.

To log into my app, the user will need to first log into their Facebook account or sign up for a new Facebook account to log in with. Upon login, the user will see a feed of posts for the current course that they are viewing. All posts to the app are stored in a common Facebook Group, where each post is mapped to a course through a database. In the database, there will be a mapping between each post id (obtained through the Facebook API) and a course id, where each course is assigned to a unique course id.

The user is able to switch between viewing different courses on their app, and the course that they had been viewing during their last session will be stored locally so that its feed appears upon login. Internally, all posts in the Facebook group that are mapped to the corresponding course id will be displayed.

The user is able to compose a post in the selected course. Composing a post will cause a new post to pop up on the feed, and will also publish the post on the common Facebook group mentioned previously. The new post's id will be mapped to the course id.

Finally, there will be a view for searching through posts that the user already read using a search bar. Before searching, the user will see a list of "recommended" posts, where posts that the user is most likely to choose will appear higher in the table. The sorting order of this initial set of posts will be determined by factors such as the author whose posts the user is most likely to read, or the time frame from which the user is likely to read posts. When searching, the user is able to filter their posts by choosing a category (title, message, etc.) to filter by. Clicking on a post in this search view will take the user to the details view for the post.


## Wireframe

<a href="https://ibb.co/RzXBCf8"><img src="https://i.ibb.co/RzXBCf8/Updated-wireframe.jpg" alt="Updated-wireframe" border="0"></a>


## MVP Features
- [X] Sign up with a new user profile through Facebook
- [X] Log in/out of app using Facebook credentials 
- [X] Animations – fading in/out when switching views
- [ ] An external library to polish UI
- [X] Select a course from a list to view its feed
- [X] Display the user feed
- [X] Upon login, display the feed for course that was viewed last during previous login session
- [X] Compose a post and update the corresponding course feed
- [X] Pinch gesture on screen to change text size
- [X] Comment on posts by mapping answers to post-id by posting them in the same Facebook post with delimiters
- [X] Dynamically fetch posts by date range to prevent fetching too many posts at a time
- [X] Cache posts to decrease number of fetches and increase efficiency
- [X] Search through already-read posts using a search bar, and click any post to view its details
- [ ] Sort posts in search view by order of how likely the user is to read each post


## Possible Stretch Features
- [ ] Liking and unliking posts
- [X] If a valid session already exists, take the user straight to the home feed without logging in
- [ ] Selecting posts to put on a personal ToDo list
- [ ] Let user search for new courses to join, so that not all courses in the database are automatically added to the user's course list
- [ ] A gamification of the app


## Edit Log

----- Thursday, July 14 -----
- Fixed lingering bugs with displaying courses on the user feed
    - [Link to update that mentions this change](https://fb.workplace.com/permalink.php?story_fbid=pfbid0TjSPX2d2mPZRrf3LxtMgoJYzJyWQ2cM2YprRs4xQtpYt4sjwC9NqNzXpM2otWzW3l&id=100081792760931)
    - One of the issues was that after composing a post, the post was not displayed immediately on the timeline.
        - The problem was that I forgot to write the prepareForSegue method; not setting the ComposeViewController's delegate as the QuestionFeedViewController was the main issue.
        - The dates and timestamps also show up now; this bug was due to using the incorrect input format for the date formatter.


----- Friday, July 15 -----
- Added feature to display list of courses under a viewcontroller in a separate tab bar
    - [Link to in-progress view of courses](https://fb.workplace.com/permalink.php?story_fbid=pfbid0TjSPX2d2mPZRrf3LxtMgoJYzJyWQ2cM2YprRs4xQtpYt4sjwC9NqNzXpM2otWzW3l&id=100081792760931)
    - I use Parse to store Course objects, where each Course has a unique course_id. Each post on the Facebook Group will be mapped to a course_id, so that each course will have posts that are only affiliated with that course.


----- Monday, July 18 -----
- Added test animation for filling screen with objects as the user interacts more with the app
    - [Link to Workplace Update with video demo](https://fb.workplace.com/permalink.php?story_fbid=pfbid02iB5YAGYFw1f9ZFE7mVKYgErcukmVHnrwXaQh5NAKPKuwztdTH84BJ7XyAZJBF59jl&id=100081792760931)
    

----- Tuesday, July 19 -----
- Attempted to add a functionality to map questions to course-id using a Parse database, but realized that calling the Parse API many times was inefficient
- Decided to add information to be mapped to the post message on Facebook itself, as discussed next

    
----- Wednesday, July 20 -----
- Added the ability for users to add a title to their post
    - Added title/body/course-ids mapping all on one Facebook post so that the post feed now displays the posts with corresponding titles for the selected course
    - Used a delimiter (/0) between each section with newlines to make the text legible on Facebook
        - The final format I stored on Facebook is: "QuestionTitle/0\n\nQuestionBody/0\n\nCourseTag1,CourseTag2"
    - [Link to Workplace Update](https://fb.workplace.com/permalink.php?story_fbid=pfbid0HJXP2vRaD1isWBe84RutPajWnpHs2r7ai4Lch689wqdBVq2AHsNmaTnba3u3a2efl&id=100081792760931) with in-between process
    - [Link to Github PR](https://github.com/emokabe/CapstoneProject/pull/16)
    
- Added UI for viewing post details and commenting on a post
    - Can click on any post in the feed to see the text components that will be filled with the corresponding information
    - Can click on "Answer this Question" button to see a view for posting an answer, with a cancel button that returns back to the details view
    
    
----- Thursday, July 21 -----
- Added functionality for selecting a course from a list of courses, saving the course id locally, then automatically switching back to the home question feed
    - [Link to Workplace Update](https://fb.workplace.com/permalink.php?story_fbid=pfbid0BjGGEjKykavLmzrngb1exZiawXHuMGdJ54iWaoRaKsCGF3Vajq7UHPkY7RM4fvm2l&id=100081792760931)
    
- Filled in the details in the post details view so that clicking on a post in the feed will lead to a view with the selected post's details
    - For both this functionality and the next one, a segue is used to pass data between view controllers
    - Have yet to add the profile picture of the poster -- this will require additional calls to the API, and API-calling methods will change with the implementation of dynamic fetching and caching
- Added the UI of the view for commenting on a post
    - Displays the question title/body and username of poster on the comment-composing view to make it easier to respond
    
    
----- Monday, July 25 -----
- Combined PR #16 (displaying the courses for a hard-coded course id) and #19 (selecting a course) so that users can select a course, then be lead immediately to the corresponding feed
    - [Link to PR with video demo](https://github.com/emokabe/CapstoneProject/pull/21)
- Created API call for posting a comment to a post
    - Calls the Facebook API and posts the comment as a Group post
    - Post has the post-id of the post it is responding to appended to it
    - [Link to PR with video demo](https://github.com/emokabe/CapstoneProject/pull/22)


----- Tuesday, July 26 -----
- Added dynamic fetching of posts
    - First, the app fetches posts from two days ago (a small number for the sake of testing) until the end of today.
    - It sorts through all of the fetched posts and keeps the ones with the correct course id.
    - If there aren't enough posts to be displayed, fetch a second two-day batch with timeframe ending two days ago from today
    - Keep fetching until there are enough posts to be displayed, or there are no more posts
    - [Link to Workplace Update](https://fb.workplace.com/permalink.php?story_fbid=pfbid02oREVd3sbqPLdoQPDTSp462qyRsLGFRxmj8JqDhbt69sb95uKCiA9LoT8wDZzWcyyl&id=100081792760931)
    
----- Wednesday, July 27 -----
- Implemented caching of posts
    - Get posts and comments using the dynamic fetching algorithm from 7/26
    - Cache all posts and comments as Post objects in an array
    - When switching courses and loading a new feed, clear cache and refetch/recache posts to prevent duplicates
- Added pinch gesture to resize post text size in details view
    - Pinch out to increase post detail body text size, pinch in to decrease text size 
    - Cap text size with maximum and minimum to prevent text from getting too large or small
    - See [this PR](https://github.com/emokabe/CapstoneProject/pull/26)


----- Thursday, July 28 -----
- Added commenting functionality for all posts in feed
    - Use caching functionality from 7/27 to access all cached Post object and filter comments
    - Display comments as a table view in the details view that users can scroll through
    - See [this PR](https://github.com/emokabe/CapstoneProject/pull/27) for a video demo
    - See [this status update](https://fb.workplace.com/permalink.php?story_fbid=pfbid0225M5UnJJxu6pxbC6ktBBeTskSAvBqQnyH88UCiUtkjJPrraPG3hAeLubBy56da8Nl&id=100081792760931) to see a bug I fixed from 6/27
    - TODO: fix UI so that the table view does not overlap with tab bar, and cells don't cut off at the edge


----- Friday, July 29 -----
- Added view with search bar for searching through posts
    - See [this status update](https://fb.workplace.com/permalink.php?story_fbid=pfbid0225M5UnJJxu6pxbC6ktBBeTskSAvBqQnyH88UCiUtkjJPrraPG3hAeLubBy56da8Nl&id=100081792760931) for what the UI for the list of posts will look like
- Added saving posts to Parse database
    - Whenever the user clicks on a post in details view, the post is saved in Parse
    - The post and its information is saved as a object with a name that contains its user-id 
        - e.g. for a user with user-id = 12345, the post will be stored as an object called "user12345"
        - This makes mapping users to viewed posts easier, because we won't have to save posts and map each post to a user, then query all posts with a particular user-id field


----- Monday, August 1 -----
- Added searching for posts using the search bar
    - Before searching, the table under the search bar shows all posts that have been recently viewed
    - When the user types a keyword into the search bar, the posts in the table filter so that only posts with messages containing the keyword remain
    - Pressing the cancel button at the top right removes the filter and makes the cancel button disappear
    - See [this PR](https://github.com/emokabe/CapstoneProject/pull/30)
- Added symbols to tab bar controller and other buttons
    - Used SFSymbols to find symbols for buttons that enhance user experience
    - See [this PR](https://github.com/emokabe/CapstoneProject/pull/31)


----- Tuesday, August 2 -----
- Added infinite scroll for post feed
    - If the user scrolls to the bottom of the feed, fetch more posts, if available, to fill up the bottom of the feed
    - This strategy ensures that the number of times we need to fetch from the Facebook API is limited
    - Only posts that were loaded in the first batch are cached, so there is a limit to how many posts can be cached at once
    - For comments in details view
        - If the creation date of the selected post is earlier than the earliest cached post date, fetch posts within this time interval to get comments
    - See [this PR](https://github.com/emokabe/CapstoneProject/pull/32)
- Added switch to details
    - Tapping on a post in the search view automatically leads the user to the details view for the post
    - Comments are not correctly displayed yet in the details view -- see [this status update](https://fb.workplace.com/permalink.php?story_fbid=pfbid037hfiSYPLYGPS5jAwa1h2RkyJ9ZdaC3953dqMbBbKXx4ta12As8tQzjQDosJ6u5msl&id=100081792760931) for blockers that I faced while implementing this functionality
    - See [this PR](https://github.com/emokabe/CapstoneProject/pull/33)


----- Wednesday, August 3 -----
- Added filtering posts in the search view by category
    - When the user tap-and-holds on the search bar, a context menu pops up for the user to select categories: all text (default), message, title, name, and course.
    - Once a category is selected (if not, the default filter is used), typing a keyword into the search bar will filter by the selected category
- Fixed comments for switch to details
    - As before, whenever the user taps a post in the search view, the user is lead to its details -- now, the post's comments are correctly displayed
    - In order to do this, I needed to share the same APIManager object so that I could share the same cache in the APIManager class among all view controllers in the tab bar
    - I created a singleton APIManager class for the above purpose
- Added auto layout and other UI fixes
    - Fixed autolayout of the details view controller, composing post view controller, and composing comment view controller
    - Changed navigation title of the home feed so that the current course name is also displayed


 
## Credits

- Facebook SDK


## License

Emily Okabe, 2022
