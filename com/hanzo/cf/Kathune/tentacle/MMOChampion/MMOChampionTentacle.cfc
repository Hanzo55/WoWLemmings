<cfcomponent displayname="MMOChampionTentacle" output="false" extends="com.hanzo.cf.Kathune.KathuneTentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.tentacle.MMOChampion.MMOChampionTentacle" access="private" output="false">
		<cfargument name="settings" type="struct" required="true" />
		
		<!--- 
		http://www.mmo-champion.com/index.php?topic=16356.0
		<span id="msg_258985"><a href="http://www.mmo-champion.com/index.php?topic=16356.0">[PvP-EST] SERVANTS OF JUSTICE! 4/6 Sunwell - Ranged DPS and more!</a></span>
		<a href="http://www.mmo-champion.com/index.php?PHPSESSID=84632d5eb3fa1364bf81174cf1115d49&amp;topic=16356.0">
		<div class="post">We are a capable new guild on the server and are searching for core members.&nbsp; We have approximately 20 dedicated people and we are missing 5 core raid slots!<br /><br />Gear-wise we are looking for at least t4, just to prove that you have tried out raiding and that you are not some arena fiend.<br /><br />Mostly we are interested in people ready to level quickly and who have a desire to experience the new content as soon as possible with the upcoming expansion.<br /><br />We usually raid around 6:30 server time. Please send me a message with an armory link and I will respond promptly.</div>
		 --->
		
		<!--- this is an abstract base class which contains shared parsing rules for blizzard-forums in general. should not be instanced. --->
		<!--- <cfset setHook('topic')> --->
		<cfset setHook('threads')>
		<cfset setThreadURL('http://www.mmo-champion.com') />		
		<!--- <cfset setLinkRegularExpression('<span id="msg_[0-9]+"><a href="http://www.mmo-champion.com/index.php\?PHPSESSID=[^&]+&amp;topic=([^>]+)">([^<]+)</a></span>') /> --->
		<cfset setLinkRegularExpression('<a class="title" href="threads/([^"]+)" id="[^"]+">([^<]+)</a>') />
		<cfset setBodyRegularExpression('<div id="post_message_[0-9]+">\s*<blockquote class="postcontent restore ">(.+?)</blockquote>\s*</div>') />		
		
		<cfreturn super.init( arguments.settings ) />
	</cffunction>

	<cffunction name="TitleToPostStruct" returntype="struct" output="false" access="public">
		<cfargument name="txt" type="string" required="true" />
		
		<cfset var dataStruct = PostStructNew() />
		
		<cfscript>
		// ******************
		// ** PASS No. 1   ** Can we insta-ban this title and save some cpu cycles?
		// ******************				
		if ( canBanText(arguments.txt) )
			return dataStruct;
		
		// ******************
		// ** PASS No. 2 ** Determing if it is a person looking for a guild, or a guild advertisement
		// ******************
		dataStruct.score = CreateScoreForLFG( arguments.txt );
		if ( !dataStruct.score )
			return dataStruct;
			
		dataStruct.region = getRegion();			
		
		// ******************
		// ** PASS No. 3   ** Determing the person's class. note that the struct is passed by reference
		// ******************	
		UpdateStructWithClasses( dataStruct, arguments.txt ); 
		
		// ******************
		// ** PASS No. 4   ** Determing the person's idiot status
		// ******************
		UpdateStructWithIdiotStatus( dataStruct, arguments.txt );
		
		// ******************
		// ** PASS No. 5   ** Determing the person's faction
		// ******************
		UpdateStructWithFaction( dataStruct, arguments.txt );	
		</cfscript>
		
		<cfreturn dataStruct />
	</cffunction>

	<cffunction name="getThreadByHook" returntype="string" access="public" output="false">
		<cfargument name="hook" type="string" required="true" />
		
		<cfreturn getThreadURL() & '/' & getHook() & '/' & arguments.hook />
	</cffunction>

</cfcomponent>