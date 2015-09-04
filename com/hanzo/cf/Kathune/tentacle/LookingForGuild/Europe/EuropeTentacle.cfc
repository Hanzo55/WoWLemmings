<cfcomponent displayname="Europe" output="false" extends="com.hanzo.cf.Kathune.tentacle.LookingForGuild.LookingForGuildTentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.tentacle.LookingForGuild.Europe.EuropeTentacle" access="private" output="false">
		<cfargument name="settings" type="struct" required="true" />

		<cfset setRegion('EU-EN') />
		
		<cfreturn super.init(arguments.settings) />
	</cffunction>
	
</cfcomponent>