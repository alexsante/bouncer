<cfcomponent>

	<cfscript>
		VARIABLES.abilities = {};
		VARIABLES.incopacities = {};
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="any">
	
		<cfset var loc = {}>

		<!--- Version stamp --->
		<cfset this.version = "0.1,1.1.8">

		<cfreturn this/>	
	</cffunction>

	<cffunction name="ableTo" access="public" output="false" returntype="void" mixin="model">
		<cfargument name="permission" type="string" required="true" hint="read,write,delete,manage">
		<cfargument name="model" type="any" required="true" hint="Name of the model class or all">

		<cfset var loc = {}>

		<cfif isObject(ARGUMENTS.model)>
			
			<cfset loc.objectMetaData = getMetaData(ARGUMENTS.model)>
			<cfset VARIABLES.abilities["#loc.objectMetaData.name#"] = ARGUMENTS.permission>

		<cfelse>

			<cfset VARIABLES.abilities["#ARGUMENTS.model#"] = ARGUMENTS.permission>

		</cfif>
		
	</cffunction>

	<cffunction name="notAbleTo" access="public" output="false" returntype="void" mixin="model">
		<cfargument name="permission" type="string" required="true" hint="read,write,delete,manage">
		<cfargument name="model" type="any" required="true" hint="Name of the model class or all">

		<cfset var loc = {}>

		<cfif isObject(ARGUMENTS.model)>
			
			<cfset loc.objectMetaData = getMetaData(ARGUMENTS.model)>
			<cfset VARIABLES.incopacities["#loc.objectMetaData.name#"] = ARGUMENTS.permission>

		<cfelse>

			<cfset VARIABLES.incopacities["#ARGUMENTS.model#"] = ARGUMENTS.permission>

		</cfif>
	
	</cffunction>	

	<cffunction name="can" access="public" output="false" returntype="any" mixin="model">
		<cfargument name="permission" type="string" required="true" hint="read,write,delete,manage">
		<cfargument name="model" type="any" required="true" hint="Name of the model class">	

		<!--- By default, every request get's bounced --->
		<cfset var hasAbility = false>

		<!--- First check if the user has full access to all models --->
		<cfif structKeyExists(VARIABLES.abilities, "ALL") AND VARIABLES.abilities["ALL"] EQ "Manage">
			<cfset hasAbility = true>
			<!--- No need to keep checking permissions.  Exit out --->
			<cfreturn hasAbility>
		</cfif>

		<!--- Check if the user has the specific permission requested on all models --->
		<cfif structKeyExists(VARIABLES.abilities, "ALL") AND VARIABLES.abilities["ALL"] EQ ARGUMENTS.permission>
			<cfset hasAbility = true>
			<!--- No need to keep checking permissions.  Exit out --->
			<cfreturn hasAbility>
		</cfif>

		<!--- If the model being checked does not exist in the models folder, grand the permission as it is most likely not of any concern --->
		<cfif modelExist(ARGUMENTS.model) EQ FALSE>
			<cfset hasAbility = true>
		</cfif>

		<!--- No global abilities have been defined.  Check specific permissions --->
		<cfswitch expression="#ARGUMENTS.permission#">
			
			<cfcase value="READ">
					
				<cfif structKeyExists(VARIABLES.abilities, ARGUMENTS.model) AND ListContainsNoCase("Read,Write,Manage", VARIABLES.abilities["#ARGUMENTS.model#"])>
					<cfset hasAbility = true>
				</cfif>

			</cfcase>

			<cfcase value="Write">
				<cfif structKeyExists(VARIABLES.abilities, ARGUMENTS.model) AND ListContainsNoCase("Write,Manage", VARIABLES.abilities["#ARGUMENTS.model#"])>
					<cfset hasAbility = true>
				</cfif>
			</cfcase>

			<cfcase value="Delete">
				<cfif structKeyExists(VARIABLES.abilities, ARGUMENTS.model) AND ListContainsNoCase("Delete,Manage", VARIABLES.abilities["#ARGUMENTS.model#"])>
					<cfset hasAbility = true>
				</cfif>
			</cfcase>

		</cfswitch>

		<cfreturn hasAbility>
	</cffunction>

	<cffunction name="isActionAllowed" access="public" output="false" returntype="any" mixin="controller">
	
		<cfset var loc = {}>


		<!--- Singularize the controller name. --->
		<cfset loc.model = singularize(PARAMS.controller)>

		<!--- Action being performed --->
		<cfset loc.action = PARAMS.action>

		<cfif listContainsNoCase("list,show,index", loc.action)>
			<cfset loc.action = "READ">
		</cfif>

		<cfif listContainsNoCase("new,update,create", loc.action)>
			<cfset loc.action = "WRITE">
		</cfif>

		<cfif loc.action EQ "edit">
			<cfset loc.action = "UPDATE">
		</cfif>

		<cfif currentUser().can(loc.action, loc.model) EQ FALSE AND PARAMS.route NEQ "Root">
			<!--- pfft! Access denied! Bounce em! --->
			<cfset flashInsert(error="You do not have access to perform that action.")>
			<cfset redirectTo(route="root")>
		</cfif>

	</cffunction>

	<cffunction name="listAbilities" access="public" output="false" returntype="any" mixin="model">
		<cfreturn VARIABLES.abilities>	
	</cffunction>

	<cffunction name="listIncopacities" access="public" output="false" returntype="any" mixin="model">
		<cfreturn VARIABLES.incopacities>	
	</cffunction>

	<cffunction name="listModels" access="public" output="false" returntype="any" mixin="global">

		<cfset var modelsFound = ArrayNew(1)>
		<!--- Inspect the model folder --->
		<cfif directoryExists(expandPath("/models"))>

			<cfdirectory action="list" directory="#expandPath('/models')#" name="models"/>	

			<cfoutput query="models">
				<!--- TODO: For whatever reason, BillTransStatusCodes does not get sigularized correctly. --->
				<cfset arrayAppend(modelsFound, Singularize(replace(lcase(name),".cfc","")))>
			</cfoutput>

		</cfif>

		<cfreturn modelsFound>	
	</cffunction>

	<cffunction name="modelExist" access="public" output="false" returntype="any">
		<cfargument name="modelToFind" type="string" required="true"/>
		<cfloop array="#listModels()#" index="model">
			<cfif model EQ arguments.modelToFind OR pluralize(model) EQ modelToFind>
				<cfreturn true>
			</cfif>
		</cfloop>

		<cfreturn false>	
	</cffunction>

</cfcomponent>