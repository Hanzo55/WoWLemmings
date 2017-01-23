<cfcomponent displayname="Europe" output="false" extends="com.hanzo.cf.Kathune.tentacle.Blizzard.BlizzardTentacle" implements="com.hanzo.cf.Kathune.interface.ITentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.tentacle.Blizzard.Europe.EuropeTentacle" access="public" output="false">
		<cfargument name="settings" type="struct" required="true" />

		<cfset setThreadURL('https://eu.battle.net/forums/en/wow') />
		
		<cfset setForumURL('https://eu.battle.net/forums/en/wow/874708/') />
		
		<cfset setSource('World of Warcraft -> Forums -> Looking For Players - PVE') />		
		
		<cfset setRegion('EU-EN') />
		
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
		// ** PASS No. 5   ** Determing the person's faction
		// ******************
		UpdateStructWithFaction( dataStruct, arguments.txt );	

		// ******************
		// ** PASS No. 6   ** Determing the person's server type
		// ******************
		if (not dataStruct.isPvP and not dataStruct.isPvE) // we'll put this check in just in case some earlier method feels that its smart enough to flag pvp/pve
			UpdateStructWithServerType( dataStruct, arguments.txt );
		</cfscript>
		
		<cfreturn dataStruct />
	</cffunction>	
	
</cfcomponent>