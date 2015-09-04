<cfcomponent displayname="TankSpot" output="false" extends="com.hanzo.cf.Kathune.KathuneTentacle" implements="com.hanzo.cf.Kathune.interface.ITentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.tentacle.TankSpot.TankSpotTentacle" access="public" output="false">
		<cfargument name="settings" type="struct" required="true" />
		
		<!--- example
		
		exclude 32613
		
		[^>]+t=([0-9]+)[^>]+

		<a href="http://www.tankspot.com/forums/f94/40441-looking-horde-guild.html" id="thread_title_40441">Looking a horde guild.</a>
		
		<div id="post_message_113118">
		 --->
		
		<cfset setForumURL('http://www.tankspot.com/forums/guild-recruitment/') /> <!--- with tank spot this trailing / MUST exist --->
		<cfset setThreadURL('http://www.tankspot.com/forums/f94') />
		<cfset setSource('TankSpot - Guild Recruitment') />
		<cfset setLinkRegularExpression('<a href="http://www.tankspot.com/forums/f94/([^>]+\.html)" id="thread_title_[0-9]+[^32613]">([^<]+)</a>') />
		<cfset setBodyRegularExpression('<div id="post_message_[0-9]+">(.+?)</div>') />		
		
		<cfreturn super.init( arguments.settings ) />
	</cffunction>
	
	<!--- overridden for tankspot --->
	<cffunction name="getThreadByHook" returntype="string" access="public" output="false">
		<cfargument name="hook" type="string" required="true" />
		
		<cfreturn getThreadURL() & '/' & arguments.hook />
	</cffunction>	
	
	<cffunction name="TitleToPostStruct" returntype="struct" output="false" access="public">
		<cfargument name="txt" type="string" required="true" />
		
		<cfreturn super.TitleToPostStruct( arguments.txt ) />
	</cffunction>	

</cfcomponent>