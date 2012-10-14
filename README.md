NOTICE
======
Cocoa Tent Client, and especially the library that powers it, is under heavy development.  If you want to try Cocoa Tent Client I encourage you to download a binary version that will be in some working state.  You can find binaries at https://github.com/dustinrue/CocoaTentClient/downloads.

Cocoa Tent Client
=================
Cocoa Tent Client is very simple application that exists to assist in the building of an Objective-C based
http://tent.io client library.  When the library is in a more finished state it will be broken out
from this app so that others can make use of it.  Currently Cocoa Tent Client works only on Mountain Lion.

The app currently provides very basic support for interacting with a tent.io version 0.1.0 server.  This includes tent.is and tentd as of this writing (10/4/2012).

If you want to hack on this client feel free.  Simply compile and run, enter your entity URL (for example, https://dustinrue.tent.is) and click save, then click the register app button.  The app will direct you to your account where you sign in and authorize the app.  Cocoa Tent Client should then start showing you your personal timeline.

Changing your username
======================
Currently this client will save whatever you enter as your entity url and then prevent you from changing.  To change it, you must delete your preferences file, enter in a new value and then register the app again.  

What is exposed in the client
=============================
Currently this client will expost to you:

* Automatically perform discovery (find the proper API root for a given tent entity url)
* Register itself with your tent.is or personal tentd server (and should work with any custom tent.io version 0.1.0 compliant server)
* Follow users
* Read your personal timeline
* Post messages
* Reply
* Repost
* Delete

Cocoa Tent Client will issue a simple notification when new items are received.

What works but isn't exposed in the client
==========================================
The following exists in the library but isn't exposed in the client:

* Display profile
* Update profile

What hasn't been implemented at all yet
=======================================
The following hasn't been implemented at all yet, but most of the items already have classes to support the operations

* Unfollow users

Support
=======
If you have issues with this client, please post them to the issues link located above.  You can also find me at dustinrue.tent.is, @dustinrue on twitter

Goals of the Cocoa Tent library
===============================
My top goal for the Cocoa Tent library is to provide fellow developers with an open, flexibly licensed library that hides the complexities of the Tent.io protocol doing all of the heavy lifting while allowing portions of it to be overridden when needed.  The library will work under both OS X and iOS and will expose all post types modeled as simple objects with the correct properties and methods to ensure that posts are built in compliance with the tent.io protocol.  The Cocoa Tent library should also be extensible to allow a developer to define new post types without worrying about how the new post type is communicated to the server.

Here is a list of some of the things the library can currently perform:

* Can easily perform tent entity server discovery against "Link:" headers - http://blog.dustinrue.com/archives/1016
* Handle the entire oAuth process with minimal client site requirements
* All post types are modeled and can pushed to the server via a single method.  Post types currently tested include status, reply (actually just a status with mention metadata), repost and delete.
* The status post type will generate proper reply mention data and reply text for a given post
* Properly fetch repost information for a given repost
* Retrieves most recent posts maintaining an internal position pointer

