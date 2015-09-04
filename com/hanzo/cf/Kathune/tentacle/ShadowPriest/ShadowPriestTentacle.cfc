<cfcomponent displayname="ShadowPriest" output="false" extends="com.hanzo.cf.Kathune.KathuneTentacle" implements="com.hanzo.cf.Kathune.interface.ITentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.tentacle.ShadowPriest.ShadowPriestTentacle" access="public" output="false">
		<cfargument name="settings" type="struct" required="true" />
		
		<cfset setForumURL('http://www.shadowpriest.com/viewforum.php?f=45') />
		<cfset setThreadURL('http://www.shadowpriest.com/viewtopic.php?f=45') />
		<cfset setHook('t') />
		<cfset setSource('shadowpriest.com - Guild Recruitment') />
		<cfset setLinkRegularExpression('<a title="[^>]+" href="[^>]+t=([0-9]+)[^>]+" class="topictitle">([^<]+)</a>') />
		<cfset setBodyRegularExpression('<div class="postbody">(.+?)</div>') />		

		<cfreturn super.init( arguments.settings ) />
	</cffunction>
	
	<cffunction name="TitleToPostStruct" returntype="struct" output="false" access="public">
		<cfargument name="txt" type="string" required="true" />
		
		<cfreturn super.TitleToPostStruct( arguments.txt ) />
	</cffunction>
	
</cfcomponent>