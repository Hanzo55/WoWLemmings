<cfcomponent displayname="Alliance" output="false" extends="com.hanzo.cf.Kathune.tentacle.WorldOfRaids.Europe.EuropeTentacle" implements="com.hanzo.cf.Kathune.interface.ITentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.tentacle.WorldOfRaids.Europe.AllianceTentacle" access="public" output="false">
		<cfargument name="settings" type="struct" required="true" />
		
		<cfset setForumURL('http://www.worldofraids.com/forums/forumdisplay.php?f=30') />
		<cfset setSource('World of Raids Forums -> EN-Alliance') />
		
		<cfreturn super.init(arguments.settings) />
	</cffunction>
	
	<cffunction name="CreatePostObjectFromQueryRow" returntype="com.hanzo.cf.Kathune.Post" access="public" output="false">
		<cfargument name="dataQuery" type="query" required="true" >
		<cfargument name="row" type="numeric" required="true" />

		<cfset var postObject = super.CreatePostObjectFromQueryRow( arguments.dataQuery, arguments.row ) />

		<cfset postObject.setIsAlliance( true ) />
		
		<cfreturn postObject />
	</cffunction>
	
</cfcomponent>