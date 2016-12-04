TBC Chat - A Snapchat Clone
===========================
This is a Snapchat clone running on iOS, powered by Firebase. A uni project developed by [@Changchang Wang](https://github.com/Jeff1943), [@Hailun Tian](https://github.com/HelenTian), and [@Boqin Hu](https://github.com/Dirtymac). Just for learning and practicing.

Screenshots
-----------
<img src="https://raw.githubusercontent.com/Jeff1943/simple-snapchat/master/images/swipe.gif" width="200">
<img src="https://raw.githubusercontent.com/Jeff1943/simple-snapchat/master/images/Login.png" width="200"> <img src="https://raw.githubusercontent.com/Jeff1943/simple-snapchat/master/images/Camera.png" width="200">
<img src="https://raw.githubusercontent.com/Jeff1943/simple-snapchat/master/images/Chat.png" width="200">
<img src="https://raw.githubusercontent.com/Jeff1943/simple-snapchat/master/images/Send.png" width="200">
<img src="https://raw.githubusercontent.com/Jeff1943/simple-snapchat/master/images/Memories.png" width="200">
<img src="https://raw.githubusercontent.com/Jeff1943/simple-snapchat/master/images/Stories.png" width="200">
<img src="https://raw.githubusercontent.com/Jeff1943/simple-snapchat/master/images/Discover.png" width="200">

Features
-------------
* User authentication
* Fluid navigation between all screens using swipe gestures
* Camera screen – take a photo, flash option, back/front camera
* Snap edit – cancel, add emoji, text, set timer, save, store as memory
* Add friends via SMS/QR code/username
* Chat - Live chat with friends, show friendship
* Chat - Send text and photo
* Chat - Viewing rules (timeout) enforced
* Chat - Share location
* Memories - Photos from snaps and camera roll
* Memories - Share with my friends
* Memories - Send to my stories
* Stories - My stories and friends' stories
* Discover - Display suggested public stories (mainly using RSS feed)

Developing Environment
----------------------
* Xcode 8
* Swift 3
* iOS 9.3+
* Firebase

Installation
------------
1. Make an account at [Firebase](https://firebase.google.com/) and perform some very basic [setup](https://firebase.google.com/docs/ios/setup). (the CocoaPods Frameworks and Libraries are already included in the repo)
2. Download *GoogleService-Info.plist* and drag it into the project<br>
<img src="https://raw.githubusercontent.com/Jeff1943/simple-snapchat/master/images/Google%20plist.png" width="200">
3. Run the project on your device. Sometimes you need to press cmd + shift + k to clean the project (not sure why).
*Don't run it on your simulator. It will crash since camera cannot be loaded. This problem only exit on iOS 10

