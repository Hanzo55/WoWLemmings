<cfcomponent displayname="BigRedKittyTentacle" output="false" extends="com.hanzo.cf.Kathune.KathuneTentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.tentacle.BigRedKitty.BigRedKittyTentacle" access="public" output="false">
		<cfargument name="settings" type="struct" required="true" />
		
		<!--- BigRedKitty is the same as MMOChampion, rule-wise --->
		
		<cfset setSource('The BigRedKitty Forums - Guilds') />
		<cfset setHook('topic')>
		<cfset setForumURL('http://www.bigredkitty.net/forums/index.php?board=17.0') />
		<cfset setThreadURL('http://www.bigredkitty.net/forums/index.php') />		
		<cfset setLinkRegularExpression('<span id="msg_[0-9]+"><a href="http://www.bigredkitty.net/forums/index.php\?PHPSESSID=[^&]+&amp;topic=([^>]+)">([^<]+)</a></span>') />
		<cfset setBodyRegularExpression('<div class="post">(.+?)</div>') />		
		
		<cfreturn super.init( arguments.settings ) />
	</cffunction>

	<cffunction name="TitleToPostStruct" returntype="struct" output="false" access="public">
		<cfargument name="txt" type="string" required="true" />
		
		<cfreturn super.TitleToPostStruct(arguments.txt) />
	</cffunction>

</cfcomponent>