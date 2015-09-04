<cfcomponent displayname="RP-PvPTentacle" output="false" extends="com.hanzo.cf.Kathune.tentacle.LookingForGuild.Europe.Horde.HordeTentacle" implements="com.hanzo.cf.Kathune.interface.ITentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.tentacle.LookingForGuild.Europe.Horde.RP-PvPTentacle" access="public" output="false">
		<cfargument name="settings" type="struct" required="true" />
		
		<cfset setForumURL('http://www.lookingforguild.net/viewsublist.asp?cid=10003&sid=50006&3id=100031') />
		<cfset setSource('LookingForGuild.net -> Players looking for a guild -> Europe -> Horde -> RP-PvP') />
		
		<cfreturn super.init( arguments.settings ) />
	</cffunction>
	
	<cffunction name="CreatePostObjectFromQueryRow" returntype="com.hanzo.cf.Kathune.Post" access="public" output="false">
		<cfargument name="dataQuery" type="query" required="true" >
		<cfargument name="row" type="numeric" required="true" />

		<cfset var postObject = super.CreatePostObjectFromQueryRow( arguments.dataQuery, arguments.row ) />

		<cfset postObject.setIsPvP( true ) />
		
		<cfreturn postObject />
	</cffunction>
	
</cfcomponent>