<cfcomponent output="false" extends="ApplicationProxy">

	<cffunction name="onRequestStart" output="false">

		<cfset StructDelete( this, "onRequest" ) />

		<cfset StructDelete( this, "onRequestEnd" ) />
		
		<cfset StructDelete( variables, "onRequest" ) />

		<cfset StructDelete( variables, "onRequestEnd" ) />	
		
		<cfcontent type="text/xml">	
	
	</cffunction>

</cfcomponent>