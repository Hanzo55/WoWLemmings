<cfcomponent displayname="PvETentacle" output="false" extends="com.hanzo.cf.Kathune.tentacle.MMOChampion.Europe.EuropeTentacle" implements="com.hanzo.cf.Kathune.interface.ITentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.tentacle.MMOChampion.Europe.PvETentacle" access="public" output="false">
		<cfargument name="settings" type="struct" required="true" />
		
		<cfset setForumURL('http://www.mmo-champion.com/forums/261-Guild-Recruitment-EU-English-PvE-Servers') />
		<cfset setSource('MMO-Champion.com -> Guild Recruitment -> EU-English PvE Servers') />
		
		<cfreturn super.init( arguments.settings ) />
	</cffunction>
	
	<cffunction name="CreatePostObjectFromQueryRow" returntype="com.hanzo.cf.Kathune.Post" access="public" output="false">
		<cfargument name="dataQuery" type="query" required="true" >
		<cfargument name="row" type="numeric" required="true" />

		<cfset var postObject = super.CreatePostObjectFromQueryRow( arguments.dataQuery, arguments.row ) />

		<cfset postObject.setIsPvE( true ) />
		
		<cfreturn postObject />
	</cffunction>
	
</cfcomponent>