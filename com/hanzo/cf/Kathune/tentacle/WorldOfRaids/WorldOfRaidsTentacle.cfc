<cfcomponent displayname="WorldOfRaidsTentacle" output="false" extends="com.hanzo.cf.Kathune.KathuneTentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.tentacle.WorldOfRaids.WorldOfRaidsTentacle" access="private" output="false">
		<cfargument name="settings" type="struct" required="true" />
		
		<!--- this is an abstract base class which contains shared parsing rules for blizzard-forums in general. should not be instanced. --->
		
		<!---
		<a href="showthread.php?t=19225" id="thread_title_19225" style="font-weight:bold">[A-PvP][Magtheridon] &lt;Sacred Wrath&gt; 2/6 SWP + WoTLK</a>
		
		<a href="showthread.php?s=35937566ac7709ed40bb479bfbe7386a&amp;t=19225" id="thread_title_19225">[A-PvP][Magtheridon] &lt;Sacred Wrath&gt; 2/6 SWP + WoTLK</a>
		
		hanzo: note below the two spaces between the id attribute and the style? that one caught me off guard, because html display shows the single space
		but the actual content is 2 spaces. I'm using \s+ to match 1 or more whitespace between those attributes in case the ever notice that and fix it back to 1

		<div id="post_message_92818"  style="font-size:9pt;"></div>	
		--->
		
		
		<cfset setHook('t')>
		<cfset setLinkRegularExpression('<a href="showthread.php\?s=[^&]+&amp;t=([0-9]+)" id="thread_title_[0-9]+">([^<]+)</a>') />
		<cfset setBodyRegularExpression('<div id="post_message_[0-9]+"\s+style="font-size:9pt;">(.+?)</div>') />
		<cfset setThreadURL('http://www.worldofraids.com/forums/showthread.php') />		
		
		<cfreturn super.init(arguments.settings) />
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
		// ** PASS No. 6   ** Determing the person's server type
		// ******************
		if (not dataStruct.isPvP and not dataStruct.isPvE) // we'll put this check in just in case some earlier method feels that its smart enough to flag pvp/pve
			UpdateStructWithServerType( dataStruct, arguments.txt );
		</cfscript>
		
		<cfreturn dataStruct />
	</cffunction>	
	
</cfcomponent>