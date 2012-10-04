Cocoa Tent Client
=================
Cocoa Tent Client is very simple application that exists to assist in the building of an Objective-C based
http://tent.io client library.  When the library is in a more finished state it will be broken out
from this app so that others can make use of it.  Currently Cocoa Tent Client works only on Mountain Lion.

The app currently provides very basic support for interacting with a tent.io version 0.1.0 server.  This includes tent.is and tentd as of this writing (10/4/2012).

If you want to hack on this client feel free.  Simply compile and run, enter your entity URL (for example, https://dustinrue.tent.is) and click save, then click the register app button.  The app will direct you to your account where you sign in and authorize the app.  Cocoa Tent Client should then start showing you your personal timeline.

What is exposed in the client
=============================
Currently this client will expost to you:

* Automatically perform discovery (find the proper API root for a given tent entity url)
* Register itself with your tent.is or personal tentd server (and should work with any custom tent.io version 0.1.0 compliant server)
* Follow users
* Read your personal timeline
* Post messages

Cocoa Tent Client will issue a simple notification when new items are received.

What works but isn't exposed in the client
==========================================
The following exists in the library but isn't exposed in the client:

* Display profile
* Update profile

What hasn't been implemented at all yet
=======================================
The following hasn't been implemented at all yet, but most of the items already have classes to support the operations

* Reply
* Repost
* Delete
* Unfollow users

Support
=======
If you have issues with this client, please post them to the issues link located above.  You can also find me at dustinrue.tent.is, @dustinrue on twitter