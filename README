## Bouncer plugin for CFWheels

Alexander Sante 

If you have questions, feel free to email me: alexandersante@gmail.com

## Installation

- Place the plugin's zip file "bouncer-x.x.zip" in your "/plugins" directory.  CFWheels will automatically unzip the contents into its own folder.

- This plugin assumed your app has a global function called currentUser().  I'll make this a configurable option later, but for now create a new function called "currentUser" in "/events/functions.cfm".  This function should return the current user's model object.

- Define abilities in the user model

- Enjoy

## About the plugin
What's it all about!?

This plugin inspired by a popular rails gem called CanCan.  It will place a bouncer in each of your controllers.  Each model will also have the capability of using a bouncer, however it's really meant for the user model.  It is up to you, the awesome coder, to implement the logic that will put this bouncer to work.

So basically this is how it works.  

Your model has been decorated with two new methods, ableTo and notAbleTo.  It is up to you to
tell the user model what it is able or not able to do.  For example, let's say a "Guest" user is
currently on the system.  We only want that user to be able to read blog posts, and that's it!

Create a new method in your user model called "_configureAbilities".  You can name this method whatever
you want.  Then associate the method to the call back "afterInitialation" like so:

	<cfset afterInitialization(methods="_configureAbilities")>

This will not be automatically called by cfWheels after the user has been loaded.  You now have to define
each ability.  In this example, we only want to give the user read access to blog posts, so we tell the 
system just that.

	<cfset ableTo("READ", "Post")>
					^         ^
					|		  |	
				{Permission}  |
				              |
					{Singular name of the model}

Now in a view you can wrap certain content with a permission check.  We need to ask the bouncer if we can come in.

(In the view)

	<cfif user.can("WRITE", "POST")>
		<a href="/post/new">Create a new blog post</a>
	</cfif>						

Of course in this case, the bouncer says "No mofo! You can't do that." Or rather .. The link is not rendered.  It's that easy.

"But wait!" you say.  "Can't they just bypass the bouncer via the URL". The answer is no.  Because each controller has it's own bouncer!
Bouncer will check the name of the controller, and assuming you've followed cfWheels convention, it will match it to a model and perform
the same check based on the type of action. For example, "Index,Show" are require "READ" permissions.  "Update,Edit,Create" all require
the "UPDATE" or "MANAGE" permissions and so on.  If the user is rejected, they are sent back to the home page, and a nice little flash message is displayed.