## Bouncer plugin for CFWheels

Alexander Sante 

If you have questions, feel free to email me: alexandersante@gmail.com

## Installation

- Place the plugin's zip file "bouncer-x.x.zip" in your "/plugins" directory.  CFWheels will automatically unzip the contents into its own folder.

- Create a global function called "currentUser()" in "/events/functions.cfm" that will return the current user's model object.

- Create a private method in your user model called "_configureAbilities".  That function needs to be called when the model is initialized.  You can do this by calling
"<cfset afterInitialization(methods='_configureAbilities')>" in your model's init method.  

- Define abilities inside the "_configureAbilities()" function.  Like so:

	<cfset ableTo("READ", "Post")>
	<cfset ableTo("WRITE", "Comment")>

- Add "isActionAllowed" filter to the base controller.  This assumes all of your controllers extend a base controller (ie: 'extends="controller.Controller"')

	<cfset filters(through="isActionAllowed", type="before")>

## Usage

Once the plugin is installed, and all permissions have been defined, you are now ready to make use of Bouncer in your views and controllers.  Let's say you have a series of links to be displayed to the user.  
	
	<a href="/users/1">Show User</a>
	<a href="/users/1/edit">Edit User</a>

Showing the users details in this case does not require additional permissions.  However, editing a user details does require additional permissions.  Wrap the elements with an ability check.

	<a href="/users/1">Show User</a>

	<cfif currentUser().can("WRITE","USER")>
		<a href="/users/1/edit">Edit User</a>
	</cfif>

This permission is also automatically enforced on controller actions.  So even if I copy and paste the url into the browser address bar, I will not be displayed the user edit screen unless I have the permission.

Available permissions are: READ, WRITE, MANAGE, ALL

READ: The user can only view a record
WRITE: The user can view and modify a record
MANAGE: The user can view, modify, and even delete a record
ALL: No restrictions
