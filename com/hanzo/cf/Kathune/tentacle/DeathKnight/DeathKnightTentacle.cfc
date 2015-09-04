<cfcomponent displayname="DeathKnightTentacle" output="false" extends="com.hanzo.cf.Kathune.KathuneTentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.tentacle.DeathKnight.DeathKnightTentacle" access="public" output="false">
		<cfargument name="settings" type="struct" required="true" />
		
		<!--- DeathKnight.info is the same as MMOChampion, rule-wise --->
		
		<cfset setSource('DeathKnight.info - Looking For Guild / Looking for DK') />		
		<cfset setHook('topic') />
		<cfset setForumURL('http://deathknight.info/forum/index.php?board=49.0') />
		<cfset setThreadURL('http://deathknight.info/forum/index.php') />		
		<cfset setLinkRegularExpression('<span id="msg_[0-9]+"><a href="http://deathknight.info/forum/index.php\?PHPSESSID=[^&]+&amp;topic=([^>]+)">([^<]+)</a></span>') />
		<cfset setBodyRegularExpression('<div class="post">(.+?)</div>') />		
		
		<cfreturn super.init( arguments.settings ) />
	</cffunction>

	<cffunction name="TitleToPostStruct" returntype="struct" output="false" access="public">
		<cfargument name="txt" type="string" required="true" />
		
		<cfreturn super.TitleToPostStruct(arguments.txt) />
	</cffunction>

</cfcomponent>