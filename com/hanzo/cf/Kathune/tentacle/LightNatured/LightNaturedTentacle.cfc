<cfcomponent displayname="LightNatured" output="false" extends="com.hanzo.cf.Kathune.KathuneTentacle" implements="com.hanzo.cf.Kathune.interface.ITentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.tentacle.LightNatured.LightNaturedTentacle" access="public" output="false">
		<cfargument name="settings" type="struct" required="true" />
		
		<cfset setForumURL('http://www.lightnatured.com/forum/viewforum.php?f=23') />
		<cfset setThreadURL('http://www.lightnatured.com/forum/viewtopic.php?f=23') />
		<cfset setHook('t') />
		<cfset setSource('LightNatured.com - Guild/Arena Recruitment') />
		<cfset setLinkRegularExpression('<a title="[^>]+" href="[^>]+t=([0-9]+)[^>]+" class="topictitle">([^<]+)</a>') />
		<cfset setBodyRegularExpression('<div class="postbody">(.+?)</div>') />		

		<cfreturn super.init( arguments.settings ) />
	</cffunction>
	
	<cffunction name="TitleToPostStruct" returntype="struct" output="false" access="public">
		<cfargument name="txt" type="string" required="true" />
		
		<cfreturn super.TitleToPostStruct( arguments.txt ) />
	</cffunction>
	
</cfcomponent>