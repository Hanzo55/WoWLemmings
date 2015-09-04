<cfcomponent displayname="MaintankadinTentacle" output="false" extends="com.hanzo.cf.Kathune.KathuneTentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.tentacle.Maintankadin.MaintankadinTentacle" access="public" output="false">
		<cfargument name="settings" type="struct" required="true" />
		
		<cfset setForumURL('http://maintankadin.failsafedesign.com/viewforum.php?f=8') />
		<cfset setThreadURL('http://maintankadin.failsafedesign.com/viewtopic.php?f=8') />
		<cfset setHook('t') />
		<cfset setSource('Maintankadin - Recruitment') />
		<cfset setLinkRegularExpression('<a href="[^>]+t=([0-9]+)[^>]+" class="topictitle">([^<]+)</a>') />
		<cfset setBodyRegularExpression('<div class="content">(.+?)</div>') />					
		
		<cfreturn super.init( arguments.settings ) />
	</cffunction>
	
	<cffunction name="TitleToPostStruct" returntype="struct" output="false" access="public">
		<cfargument name="txt" type="string" required="true" />
		
		<cfreturn super.TitleToPostStruct( arguments.txt ) />
	</cffunction>
	
</cfcomponent>