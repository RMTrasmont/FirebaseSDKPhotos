
Camera and Cloud

Concept:
Create an app that lets users post photos to ‘the cloud’ and lets users see any/all photos that have been posted. Users should be able to leave comments and like photos that have been posted. Imagine a simpler version of Instagram—but everyone is the same user (or there are no users—same thing, ultimately).

Assignment:

1. Read the Tab Bar Controller documentation
2. Install the Firebase SDK. Read the getting started documentation about Firebase Storage.
3. Upload a photo to Firebase storage and get a reference to it.

4. Design a data model for your app and how it will be stored as JSON (including a reference to the file)
5. Using the Firebase Database, Firebase Storage, Firebase Authentication SDK make an HTTP POST with metadata about the image you uploaded earlier (including the reference to it). Metadata is all the information related to the image (but not the actual image) like image name, date created, file type, caption, etc.
6. Get the data from the API and fetch the image. Prove to yourself that you can display these things in a view.
7. Create API requests to add comments and likes.
8. Create the interface of the app using a Tab Bar Controller for the overall navigation of the app.
a. One tab will house a navigation controller.
i. The first view in the nav controller is a Collection View to display image thumbnails
ii. When a thumbnail is selected it should open a detail view for that image (still in the same tab, but a new view in the nav controller), showing a larger version of the image, a like button, number of likes and a comments section (using a textfield for new comment, and table view for existing comments—reply feature is NOT required). Likes and comments should
b. The second tab, when opened, should determine if the device has a camera or not. If so it should offer the user a choice of whether to display the camera or image library to select an image for upload. If no camera is available, it should simply show the image library.
9. Integrate all the parts.

Completion Checklist:
• The app should have multiple tabs (UITabBarController)
• User can take or select an image using UIImagePickerController
• The user should be able to post a photo to Firebase Storage using the Firebase
SDK
• Metadata about user pictures (e.g. title, author, comments, and number of likes) should be saved in Firebase Database using the Firebase RESTful API
• Photos from Firebase should be displayed in a UICollectionView
• All networking should be done using AFNetworking or AlamoFire (Swift)
• (optional) The app should have some sense of users (this can be done without
authentication)
• (optional) The app should have pagination (i.e. it shouldn’t download all of the
images in Firebase at once, it should get some, and then get more when the user has seen all of the downloaded ones.
