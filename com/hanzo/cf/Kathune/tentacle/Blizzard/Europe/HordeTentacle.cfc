<cfcomponent displayname="Horde" output="false" extends="com.hanzo.cf.Kathune.Tentacle.Blizzard.Europe.EuropeTentacle" implements="com.hanzo.cf.Kathune.interface.ITentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.Tentacle.Blizzard.Europe.HordeTentacle" access="public" output="false">
		<cfargument name="settings" type="struct" required="true" />
		
		<cfset setForumURL('http://forums.wow-europe.com/board.html?forumId=9575909') />
		<cfset setSource('World of Warcraft (Europe Forums) -> Guild Recruitment -> Horde') />
		
		<cfreturn super.init(arguments.settings) />
	</cffunction>
	
	<cffunction name="CreatePostObjectFromQueryRow" returntype="com.hanzo.cf.Kathune.Post" access="public" output="false">
		<cfargument name="dataQuery" type="query" required="true" >
		<cfargument name="row" type="numeric" required="true" />

		<cfset var postObject = super.CreatePostObjectFromQueryRow( arguments.dataQuery, arguments.row ) />

		<cfset postObject.setIsAlliance( false ) />
		
		<cfreturn postObject />
	</cffunction>
	
</cfcomponent>