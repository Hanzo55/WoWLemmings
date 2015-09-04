<cfcomponent output="false">

	<!--- ** 
	Queue.cfc: Specialized Array that allows data to be added at one end, and taken out
	of the other 
	** --->
	
	<!--- ** CONSTRUCTOR ** --->
	
	<cfset variables.queueArray = ArrayNew(1) />

	<!--- ** PUBLIC METHODS ** --->

	<cffunction name="empty" returntype="boolean" access="public" output="false">
	
		<cfreturn ArrayIsEmpty(variables.queueArray) />
	</cffunction>

	<cffunction name="size" returntype="numeric" access="public" output="false">
	
		<cfreturn ArrayLen(variables.queueArray) />
	</cffunction>	

	<cffunction name="push" returntype="void" access="public" output="false">
		<cfargument name="obj" type="any" required="true" />

		<cfset ArrayAppend(variables.queueArray, arguments.obj) />
	</cffunction>

	<cffunction name="pop" returntype="void" access="public" output="false">

		<cfset ArrayDeleteAt(variables.queueArray, 1) />
	</cffunction>

	<cffunction name="front" returntype="any" access="public" output="false">

		<cfreturn variables.queueArray[1] />
	</cffunction>

	<cffunction name="back" returntype="any" access="public" output="false">

		<cfreturn variables.queueArray[ArrayLen(variables.queueArray)] />
	</cffunction>

	<cffunction name="dump" returntype="void" access="public" output="true">
		
		<cfdump var=#variables.queueArray# />
	</cffunction>

</cfcomponent>