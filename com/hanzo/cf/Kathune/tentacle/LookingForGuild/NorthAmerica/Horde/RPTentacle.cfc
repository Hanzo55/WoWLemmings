<cfcomponent displayname="RPTentacle" output="false" extends="com.hanzo.cf.Kathune.tentacle.LookingForGuild.NorthAmerica.Horde.HordeTentacle" implements="com.hanzo.cf.Kathune.interface.ITentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.tentacle.LookingForGuild.NorthAmerica.Horde.RPTentacle" access="public" output="false">
		<cfargument name="settings" type="struct" required="true" />
		
		<cfset setForumURL('http://www.lookingforguild.net/viewsublist.asp?cid=10001&sid=50003&3id=100010') />
		<cfset setSource('LookingForGuild.net -> Players looking for a guild -> North America -> Horde -> RP') />
		
		<cfreturn super.init( arguments.settings ) />
	</cffunction>
	
	<cffunction name="CreatePostObjectFromQueryRow" returntype="com.hanzo.cf.Kathune.Post" access="public" output="false">
		<cfargument name="dataQuery" type="query" required="true" >
		<cfargument name="row" type="numeric" required="true" />

		<cfset var postObject = super.CreatePostObjectFromQueryRow( arguments.dataQuery, arguments.row ) />

		<cfset postObject.setIsPvP( false ) />
		
		<cfreturn postObject />
	</cffunction>
	
</cfcomponent>