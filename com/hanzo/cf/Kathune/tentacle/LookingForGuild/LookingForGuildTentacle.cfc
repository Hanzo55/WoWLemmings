<cfcomponent displayname="LookingForGuildTentacle" output="false" extends="com.hanzo.cf.Kathune.KathuneTentacle">

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.tentacle.LookingForGuild.LookingForGuildTentacle" access="private" output="false">
		<cfargument name="settings" type="struct" required="true" />
		
		<!--- this is an abstract base class which contains shared parsing rules for blizzard-forums in general. should not be instanced. --->
		
		<!---
		<td height="22" class='oddcell' ><a href='viewad.asp?id=50002245057103194'>Looking for a 10 Man Lich Guild</a></td>

		<div class="ad_table_light_cell" id="descr" align="justify" style="margin: 3; width:100%">I currently have 3 lvl 70 alliance toons on the Nordrassil server. A lock, a resto druid, and a prot paladin. I would like to find a guild that has no interest in the 25 man content in Lich. My experience with 25 mans, though the gear is nice, is that the raid feels impersonal. I know the idea of 10 men bringing down Arthas is blasphemy to some, but I just prefer the 10 man group setting. <br>
		<br>
		I would also like a guild who's members have real lives too. Though I can make raid times when I make a commitment, I would not like to spend most of my free time with hardcore raiders who do not understand that real life takes precedence. WoW is my free time release and I don't want it to feel like work. A few hours a couple weeknights a week and maybe some time on the weekends would be ideal for raiding. Between a working on a start up, a full time job, and a significant other, WoW is spent for personal time and I'd like a guild that understands that. <br>
		
		<br>
		That being said, I do take my play seriously and I review rotations of spells for maximum TPS, DPS, and HPS. I'm a geek at heart and have already started a dorky spreadsheet for the new paladin coeffecients that use both AP and SP so that I can maximize itemization. <br>
		<br>
		I curretly play on a pacific server but live in the central time zone, so no server will put me out of peak time raiding.  I understand that I may need to initiate a server transfer and I am completely ready to do that, but would like to maybe start a low lvl toon and get a feel for personalities before lich releases.<br>
		<br>
		Carvis - Lock<br>
		Ronir - Druid<br>
		Rabella - Paladin</div>
		--->
		
		
		<cfset setHook('id')>
		
		<cfset setLinkRegularExpression('<td height="22" class=''oddcell'' ><a href=''viewad.asp\?id=([0-9]+)''>([^<]+)</a></td>') />
		<cfset setBodyRegularExpression('<div class="ad_table_light_cell" id="descr" align="justify" style="margin: 3; width:100%">(.+?)</div>') />
		
		<cfset setThreadURL('http://www.lookingforguild.net/viewad.asp') />		
		
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
		// LookingForGuild.net Tentacles are ALL players looking for guilds. No calculation necessary.
		dataStruct.score = 1.0;
			
		dataStruct.region = getRegion();			
		
		// ******************
		// ** PASS No. 3   ** Determing the person's class. note that the struct is passed by reference
		// ******************	
		UpdateStructWithClasses( dataStruct, arguments.txt ); 
		
		// ******************
		// ** PASS No. 4   ** Determing the person's idiot status
		// ******************
		UpdateStructWithIdiotStatus( dataStruct, arguments.txt );
		</cfscript>
		
		<cfreturn dataStruct />
	</cffunction>	
	
</cfcomponent>