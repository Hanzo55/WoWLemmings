<cfcomponent displayname="Tentacle" output="false">

	<cfscript>
	variables.timeout 		= 8;
	variables.htmlContent 	= '';
	variables.region		= '';
	variables.postQuery 	= 0;
	variables.hPos			= 1; // hook position in reg exp
	variables.tPos			= 2; // title position in reg exp
	
	variables.class 		= 'rogue|rouge|sin |outlaw|druid|feral|boomkin|drood|balance|warr|prot war|fury war|arms war|priest|sham|hunter|mage|monk|windwalker|windwaker|brewmaster|mistweaver|lock|destro |pally|paladin|paly| pala |tankadin|retadin|healadin|holydin|loladin| dk |knight|death knight|deathknight|dethknight|dknight|deathk|dethk| dh |demon hunter|demonhunter|dhunter|dhunt|demonh|veng|havoc';
	variables.bannedPhrases	= 'just got easier|lf healer|are you a|are you looking for a guild|looking for more members|look here';	
	variables.rogue 		= 'rogue|rouge|outlaw|sin ';
	variables.deathknight 	= ' dk |deathknight|death knight|dknight|deathk|dethknight|dethk';
	variables.druid 		= 'druid|drood|feral|boomkin|balance';
	variables.warrior 		= 'warr|prot war|fury war|arms war';
	variables.priest 		= 'priest';
	variables.shaman 		= 'sham';
	variables.hunter 		= 'hunter|huner';
	variables.mage 			= 'mage';
	variables.monk			= 'monk|windwalker|windwaker|brewmaster|mistweaver';
	variables.demonhunter	= ' dh |demon hunter|demonhunter|dhunter|dhunt|demonh|veng|havoc';
	variables.warlock 		= 'lock|destro';
	variables.paladin 		= 'pally|paly| pala |paladin|tankadin|retadin|healadin|holydin|loladin';
	variables.role			= 'tank|healer|healbot|nuker|caster';
	
	variables.typo 			= 'rouge|drood|furry|worrier|warruir|shamy|serius|shamman|giuld|desto|walrlock|huner|paly|palidan|atunned|dorf|experinced|rading|holydin|loladin|hardocre|grull|preist|pirest|deth|windwaker';
	
	variables.allyFlag 		= 'gnome|dwarf|dorf|nelf|night elf|nightelf| ne |draenei|human|alliance';
	variables.hordeFlag 	= 'orc|undead|troll|tauren|belf|blood elf|bloodelf|horde';
	</cfscript>

	<cffunction name="init" returntype="com.hanzo.cf.Kathune.KathuneTentacle" access="private" output="false">
		<cfargument name="settings" type="struct" required="true" />
		
		<cfscript>		
			variables.siteuuid 		= arguments.settings.siteuuid;
			variables.dsn 			= arguments.settings.dsn;
			variables.user_agent 	= arguments.settings.user_agent;
		</cfscript>
		
		<!--- a Kathune Tentacle is a stateful object representing a site that can be parsed for recruitment data. Each Tentacle should maintain its own properties:
		
		1. forum url
		2. forum thread detail url
		3. forum username/password login (if applicable)
		4. datasource if db activity is needed (mostlikely, passed in via Kathune) --->

		<!---
		And, should know how to:
		
		3. parse the HTML for the forum url, and return the parsed data as a query ( ::Grab() )
		4. todo: parse the HTML for the thread detail url, and return the parsed data as a string (Parse:fetchPost)
		5. todo: know how to determine if a post is valid (may no longer exist, may timeout, may be a 404, may be removed, etc) (ITentacle:isPostValid)
		6. todo: provide a region
		
		base functionality across all tentacles should be:
		
		6. todo: know how to pull the server type from a title (Parse:getServerTypeFromTitle)
		7. take the title of a post, and and convert it to a postStruct.
		8. strip XML-style tags (Parse:stripTags)
		9. parse an Armory URL out of an html post
		 --->

		<cfreturn this />
	</cffunction>
	
	<cffunction name="Grab" returntype="void" access="public" output="true">
		<cfset var html = '' />
		
		<!--- fetch the html data, and if there is a result, convert it into a query --->		
		<cfset html = fetchHTML() />
		
		<cfif len( html )>
			<cflock type="exclusive" timeout="15">
				<cfset variables.postQuery = getForumPostQueryFromHTML( html ) />
				<cfset variables.htmlContent = html />
			</cflock>
		<cfelse>
			<cflock type="exclusive" timeout="15">
				<cfset variables.postQuery = 0 />
				<cfset variables.htmlContent = '' />
			</cflock>
		</cfif>
	</cffunction>

	<cffunction name="Purge" returntype="void" access="public" output="true">

		<cflock type="exclusive" timeout="15">
			<cfset variables.postQuery = 0 />
			<cfset variables.htmlContent = '' />
		</cflock>
	</cffunction>
	
	<cffunction name="getForumPostQueryFromHTML" returntype="query" access="public" output="false">
		<cfargument name="html" type="string" required="true" />
		
		<cfscript>
			var httpContent 	= '';
			var pageNo 			= 1;
			var mQuery 			= queryNew('title,hook');
			var scoreObj		= structNew();
			var startPos		= 0;
			var endPos			= 0;
			var forumVar		= 0;
			var startTR			= 0;
			var endTR			= 0;
			var startTDOne		= 0;
			var endTDOne		= 0;
			var startTDTwo		= 0;
			var endTDTwo		= 0;
			var topicVar		= '';
			var startAnchorOne	= 0;
			var endAnchorOne	= 0;
			var startAnchorTwo	= 0;
			var endAnchorTwo	= 0;
			var titleVar 		= '';
			var final			= '';
			var link			= '';
			var title			= '';
			var totalPages 		= 0;
			var currentPage		= 1;
			var hook 			= 0;
			
			var start			= 0;
			var end				= 0;
			
			var linkArray		= 0;
			var i				= 0;
			var tokenized		= 0;
			var token 			= 0;
		</cfscript>
		
		<!--- just return now if it's got no data in the cache --->
		<cfif not len(trim(arguments.html))>
			<cfreturn mQuery />
		</cfif>

		<!--- Phase 2:
		
		This is the actual code that does the work, attempting to break down the HTML into quantifiable meta-deta that can be
		saved to the Database, row-by-row.
		
		--->
		
		<!--- we begin the loop by telling CF to continue to do work so long as there is content on the page to parse, and
		as we break the page down, we'll shrink this string until there is nothing left to work with --->
		
		<cfset httpContent = arguments.html />
		
		<cfset start = getTickCount() />
		
		<cfset linkArray = REMatch( getLinkRegularExpression(), httpContent ) />
		
		<cfloop from="1" to="#ArrayLen(linkArray)#" index="i">
			<cfset token = ExtractTitleAndHookFromLink( linkArray[i] ) />

			<cfset QueryAddRow( mQuery ) />

			<cfset QuerySetCell( mQuery, 'title', urldecode(token.title) ) />
			<cfset QuerySetCell( mQuery, 'hook', token.hook ) />
		</cfloop>		
		
		<cfset end = getTickCount() />
		
		<!--- <cflog file="Kathune" text="KathuneTentacle::getForumPostQueryFromHTML() - time: #evaluate(end-start)#" type="information"> --->
		
		<cfreturn mQuery />		
	</cffunction>	
	
	<cffunction name="fetchHTML" returntype="string" access="public" output="false">
		<cfscript>
		var httpVar 	= structNew();
		var httpResult 	= '';
		</cfscript>
		
		<cftry>
			<cfhttp method="get" url="#getForumURL()#" timeout="#variables.timeout#" resolveurl="false" result="httpVar" useragent="#variables.user_agent#">
			
			<cfset httpResult = httpVar.fileContent />
			
			<cfif httpResult is "Connection Failure">
				<cflog file="Kathune" type="information" text="fetchHTML() - Failed on #getForumURL()#: Connection Failure" />
				<cfreturn "" />
			</cfif>
			
			<cfcatch type="any">
				<cflog file="Kathune" type="information" text="fetchHTML() - Failed on #getForumURL()#: #cfcatch.message# - #cfcatch.detail#" />
				<cfreturn "" />
			</cfcatch>
		</cftry>
	
		<cfreturn httpResult />
	</cffunction>
	
	<cffunction name="fetchPostByHook" returntype="struct" access="public" output="false">
		<cfargument name="hook" type="string" required="true" />
		<cfscript>
			var httpVar 		= structNew();
			var postTitle		= arrayNew(1);
			var postBody		= arrayNew(1);
			var postData		= structNew();
			var cleaned			= '';

			postData.title 		= '';
			postData.body 		= '';


		</cfscript>

		<!--- Between 2008 (wowlemmings inception) and 2016, this method returned a string: the body of the first post of the actual recruitment
		thread. As of now, it will return a struct containing the title of the post and the first post (the original string it used to return).
		the reason? apparently Blizzard's new forums like to switch ids around on brand new posts (for reasons I have yet to comprehend), and
		in order to prevent an extra HTTP request *just* to compare the forum titles a SECOND time, i'm returning the title with the body so that
		it can be used as a comparison. 

		NOTE: ALL old tentacles that derive will have to be updated in order for this to work 
		--->
		
		<cftry>
			<cfhttp method="get" url="#getThreadByHook(arguments.hook)#" timeout="#variables.timeout#" resolveurl="false" result="httpVar" throwOnError="true">
			
			<!--- we store it locally now in case we need to debug the regular expression via getBodyHTML() --->
			<cfset variables.bodyHTML = httpVar.fileContent />

			<cfif variables.bodyHTML is "Connection Failure">
				<cfreturn postData />
			</cfif>

			<!--- now parsed html must both successfully pull a title and a body --->
			<cfif not REFindNoCase( getTitleRegularExpression(), variables.bodyHTML ) and not REFindNoCase( getBodyRegularExpression(), variables.bodyHTML )>
				<cfreturn postData />
			</cfif>
						
			<!--- the parsing is so trivial, let's just do it in this method --->
			<cfif len( variables.bodyHTML )>

				<!--- 1. TITLE --->
				<cfset postTitle = ReMatch( getTitleRegularExpression(), variables.bodyHTML ) />

				<cfset cleaned = trim( ReReplace( postTitle[1], getTitleRegularExpression(), '\1', 'ONE' ) ) />

				<cfset cleaned = URLDecode( cleaned ) />

				<cfset cleaned = replace( cleaned, "'", "''", "ALL" ) />

				<cfset postData.title = cleaned />

				<!--- 2. BODY --->
				<cfset postBody = ReMatch( getBodyRegularExpression(), variables.bodyHTML ) />

				<cfset postData.body = trim( ReReplace( postBody[1], getBodyRegularExpression(), '\1', 'ONE' ) ) />	<!--- the first match will be the person's post, anything else are people responding to his post --->

			</cfif>
			
			<cfcatch type="any">
				<cflog file="Kathune" type="information" text="fetchPostByHook() - Failed on #getThreadByHook(arguments.hook)#: #cfcatch.message# - #cfcatch.detail#" />
				<cfreturn postData />
			</cfcatch>
		</cftry>
		
		<cfreturn postData />		
	</cffunction>		
	
	<cffunction name="ExtractTitleAndHookFromLink" returntype="struct" access="public" output="false">
		<cfargument name="link" type="string" required="true">
		
		<cfset var data = structNew() />
		<cfset var tokenized = ReReplaceNoCase( arguments.link, getLinkRegularExpression(), '\#getHookPosition()#;=;\#getTitlePosition()#', 'ONE' ) />
		
		<cfset data.title = ListGetAt(tokenized, getTitlePosition(), ';=;' ) />
		<cfset data.hook = ListGetAt(tokenized, getHookPosition(), ';=;' ) />

		<cfreturn data />
	</cffunction>	
	
	<cffunction name="getPostsAsObjectArray" returntype="array" access="public" output="false">
		<cfset var oArray = arrayNew(1) />
		<cfset var postObj = 0 />

		<cflock type="readonly" timeout="30">

			<cfif isQuery(variables.postQuery) and variables.postQuery.recordcount>
				<cfloop query="variables.postQuery">
					<cfset postObj = CreatePostObjectFromQueryRow( variables.postQuery, variables.postQuery.currentRow ) />
					<cfset arrayAppend(oArray, postObj ) />
				</cfloop>
			</cfif>

		</cflock>
		
		<cfreturn oArray />
	</cffunction>
	
	<cffunction name="CreatePostObjectFromQueryRow" returntype="com.hanzo.cf.Kathune.Post" access="public" output="false">
		<cfargument name="dataQuery" type="query" required="true" />
		<cfargument name="row" type="numeric" required="true" />
		
		<cfset var postObject = 0 />
		<cfset var scoredStruct = 0 />
		
		<!--- the plan is to:
		1. do generic scoring first
		2. touch up any tentacle-specific scoring in the derived class via polymorphism --->
		
		<cfset postObject 	= CreateObject('component', 'com.hanzo.cf.Kathune.Post') />

			<!--- <cflog file="Kathune" type="information" text="CreatePostObjectFromQueryRow(#arguments.dataQuery.title[arguments.row]#): New com.hanzo.cf.Kathune.Post object created" /> --->
		
		<cfset scoredStruct = TitleToPostStruct( arguments.dataQuery.title[arguments.row] ) />
		
		<cfset postObject.init( argumentCollection=scoredStruct ) />

			<!--- <cflog file="Kathune" type="information" text="CreatePostObjectFromQueryRow(#arguments.dataQuery.title[arguments.row]#): Post Init Fired - Title Output is: #postObject.getPostTitle()#" /> --->
		
		<cfset postObject.setSource( getSource() ) />
		
		<cfset postObject.setPostTitle( replace(arguments.dataQuery.title[arguments.row],"'","''","ALL") ) />

			<!--- <cflog file="Kathune" type="information" text="CreatePostObjectFromQueryRow(#arguments.dataQuery.title[arguments.row]#): setPostTitle() Fired - Title Output is: #postObject.getPostTitle()#" /> --->

		<cfset postObject.setHookValue( arguments.dataQuery.hook[arguments.row] ) />

			<!--- <cflog file="Kathune" type="information" text="CreatePostObjectFromQueryRow(#arguments.dataQuery.title[arguments.row]#): setHookValue() Fired - Hook Output is: #postObject.getHookValue()#" /> --->

		<cfset postObject.setPostURL( getThreadByHook( postObject.getHookValue() ) ) />

			<!--- <cflog file="Kathune" type="information" text="CreatePostObjectFromQueryRow(#arguments.dataQuery.title[arguments.row]#): setPostURL() Fired - URL is: #postObject.getPostURL()#" /> --->
	
		<cfreturn postObject />
	</cffunction>
	
	<cffunction name="getThreadByHook" returntype="string" access="public" output="false">
		<cfargument name="hook" type="string" required="true" />
		
		<cfif find('?', getThreadURL())>
			<cfreturn getThreadURL() & '&' & getHook() & '=' & arguments.hook />
		<cfelse>
			<cfreturn getThreadURL() & '?' & getHook() & '=' & arguments.hook />
		</cfif>	
	</cffunction>		
	
	<cffunction name="fetchArmoryURLFromPost" returntype="string" access="public" output="false">
		<cfargument name="htmlData" type="string" required="true" />
		
		<cfscript>
		var strip 			= '';
		var result 			= '';
		var armoryPattern 	= '.*(http://(armory.worldofwarcraft.com|www.wowarmory.com|wowarmory.com|armory.wow-europe.com|eu.wowarmory.com)/(.*)\.xml\?r=([A-Z|''| |%20|%27|\+]+)(&amp;|&)n=([A-Z]+)).*';
		</cfscript>
		
		<cfif not len( trim(arguments.htmlData) )>
			<cfreturn result />
		</cfif>
		
		<!--- get rid of html tags first --->
		<cfset strip = stripTags('allow', '', arguments.htmlData) />
		
		<!--- find armory info --->
		<cfif reFindNoCase( armoryPattern, strip )>
			<!--- grab it out (only the first, to save cpu cycles...we can only use 1 anyway!) --->
			<cfset result = reReplaceNoCase(strip, armoryPattern, '\1','ONE')>
		</cfif>
		
		<cfif len(result)>
			<cfset result = replace(result, '&amp;', '&', 'ALL') />
		</cfif>

		<cfreturn result />
	</cffunction>
	
	<cffunction name="getServerTypeFromTitleByRegion" returntype="struct" output="false" access="public">
		<cfargument name="region" type="string" required="true">
		<cfargument name="txt" type="string" required="true" />
		
		<cfscript>
		var data 			= structNew();
		var exclusions 		= "Vashj|Kael|Hyjal";
		var dbDomain 		= '';
		
		data.isPvP 			= 0;
		data.isPvE 			= 0;
		</cfscript>
		
		<cfif arguments.region is "EU-EN">
			<cfset dbDomain = 'EU-EN'>
		<cfelse>
			<cfset dbDomain = 'US'>
		</cfif>
		
		<cfquery name="qryServers" datasource="#variables.dsn#" cachedwithin="#createTimeSpan(0,8,0,0)#">
			SELECT ServerName, ServerRegExp, ServerType
			FROM Servers
			WHERE Region = '#dbDomain#'
			ORDER BY ServerName
		</cfquery>
		
		<cfloop query="qryServers">
			<cfif findNoCase(qryServers.ServerName[qryServers.currentRow], arguments.txt) OR 
					( len(qryServers.ServerRegExp[qryServers.currentRow]) and reFindNoCase(qryServers.ServerRegExp[qryServers.currentRow], arguments.txt) )>
				<!--- server name found! flag the type appropriately --->
				
				<!--- check exclusions first --->
				<cfif reFindNoCase(exclusions, arguments.txt)>
					<!--- sorry, i can't tell if it's a server name or if you're talking about your personal raid progression...END-OF-LINE --->
					<cfbreak />
				</cfif>
				
				<!--- ELSE, we have a winner, so use the lookup and flag appropriately --->
				<cfif find("PvP", ServerType[qryServers.currentRow])>
					<cfset data.isPvP = 1>
				<cfelse>
					<cfset data.isPvE = 1>
				</cfif>
				
				<cfbreak /> <!--- cut out of the loop now to save cycles --->
			</cfif>
		</cfloop>
		
		<cfreturn data />		
	</cffunction>
	
	<cffunction name="canBanText" returntype="boolean" access="public" output="false">
		<cfargument name="textString" type="string" required="true" />
		
		<!--- we ban if we find a banned phrase or a ? in the string of text --->
		<cfreturn iif((reFindNoCase( variables.bannedPhrases, arguments.textString ) or find( '?', arguments.textString )), true, false) />			
	</cffunction>
	
	<cffunction name="CreateScoreForLFG" returntype="numeric" access="public" output="false">
		<cfargument name="textString" type="string" required="true" />
		
		<!--- logic could potentially be re-arranged a bit to return a score of 0 and prevent further processing from happening. ie (insta-ban stuff) --->
		
		<cfscript>
		var score 		= 0.0;
		var lfPos 		= 0;
		var guildPos 	= 0;
		var cPos		= 0;		
		var lfmPos		= 0;
		var homePos		= 0;
		var rPos		= 0;
		
		// look for LF
		lfPos = findNoCase(' LF', arguments.textString ); // space at the start, so that you don't grab LF out of the middle of a word
		
		// try for 'looking for'
		if (not lfPos) 
			lfPos = findNoCase( 'looking for', arguments.textString );
	
		// how about 'guild'?
		guildPos = findNoCase( 'guild', arguments.textString );
	
		// if we have 'guild' and 'lf'?
		if ( lfPos and guildPos )
		{
			// does 'guild' come before 'lf'? if so, poor score
			if ( guildPos lt lfPos )
				score = 0.0;
			else {
				// one more edge condition, if LF is in position 1, and there is a question mark in the title, it *may* be a guild asking the question: 'Looking for a new Guild?'
				// hanzo: we now exclude any string of text with a ? mark, so this additional cpu cycle is unnecessary
				//if ( lfPos eq 1 and find( '?', arguments.textString ) )
					//score = 0.0;
				//else
					score = 1.0;
			}
		}	
		
		// find a class?
		cPos = refindnocase( variables.class, arguments.textString );
		
		// if a class is in the title, and "LF" is in the title...and the LF comes after the class...(ie. "Priest looking for a new home!")
		if ( cPos and lfPos and (lfPos gt cPos) )
			score = 1.0;
			 
		// this is a rare occurrence, but if the LF comes before the class, and the class comes before the guild
		// then someone probably tried this : "LF HolyPriest for Guild"
		if ( ( (lfPos) and (guildPos) and (cPos) ) 
				and ( (guildPos gt cPos) and (cPos gt lfPos) ) )
			score = 0.0;
			
		// LFM is usually an indication of a guild loooking for more people
		lfmPos = findNoCase( 'LFM', arguments.textString );
		
		if (score and lfmPos)
			score = 0.0;	
			
		// find a role?
		rPos = refindnocase( variables.role, arguments.textString );
		if ( rPos and lfPos and (lfPos gt rPos) )
			score = 1.0;		
			
		// 'WANTS A NEW HOME' - sure i'll let this fly		
		homePos = refindnocase( 'wants a new home', arguments.textString );
		if (homePos)
			score = 1.0;
		</cfscript>
		
		<cfreturn score />
	</cffunction>
	
	<cffunction name="UpdateStructWithClasses" returntype="void" output="false" access="public">
		<cfargument name="data" type="struct" required="true" />
		<cfargument name="textString" type="string" required="true" />

		<cfscript>
		var cPos 	= refindnocase( variables.class, arguments.textString );
		var check 	= 0;
			
		// try to grab the class
		if (cPos) {
			check = refindnocase( variables.rogue, arguments.textString );
			if (check)
				arguments.data.isRogue = 1;
				
			check = refindnocase( variables.deathknight, arguments.textString );
			if (check)
				arguments.data.isDeathKnight = 1;
			
			check = refindnocase( variables.druid, arguments.textString );
			if (check)
				arguments.data.isDruid = 1;
				
			check = refindnocase( variables.warrior, arguments.textString );
			if (check)
				arguments.data.isWarrior = 1;	
								
			check = refindnocase( variables.warlock, arguments.textString );
			if (check)
				arguments.data.isWarlock = 1;	
				
			check = refindnocase( variables.priest, arguments.textString );
			if (check)
				arguments.data.isPriest = 1;
				
			check = refindnocase( variables.shaman, arguments.textString );
			if (check)
				arguments.data.isShaman = 1;
				
			check = refindnocase( variables.paladin, arguments.textString );
			if (check)
				arguments.data.isPaladin = 1;
				
			check = refindnocase( variables.hunter, arguments.textString );
			if (check)
				arguments.data.isHunter = 1;
				
			check = refindnocase( variables.mage, arguments.textString );
			if (check)
				arguments.data.isMage = 1;

			check = refindnocase( variables.monk, arguments.textString );
			if (check)
				arguments.data.isMonk = 1;

			check = refindnocase( variables.demonhunter, arguments.textString );
			if (check)
				arguments.data.isDemonHunter = 1;
		}
		</cfscript>
	</cffunction>
	
	<cffunction name="UpdateStructWithIdiotStatus" returntype="void" access="public" output="false">
		<cfargument name="data" type="struct" required="true" />
		<cfargument name="textString" type="string" required="true" />
		
		<cfset var iPos = refindnocase( variables.typo, arguments.textString ) />
		<cfif (iPos gt 0)>
			<cfif (arguments.data.score gt 0)>
				<cfset arguments.data.score = 40.0 />
			</cfif>
			<cfset arguments.data.isIdiot = 1 />
		</cfif>
	</cffunction>
	
	<cffunction name="UpdateStructWithFaction" returntype="void" access="public" output="false">
		<cfargument name="data" type="struct" required="true" />
		<cfargument name="textString" type="string" required="true" />

		<cfset var hPos = 0 />
		<cfset var aPos = 0 />
		
		<cfscript>	
		// look for [H], (H), < H >, >H< or {H}. also handles escaped < > symbols, and allows a space at the start of the special character. i'm now allowing lowercase
		hPos = refindnocase( '(\[|\{|\(|\<|\>|(&lt;)) ?H{1}.*(\]|\}|\)|\>|\<|(&gt;))', arguments.textString );
		if (hPos)
			arguments.data.isHorde = 1;
		else {
			hPos = refindnocase( variables.hordeFlag, arguments.textString );
			if (hPos)
				arguments.data.isHorde = 1;
		}
		
		// look for [A], (A), < A >, >A< or {A}. also handles escaped < > symbols, and allows a space at the start of the special character. i'm now allowing lowercase
		aPos = refindnocase( '(\[|\{|\(|\<|\>|(&lt;)) ?A{1}.*(\]|\}|\)|\>|\<|(&gt;))', arguments.textString );
		if (aPos)
			arguments.data.isAlliance = 1;
		else {
			aPos = refindnocase( variables.allyFlag, arguments.textString );
			if (aPos)
				arguments.data.isAlliance = 1;
		}	
		</cfscript>
	</cffunction>
	
	<cffunction name="UpdateStructWithServerType" returntype="void" access="public" output="false">
		<cfargument name="data" type="struct" required="true" />
		<cfargument name="textString" type="string" required="true" />
		
		<cfscript>
		var pvePos 			= 0;
		var pvpPos 			= 0;
		var check 			= 0;
		var serverStruct 	= 0;
			
		// look for PvE
		pvePos = findNoCase( 'pve', arguments.textString );
		if (pvePos) {
			// check to make sure they didn't do something sillly like "NON PVE"
			check = refindnocase( '(no|non) ?-? ?pve', arguments.textString );
			if (not check)
				arguments.data.isPvE = 1;
			else
				arguments.data.isPvP = 1;
		} else { 
			// last chance, try to find the server name
			serverStruct = getServerTypeFromTitleByRegion( getRegion(), arguments.textString );
			
			arguments.data.isPvE = serverStruct.isPvE;					
		}
		
		// look for PvP (if the first PvE pass didn't already set PvE or PvP)
		if (not arguments.data.isPvE and not arguments.data.isPvP) {
			pvpPos = findNoCase( 'pvp', arguments.textString );
			if (pvpPos) {
				// check to make sure they didn't do something sillly like "NON PVP"
				check = refindnocase( '(no|non) ?-? ?pvp', arguments.textString );
				if (not check)
					arguments.data.isPvP = 1;
				else
					arguments.data.isPvE = 1;
			} else {
				// last chance, try to find the server name
				serverStruct = getServerTypeFromTitleByRegion( getRegion(), arguments.textString );
				
				arguments.data.isPvP = serverStruct.isPvP;				
			}			
		}
		</cfscript>	
	</cffunction>
	
	<cffunction name="GetRegionFromText" returntype="string" access="public" output="false">
		<cfargument name="textString" type="string" required="true" />
		
		<cfset var rPos = refindnocase( 'oceanic|europe|[^[:alnum:]]eu[^[:alnum:]]', arguments.textString ) />
		
		<cfif rPos>
			<cfreturn 'EU-EN' />
		<cfelse>
			<cfreturn 'US' />
		</cfif>
	</cffunction>
	
	<cffunction name="PostStructNew" returntype="struct" access="public" output="false">
		<cfscript>
		var data 	= structNew();

		data.isIdiot		= 0;
		data.isAlliance 	= 0;
		data.isHorde 		= 0;	
		data.isPvP			= 0;
		data.isPvE			= 0;
		data.isDeathKnight 	= 0;	
		data.isDemonHunter	= 0;
		data.isRogue 		= 0;
		data.isDruid 		= 0;
		data.isWarrior 		= 0;	
		data.isWarlock 		= 0;	
		data.isPriest 		= 0;
		data.isShaman 		= 0;
		data.isPaladin 		= 0;
		data.isHunter 		= 0;
		data.isMage 		= 0;
		data.isMonk			= 0;
		data.score			= 0;
		data.region			= '';			
		</cfscript>
		
		<cfreturn data />
	</cffunction>
	
	
	
	


	<!--- this function is private, so we force actual tentacle implementations to provide their own TitleToPostStruct() method, which will
	either call super() [ie. this one] or perform its own logic, possibly skipping any of the below methods to save cpu cycles. For example,
	Blizzard.NorthAmerica.Alliance and Blizzard.NorthAmerica.Horde do not require the parse for isHorde or isAlliance; they are flagged 
	automatically
	
	The implementation below is the default order for all parsing requests, called in the most efficient (cpu-saving) order.
	 --->
	<cffunction name="TitleToPostStruct" returntype="struct" output="false" access="private">
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
			
		// ******************
		// ** PASS No. 3   ** Set up the tentacle's region, based on post-title, if it hasn't already been set.
		// ******************
		if ( not len(getRegion() ) )	
			setRegion( getRegionFromText( arguments.txt ) );
		
		dataStruct.region = getRegion();	
		
		// ******************
		// ** PASS No. 4   ** Determing the person's class. note that the struct is passed by reference
		// ******************	
		UpdateStructWithClasses( dataStruct, arguments.txt ); 
		
		// ******************
		// ** PASS No. 5   ** Determing the person's idiot status
		// ******************
		UpdateStructWithIdiotStatus( dataStruct, arguments.txt );
	
		// ******************
		// ** PASS No. 6   ** Determing the person's faction
		// ******************
		UpdateStructWithFaction( dataStruct, arguments.txt );	

		// ******************
		// ** PASS No. 7   ** Determing the person's server type
		// ******************
		if ( !dataStruct.isPvP and !dataStruct.isPvE ) // we'll put this check in just in case some earlier method feels that its smart enough to flag pvp/pve
			UpdateStructWithServerType( dataStruct, arguments.txt );
		</cfscript>
		
		<cfreturn dataStruct />
	</cffunction>			
	
	
	
	
	
	
	
	
	
	
	<!--- getters/setters --->
	<cffunction name="setForumURL" returntype="void" access="public" output="false">
		<cfargument name="forumURL" type="string" required="true" />
		
		<cfset variables.forumURL = arguments.forumURL />
	</cffunction>
	
	<cffunction name="getForumURL" returntype="string" access="public" output="false">

		<cfreturn variables.forumURL />
	</cffunction>
	
	<cffunction name="setThreadURL" returntype="void" access="public" output="false">
		<cfargument name="threadURL" type="string" required="true" />
		
		<cfset variables.threadURL = arguments.threadURL />
	</cffunction>
	
	<cffunction name="getThreadURL" returntype="string" access="public" output="false">

		<cfreturn variables.threadURL />
	</cffunction>	
	
	<cffunction name="setHTML" returntype="void" access="public" output="false">
		<cfargument name="html" type="string" required="true" />
		
		<cfset variables.html = arguments.html />
	</cffunction>
		
	<cffunction name="getHTML" returntype="string" access="public" output="false">
		
		<cfreturn variables.htmlContent />
	</cffunction>
	
	<cffunction name="setPostQuery" returntype="void" access="public" output="false">
		<cfargument name="postQuery" type="query" required="true" />
		
		<cfset variables.postQuery = arguments.postQuery />
	</cffunction>	
	
	<cffunction name="getPostQuery" returntype="query" access="public" output="false">
		
		<cfreturn variables.postQuery />
	</cffunction>
	
	<cffunction name="setSiteUUID" returntype="void" access="public" output="false">
		<cfargument name="siteUUID" type="uuid" required="true" />
		
		<cfset variables.siteUUID = arguments.siteUUID />
	</cffunction>	
	
	<cffunction name="getSiteUUID" returntype="string" access="public" output="false">
		
		<cfreturn variables.siteuuid />
	</cffunction>
	
	<cffunction name="setHook" returntype="void" access="public" output="false">
		<cfargument name="hook" type="string" required="true" />
		
		<cfset variables.hook = arguments.hook />
	</cffunction>	
	
	<cffunction name="getHook" returntype="string" access="public" output="false">
	
		<cfreturn variables.hook />
	</cffunction>
	
	<cffunction name="setHookPosition" returntype="void" access="public" output="false">
		<cfargument name="hPos" type="numeric" required="true" />
		
		<cfset variables.hPos = arguments.hPos />
	</cffunction>	
	
	<cffunction name="getHookPosition" returntype="numeric" access="public" output="false">
	
		<cfreturn variables.hPos />
	</cffunction>
	
	<cffunction name="setTitlePosition" returntype="void" access="public" output="false">
		<cfargument name="tPos" type="numeric" required="true" />
		
		<cfset variables.tPos = arguments.tPos />
	</cffunction>	
	
	<cffunction name="getTitlePosition" returntype="numeric" access="public" output="false">
	
		<cfreturn variables.tPos />
	</cffunction>		
	
	<cffunction name="setRegion" returntype="void" access="public" output="false">
		<cfargument name="region" type="string" required="true" />
		
		<cfset variables.region = arguments.region />
	</cffunction>	
	
	<cffunction name="getRegion" returntype="string" access="public" output="false">
	
		<cfreturn variables.region />
	</cffunction>
	
	<cffunction name="setSource" returntype="void" access="public" output="false">
		<cfargument name="source" type="string" required="true" />
		
		<cfset variables.source = arguments.source />
	</cffunction>	
	
	<cffunction name="getSource" returntype="string" access="public" output="false">
	
		<cfreturn variables.source />
	</cffunction>		
	
	<cffunction name="setLinkRegularExpression" returntype="void" access="public" output="false">
		<cfargument name="regex" type="string" required="true" />
		
		<cfset variables.lregex = arguments.regex />
	</cffunction>	
	
	<cffunction name="getLinkRegularExpression" returntype="string" access="public" output="false">
	
		<cfreturn variables.lregex />
	</cffunction>	

	<cffunction name="setBodyRegularExpression" returntype="void" access="public" output="false">
		<cfargument name="regex" type="string" required="true" />
		
		<cfset variables.bregex = arguments.regex />
	</cffunction>	
	
	<cffunction name="getBodyRegularExpression" returntype="string" access="public" output="false">
	
		<cfreturn variables.bregex />
	</cffunction>	

	<cffunction name="setTitleRegularExpression" returntype="void" access="public" output="false">
		<cfargument name="regex" type="string" required="true" />
		
		<cfset variables.tregex = arguments.regex />
	</cffunction>	
	
	<cffunction name="getTitleRegularExpression" returntype="string" access="public" output="false">
	
		<cfreturn variables.tregex />
	</cffunction>		

	<cffunction name="setBodyHTML" returntype="void" access="public" output="false">
		<cfargument name="html" type="string" required="true" />

		<cfset variables.bodyHTML = arguments.html />
	</cffunction>

	<cffunction name="getBodyHTML" returntype="string" access="public" output="false">

		<cfreturn variables.bodyHTML />
	</cffunction>

	

	
		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	


	
	






	
	

	<!--- UTILITIES --->

	<!--- 	/**
	 * Strip xml-like tags from a string when they are within or not within a list of tags.
	 * 
	 * @param stripmode 	 A string, disallow or allow. Specifies if the list of tags in the mytags attribute is a list of tags to allow or disallow. (Required)
	 * @param mytags 	 List of tags to either allow or disallow. (Required)
	 * @param mystring 	 The string to check. (Required)
	 * @param findonly 	 Boolean value. If true, returns the first match. If false, all instances are replaced. (Optional)
	 * @return Returns either a string or the first instance of a match. 
	 * @author Isaac Dealey (info@turnkey.to) 
	 * @version 2, September 22, 2004 
	 */
 	--->
	<cffunction name="stripTags" returntype="string" access="public" output="false">
		<cfargument name="stripmode" type="string" required="true" />
		<cfargument name="mytags" type="string" required="true" />
		<cfargument name="mystring" type="string" required="true" />
		<cfargument name="findonly" type="boolean" required="false" default="false" />
	
		<cfscript>
		var spanquotes = "([^"">]*""[^""]*"")*";
		var spanstart = "[[:space:]]*/?[[:space:]]*";
		var endstring = "[^>$]*?(>|$)";
		var x = 1;
		var currenttag = structNew();
		var subex = "";
		var cfversion = iif(structKeyExists(GetFunctionList(),"getPageContext"), 6, 5);
		var backref = "\\1"; // this backreference works in cf 5 but not cf mx
		var rexlimit = len(mystring);
	
		if (arraylen(arguments) gt 3) { findonly = arguments[4]; }
		if (cfversion gt 5) { backref = "\#backref#"; } // fix backreference for mx and later cf versions
		else { rexlimit = 19000; } // limit regular expression searches to 19000 characters to support CF 5 regex character limit
	
		if (len(trim(mystring))) {
			// initialize defaults for examining this string
			currenttag.pos = ListToArray("0");
			currenttag.len = ListToArray("0");
	
			mytags = ArrayToList(ListToArray(mytags)); // remove any empty items in the list
			if (len(trim(mytags))) {
				// turn the comma delimited list of tags with * as a wildcard into a regular expression
				mytags = REReplace(mytags,"[[:space:]]","","ALL");
				mytags = REReplace(mytags,"([[:punct:]])",backref,"ALL");
				mytags = Replace(mytags,"\*","[^$>[:space:]]*","ALL");
				mytags = Replace(mytags,"\,","[$>[:space:]]|","ALL");
				mytags = "#mytags#[$>[:space:]]";
			} else { mytags = "$"; } // set the tag list to end of string to evaluate the "allow nothing" condition
	
			// loop over the string
			for (x = 1; x gt 0 and x lt len(mystring); x = x + currenttag.pos[1] + currenttag.len[1] -1)
			{ 
				// find the next tag within rexlimit characters of the starting point
				currenttag = REFind("<#spanquotes##endstring#",mid(mystring,x,rexlimit),1,true); 
				if (currenttag.pos[1])
				{ 
					// if a tag was found, compare it to the regular expression
					subex = mid(mystring,x + currenttag.pos[1] -1,currenttag.len[1]); 
					if (stripmode is "allow" XOR REFindNoCase("^<#spanstart#(#mytags#)",subex,1,false) eq 1)
					{
						if (findonly) { return subex; } // return invalid tag as an error message
						else { // remove the invalid tag from the string
							myString = RemoveChars(myString,x + currenttag.pos[1] -1,currenttag.len[1]);
							currenttag.len[1] = 0; // set the length of the tag string found to zero because it was removed
						}
					}
				}
				// no tag was found within rexlimit characters
				// move to the next block of rexlimit characters -- CF 5 regex limitation
				else { currenttag.pos[1] = rexlimit; }
			}
		}
		if (findonly) { return ""; } // return an empty string indicating no invalid tags found
		else { return mystring; } // return the new string discluding any invalid tags
		</cfscript>
	</cffunction>
	
	<cffunction name="DumpRawFood" returntype="void" access="public" output="true">
	
		<cfif isDefined('variables.forumQry') and variables.forumQry.recordCount>
			<cfdump var="#variables.forumQry#">
		<cfelse>
			<cfdump var="#variables.htmlContent#">
		</cfif>

		<cfabort/>

	</cffunction>
	

</cfcomponent>