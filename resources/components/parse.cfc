<cfcomponent displayname="Parse" output="false">

	<cffunction name="Run" access="public" output="false" returntype="void">

		<cfscript>
		PopulateCache('US-A');
		Refresh('US-A');
		
		PopulateCache('US-H');
		Refresh('US-H');
		
		PopulateCache('EU-EN'); 	
		Refresh('EU-EN');
					
		UpdateHistory();
		</cfscript>
	
	</cffunction>
	
	<cffunction name="PopulateCache" access="public" output="false" returntype="void">
		<cfargument name="region" type="string" required="true">
		
		<cfscript>
			var httpContent = '';
		</cfscript>
		
		<cfset httpContent = fetchHTML(arguments.region,1)>
		
		<cfif len(httpContent)>
			<cfquery name="del" datasource="#this.dsn#">
				set nocount on;
				DELETE FROM Cache
			</cfquery>
			
			<cfquery name="ins" datasource="#this.dsn#">
				set nocount on; 
				INSERT INTO Cache(HTMLCache) VALUES ('#httpContent#');
			</cfquery>
		</cfif>
		
		<cfreturn />
	</cffunction>	

	<cffunction name="Refresh" access="public" output="false" returntype="void">
		<cfargument name="region" type="string" required="true">
	
		<cfscript>
			var data = 0;
			
			data = RefreshData(arguments.region); // refresh the forums
			UpdateLinks(arguments.region, data); // and update them
		</cfscript>
	
	</cffunction>

	<cffunction name="UpdateLinks" access="public" output="false" returntype="void">
		<cfargument name="region" type="string" required="true">
		<cfargument name="dataQry" type="query" required="true">
		
		<cfscript>
			var postVar = '';
			var dbDomain = '';
			var domain = '';
			var armoryURL = '';
			var postBody = '';
		</cfscript>
		
		<cfswitch expression="#arguments.region#">
			<cfcase value="US-A,US-H">
				<cfset dbDomain = 'US'>
				<cfset domain = "http://forums.worldofwarcraft.com/">
			</cfcase>
			<cfcase value="EU-EN">
				<cfset dbDomain = 'EU-EN'>
				<cfset domain = "http://forums.wow-europe.com/">
			</cfcase>
			<cfdefaultcase>
				<cfset dbDomain = 'US'>
				<cfset domain = "http://forums.worldofwarcraft.com/">
			</cfdefaultcase>
		</cfswitch>				
		
		<cfoutput query="dataQry">
			<!--- check to see if the link exists --->
			<cfquery name="check" datasource="#this.dsn#" cachedwithin="#createTimeSpan(0,0,5,0)#">
				SELECT PostID
				FROM Links
				WHERE topicId = '#topicId[currentRow]#'
				AND Region = '#dbDomain#'
			</cfquery>
			
			<cfif not check.recordcount and score gt 0.0>
				<!--- not found, and it's not 0.0, so go! so it's new, so insert! --->
				
				<!--- wait! first let's try to get the post details! --->
				<cfset postBody = fetchPost(arguments.region, topicId[currentRow])>
				
				<!--- wait second, find armory! --->
				<cfset armoryURL = fetchArmory(postBody)>
				
				<cfquery name="ins" datasource="#this.dsn#">
					set nocount on;
					insert into Links(PostURL, 
						  PostTitle, 
						  PostBody,
						  isAlliance,
						  isHorde,
						  isPvP,
						  isPvE,
						  isIdiot,
						  isDeathKnight,
						  isDruid,
						  isHunter,
						  isMage,
						  isMonk,
						  isMonk,
						  isPaladin,
						  isPriest,
						  isRogue,
						  isShaman,
						  isWarlock,
						  isWarrior,
						  Score,
						  topicId,
						  Region,
						  ArmoryURL)
					values('#domain##link[currentRow]#',
						   '#title[currentRow]#',
						   '#postBody#',
						   #isAlliance[currentRow]#,
						   #isHorde[currentRow]#,
						   #isPvP[currentRow]#,
						   #isPvE[currentRow]#,
						   #isIdiot[currentRow]#,
						   #isDeathKnight[currentRow]#,
						   #isDruid[currentRow]#,
						   #isHunter[currentRow]#,
						   #isMage[currentRow]#,
						   #isMonk[currentRow]#
						   #isMonk[currentRow]#,
						   #isPaladin[currentRow]#,
						   #isPriest[currentRow]#,
						   #isRogue[currentRow]#,
						   #isShaman[currentRow]#,
						   #isWarlock[currentRow]#,
						   #isWarrior[currentRow]#,
						   #score[currentRow]#,
						   '#topicId[currentRow]#',
						   '#dbDomain#',
						   '#ArmoryURL#');
				</cfquery>
			</cfif>
		</cfoutput>
		
		<!--- now, make an attempt to fill in some missing data --->
		<cfquery name="getNoPosts" datasource="#this.dsn#" blockfactor="5">
		SELECT TOP (5) topicId, PostID, Region
		FROM Links
		WHERE (PostBody = '') OR (PostBody IS NULL)
		ORDER BY PostID DESC
		</cfquery>
		
		<cfif getNoPosts.recordCount>
			
			<cfoutput query="getNoPosts">

				<cfset postVar = fetchPost(getNoPosts.Region[currentRow], getNoPosts.topicId[currentRow])>
				
				<cfif len(postVar)>
					<cfquery name="updatePost" datasource="#this.dsn#">
						set nocount on;
						UPDATE Links
						SET PostBody = '#postVar#'
						WHERE PostID = #getNoPosts.PostID[currentRow]#
					</cfquery>
				</cfif>

			</cfoutput>
			
		</cfif>
		
	</cffunction>

	<cffunction name="fetchArmory" access="public" output="false" returntype="string">
		<cfargument name="htmlData" type="string" required="true">
		
		<cfscript>
			var strip = '';
			var result = '';
			var armoryPattern = '.*(http://(armory.worldofwarcraft.com|www.wowarmory.com|wowarmory.com|armory.wow-europe.com|eu.wowarmory.com)/(.*)\.xml\?r=([A-Z|''| |%20|%27|\+]+)(&amp;|&)n=([A-Z]+)).*';
		</cfscript>
		
		<cfif not len(trim(arguments.htmlData))>
			<cfreturn result />
		</cfif>
		
		<!--- get rid of html tags first --->
		<cfset strip = stripTags('allow','',arguments.htmlData)>
		
		<!--- find armory info --->
		<cfif reFindNoCase(armoryPattern, strip)>
			<!--- grab it out (only the first!) --->
			<cfset result = reReplaceNoCase(strip, armoryPattern, '\1','ONE')>
		</cfif>

		<cfreturn result />
	</cffunction>

	<cffunction name="RefreshData" access="public" output="false" returntype="query">
		<cfargument name="region" type="string" requied="true">
		
		<cfscript>
			var httpContent 	= '';
			var pageNo 			= 1;
			var mQuery 			= queryNew('link,title,score,topicId,isAlliance,isHorde,isPvP,isPvE,isIdiot,isRogue,isDeathKnight,isDruid,isHunter,isShaman,isWarrior,isWarlock,isPriest,isMage,isMonk,isPaladin');
			var scoreObj		= structNew();
			//var sTempStart 		= 0;
			//var sTempEnd 		= 0;
			//var pageNoPos 		= 0;
			//var pageNoPosEnd	= 0;
			//var tempValue		= 0;
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
			var topicId 		= 0;
		</cfscript>
		
		<cfquery name="get" datasource="#this.dsn#">
			SELECT HTMLCache as cacheData
			FROM Cache
		</cfquery>
		
		<!--- just return now if it's got no data in the cache --->
		<cfif not len(trim(get.cacheData))>
			<cfreturn mQuery />
		</cfif>

		<!--- Phase 2:
		
		This is the actual code that does the work, attempting to break down the HTML into quantifiable meta-deta that can be
		saved to the Database, row-by-row.
		
		--->
		
		<!--- we begin the loop by telling CF to continue to do work so long as there is content on the page to parse, and
		as we break the page down, we'll shrink this string until there is nothing left to work with --->
		
		<cfset httpContent = get.cacheData />
		
		<!--- find the start of <tr class="rows"> --->
		<cfset startPos = findNoCase('<tr class="rows">', httpContent)>
		
		<!--- find the endposition, based on the closed </table> tag --->
		<cfset endPos = findNoCase('</table>', httpContent, startPos)>
		
		<!--- trim away the fat so parsing is a bit faster (just a bit) --->
		<cfset forumVar = trim(mid(httpContent, startPos, evaluate(endPos-startPos)))>
		
		<!--- each <TR> row has 6 <TD>s. We want #2 --->
		<cfset startTR = 1>
		
		<cfloop condition="startTR lt len(forumVar)">
			<cfset endTR = findNoCase('</tr>', forumVar, startTR)>
			
			<cfset startTDOne = findNoCase('<td', forumVar, startTR)>
			<cfset endTDOne = findNoCase('</td>', forumVar, startTDOne)>
			
			<cfset startTDTwo = findNoCase('<td', forumVar, endTDOne)>
			<cfset endTDTwo = findNoCase('</td>', forumVar, startTDTwo)>
			
			<!--- grab the text between those two TD tags --->
			<cfset topicVar = trim(mid(forumVar, startTDTwo, evaluate(endTDTwo-startTDTwo)))>
			
			<!--- now i have the Topic's HTML, time to look for the title of the post. the topic is found in the second anchor --->
			<cfset startAnchorOne = findNoCase('<a', topicVar)>
			<cfset endAnchorOne = findNoCase('</a>', topicVar, startAnchorOne)>
			
			<cfset startAnchorTwo = findNoCase('<a', topicVar, endAnchorOne)>
			<cfset endAnchorTwo = findNoCase('</a>', topicVar, startAnchorTwo)>
			
			<!--- titleVar will now be the start of an anchor, and a string of text... --->
			<cfset titleVar = trim(mid(topicVar, startAnchorTwo, evaluate(endAnchorTwo-startAnchorTwo)))>
			
			<!--- let's grab the anchor and the text --->
			<cfset final = rereplacenocase(titleVar, this.regexp,'\1|\2','ALL')>
			
			<cfset link = listGetAt(final,1,"|")>
			<cfset title = listGetAt(final,2,"|")>
			
			<!--- go ahead and strip the jsession junk out, we don't need it --->
			<cfset link = rereplacenocase(link, '(.*)(;jsessionid=.*[^\?])(\?topicId=[0-9]+.*)', '\1\3', 'ALL')>
			
			<cfset queryAddRow(mQuery)>
			<cfset querySetCell(mQuery,"title", title)>
			<cfset querySetCell(mQuery,"link", link)>
			
			<!--- grab the blizzard topicId and hold onto it for uniqeness later --->
			<cfset topicId = rereplace(link, '.*\?topicId=([0-9]+).*','\1','all')>
			<cfset querySetCell(mQuery,"topicId", topicId)>

			<cfset scoreObj = scoreTitle(arguments.region, title) />
			
			<cfloop list="#structKeyList(scoreObj)#" index="thisKey">
				<cfset querySetCell(mQuery,thisKey,scoreObj[thisKey])>
			</cfloop>				

			<cfset startTR = endTR + 5>
		</cfloop>
		
		<cfreturn mQuery />
	
	</cffunction>
	
	<cffunction name="fetchHTML" returntype="string" output="false" access="private">
		<cfargument name="region" type="string" required="true">
		<cfargument name="currentPage" type="numeric" required="true">
		
		<cfscript>
			var httpVar 	= structNew();
			var httpResult 	= '';
			var start = 0;
			var finish = 0;
			var time = 0;
		</cfscript>
		
		<cfswitch expression="#arguments.region#">
			<cfcase value="US-A">
				<cfset baseURL = "http://forums.worldofwarcraft.com/board.html?forumId=7244843&sid=1&pageNo=#arguments.currentPage#">
			</cfcase>
			<cfcase value="US-H">
				<cfset baseURL = "http://forums.worldofwarcraft.com/board.html?forumId=7244844&sid=1&pageNo=#arguments.currentPage#">
			</cfcase>
			<cfcase value="EU-EN">
				<cfset baseURL = "http://forums.wow-europe.com/board.html?forumId=11096&sid=1&pageNo=#arguments.currentPage#">
			</cfcase>
		</cfswitch>
		
		<cftry>
			<cfset start = getTickCount() />
			<cfhttp method="get" url="#baseURL#" timeout="#this.timeout#" resolveurl="false" result="httpVar">
			
			<cfset finish = getTickCount() />
			<cfset time = (finish-start)>

			<cftrace inline="false" type="information" var="time" category="fetchHTML" text="Time to Fetch HTML">
			
			<cfset httpResult = httpVar.fileContent />
			
			<cfif httpResult is "Connection Failure">
				<cfreturn "" />
			</cfif>
			
			<cfcatch type="any">
				<cfreturn "" />
			</cfcatch>
		</cftry>
	
		<cfreturn httpResult />
	</cffunction>
	
	<cffunction name="fetchPost" returntype="string" output="false" access="private">
		<cfargument name="region" type="string" required="true">
		<cfargument name="topicId" type="numeric" required="true">
		
		<cfscript>
			var httpVar 	= structNew();
			var httpResult 	= '';
			var start = 0;
			var finish = 0;
			var time = 0;
			var startPos = 0;
			var endPos = 0;
			var postStartPos = 0;
			var postVar = '';
		</cfscript>
		
		<cfswitch expression="#arguments.region#">
			<cfcase value="US-A,US-H">
				<cfset baseURL = "http://forums.worldofwarcraft.com/thread.html?topicId=#arguments.topicId#&sid=1">
			</cfcase>
			<cfcase value="EU-EN">
				<cfset baseURL = "http://forums.wow-europe.com/thread.html?topicId=#arguments.topicId#&sid=1">
			</cfcase>
		</cfswitch>
		
		<cftry>
			<cfset start = getTickCount() />
			<cfhttp method="get" url="#baseURL#" timeout="#this.timeout#" resolveurl="false" result="httpVar">
			
			<cfset finish = getTickCount() />
			<cfset time = (finish-start)>

			<cftrace inline="false" type="information" var="time" category="fetchPost" text="Time to Fetch Post">
			
			<cfset httpResult = httpVar.fileContent />
			
			<cfif httpResult is "Connection Failure">
				<cfreturn "" />
			</cfif>
			
			<!--- the parsing is so trivial, let's just do it in this method --->
			<cfif len(httpResult)>
				<cfset startPos = findNoCase('<div class="message-format">', httpResult)>
				<cfset endPos = findNoCase('</div>', httpResult, startPos)>
				<cfset postStartPos = startPos + 28>
				<cfset postVar = trim(mid(httpResult, postStartPos, evaluate(endPos-postStartPos)))>
				<cfreturn postVar />
			</cfif>
			
			<cfcatch type="any">
				<cfreturn "" />
			</cfcatch>
		</cftry>
	
		<cfreturn httpResult />
	</cffunction>	
	
	<cffunction name="getServerTypeFromTitle" returntype="struct" output="false" access="public">
		<cfargument name="region" type="string" required="true">
		<cfargument name="txt" type="string" required="true" />
		
		<cfscript>
			var data = structNew();
			var exclusions = "Vashj|Kael|Hyjal";
			var dbDomain = '';
			data.isPvP = 0;
			data.isPvE = 0;
		</cfscript>
		
		<cfif arguments.region is "EU-EN">
			<cfset dbDomain = 'EU-EN'>
		<cfelse>
			<cfset dbDomain = 'US'>
		</cfif>
		
		<cfquery name="qryServers" datasource="#this.dsn#" cachedwithin="#createTimeSpan(0,8,0,0)#">
			SELECT ServerName, ServerRegExp, ServerType
			FROM Servers
			WHERE Region = '#dbDomain#'
			ORDER BY ServerName
		</cfquery>
		
		<cfloop query="qryServers">
			<cfif findNoCase(ServerName[currentRow], arguments.txt) OR (len(ServerRegExp[currentRow]) and reFindNoCase(ServerRegExp[currentRow], arguments.txt))>
				<!--- server name found! flag the type appropriately --->
				
				<!--- check exclusions first --->
				<cfif reFindNoCase(exclusions, arguments.txt)>
					<!--- sorry, i can't tell if it's a server name or if you're talking about your personal raid progression...END-OF-LINE --->
					<cfbreak />
				</cfif>
				
				<!--- ELSE, we have a winner, so use the lookup and flag appropriately --->
				<cfif find("PvP", ServerType[currentRow])>
					<cfset data.isPvP = 1>
				<cfelse>
					<cfset data.isPvE = 1>
				</cfif>
				
				<cfbreak/> <!--- cut out of the loop now to save cycles --->
			</cfif>
		</cfloop>
		
		<cfreturn data />		
	</cffunction>
	
	<cffunction name="UpdateHistory" returntype="void" output="false" access="public">
		
		<!--- step 1. find out what last month was, and determine if we have data for that month, which should correlate to the 1st of that month. --->
		<cfset lastMonthDate = dateAdd("m", -1, now())>
		<cfset checkDateStart = createDate(year(lastMonthDate), month(lastMonthDate), 1)>
		<cfset checkDateEnd = createDate(year(lastMonthDate), month(lastMonthDate), daysInMonth(lastMonthDate))>
		
		<cfquery name="dateCheck" datasource="#this.dsn#">
			SELECT HistoryID
			FROM History
			WHERE EffectiveDate = #CreateODBCDate(checkDateStart)#
		</cfquery>
		
		<cfif not dateCheck.recordCount>
		
			<!--- it does not exist, so let's load up the stats for the month --->
			<cfquery name="statOne" datasource="#this.dsn#">
				SELECT count(PostID) as NumPosts
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
			</cfquery>
			
			<cfset NumPosts = statOne.NumPosts />
			
			<cfquery name="statTwo" datasource="#this.dsn#">
				SELECT count(PostID) as NumAlliance
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isAlliance = 1
			</cfquery>
			
			<cfset NumAlliance = statTwo.NumAlliance />			
			
			<cfquery name="statThree" datasource="#this.dsn#">
				SELECT count(PostID) as NumHorde
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isHorde = 1
			</cfquery>
			
			<cfset NumHorde = statThree.NumHorde />			
			
			<cfquery name="statFour" datasource="#this.dsn#">
				SELECT count(PostID) as NumPvP
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isPvP = 1
			</cfquery>
			
			<cfset NumPvP = statFour.NumPvP />		
			
			<cfquery name="statFive" datasource="#this.dsn#">
				SELECT count(PostID) as NumPvE
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isPvE = 1
			</cfquery>
			
			<cfset NumPvE = statFive.NumPvE />				
			
			<cfquery name="statSix" datasource="#this.dsn#">
				SELECT count(PostID) as NumIdiots
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isIdiot = 1
			</cfquery>
			
			<cfset NumIdiots = statSix.NumIdiots />		
			
			<cfquery name="statSeven" datasource="#this.dsn#">
				SELECT count(PostID) as NumDruids
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isDruid = 1
			</cfquery>
			
			<cfset NumDruids = statSeven.NumDruids />
			
			<cfquery name="statSevenPointFive" datasource="#this.dsn#">
				SELECT count(PostID) as NumDeathKnights
				FROM LINKS
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isDeathKnight = 1				
			</cfquery>
			
			<cfset NumDeathKnights = statSevenPointFive.NumDeathKnights />					
			
			<cfquery name="statEight" datasource="#this.dsn#">
				SELECT count(PostID) as NumHunters
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isHunter = 1
			</cfquery>
			
			<cfset NumHunters = statEight.NumHunters />		
			
			<cfquery name="statNine" datasource="#this.dsn#">
				SELECT count(PostID) as NumMages
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isMage = 1
			</cfquery>
			
			<cfset NumMages = statNine.NumMages />

			<cfquery name="statNinePointFive" datasource="#this.dsn#">
				SELECT count(PostID) as NumMonks
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isMonk = 1
			</cfquery>
			
			<cfset NumMonks = statNinePointFive.NumMonks />			
			
			<cfquery name="statTen" datasource="#this.dsn#">
				SELECT count(PostID) as NumPaladins
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isPaladin = 1
			</cfquery>
			
			<cfset NumPaladins = statTen.NumPaladins />		
			
			<cfquery name="statEleven" datasource="#this.dsn#">
				SELECT count(PostID) as NumPriests
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isPriest = 1
			</cfquery>
			
			<cfset NumPriests = statEleven.NumPriests />					
			
			<cfquery name="statTwelve" datasource="#this.dsn#">
				SELECT count(PostID) as NumRogues
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isRogue = 1
			</cfquery>
			
			<cfset NumRogues = statTwelve.NumRogues />					
			
			<cfquery name="statThirteen" datasource="#this.dsn#">
				SELECT count(PostID) as NumShamans
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isShaman = 1
			</cfquery>
			
			<cfset NumShamans = statThirteen.NumShamans />	
			
			<cfquery name="statFourteen" datasource="#this.dsn#">
				SELECT count(PostID) as NumWarlocks
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isWarlock = 1
			</cfquery>
			
			<cfset NumWarlocks = statFourteen.NumWarlocks />
			
			<cfquery name="statFifteen" datasource="#this.dsn#">
				SELECT count(PostID) as NumWarriors
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isWarrior = 1
			</cfquery>
			
			<cfset NumWarriors = statFifteen.NumWarriors />		
			
			<cfquery name="statSixteen" datasource="#this.dsn#">
				SELECT count(PostID) as NumUS
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND Region = 'US'
			</cfquery>
			
			<cfset NumUS = statSixteen.NumUS />		
			
			<cfquery name="statSeventeen" datasource="#this.dsn#">
				SELECT count(PostID) as NumEU
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND Region = 'EU-EN'
			</cfquery>
			
			<cfset NumEU = statSeventeen.NumEU />		
			
			<cfquery name="statEighteen" datasource="#this.dsn#">
				SELECT count(PostID) as NumArmory
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND ArmoryURL IS NOT NULL
				AND ArmoryURL <> ''
			</cfquery>
			
			<cfset NumArmory = statEighteen.NumArmory />						

			<!--- we've got em! now let's cache them into History --->
			<cfquery name="ins" datasource="#this.dsn#">
				INSERT INTO History (
					EffectiveDate,
					NumPosts,
					NumAlliance,
					NumHorde,
					NumPvP,
					NumPvE,
					NumIdiots,
					NumDeathKnights,
					NumDruids,
					NumHunters,
					NumMages,
					NumMonks,
					NumPaladins,
					NumPriests,
					NumRogues,
					NumShamans,
					NumWarlocks,
					NumWarriors,
					NumUS,
					NumEU,
					NumArmory
				) VALUES (
					#CreateODBCDate(checkDateStart)#,
					#NumPosts#,
					#NumAlliance#,
					#NumHorde#,
					#NumPvP#,
					#NumPvE#,
					#NumIdiots#,
					#NumDeathKnights#,
					#NumDruids#,
					#NumHunters#,
					#NumMages#,
					#NumMonks#,
					#NumPaladins#,
					#NumPriests#,
					#NumRogues#,
					#NumShamans#,
					#NumWarlocks#,
					#NumWarriors#,
					#NumUS#,
					#NumEU#,
					#NumArmory#
				)
			</cfquery>
		
		</cfif>
		
	</cffunction>
	
	<cffunction name="scoreTitle" returntype="struct" output="false" access="private">
		<cfargument name="region" type="string" required="true">
		<cfargument name="txt" type="string" required="true" />
		
		<cfscript>
			var class = 'rogue|druid|moonkin|boomkin|feral|warr|prot war|fury war|arms war|priest|sham|hunter|mage|lock|destro |pally|paladin|paly| pala |tankadin|retadin|healadin|holydin|loladin| dk |death knight|deathknight|dethknight|dknight|deathk|dethk';	
			var typo = 'rouge|drood|furry|worrier|shamy|serius|shamman|giuld|desto|walrlock|huner|paly|palidan|atunned|dorf|experinced|rading|holydin|loladin|hardocre|grull|preist|deth|hyajl';
			var allyFlag = 'gnome|dwarf|dorf|nelf|night elf|nightelf| ne |draenei|human|alliance';
			var hordeFlag = 'orc|undead|troll|tauren|belf|blood elf|bloodelf|horde';
			var bannedPhrases = 'just got easier|lf healer|are you a|the forgotten knights';

			var start = 0;
			var finish = 0;
			var time = 0;
			
			var rogue = 'rogue|rouge';
			var deathknight = ' dk |deathknight|death knight|dknight|deathk|dethknight|dethk';
			var druid = 'druid|drood|feral|moonkin|boomkin';
			var warrior = 'warr|prot war|fury war|arms war';
			var priest = 'priest';
			var shaman = 'sham';
			var hunter = 'hunter|huner';
			var mage = 'mage';
			var monk = 'monk|mistweaver|brewmaster|windwalker';
			var warlock = 'lock|destro ';
			var paladin = 'pally|paly| pala |paladin|tankadin|retadin|healadin|holydin|loladin';
			
			// scores the title based on how close we think it comes to a person LF guild and not a guild LF person
			var score 		= 0.0;	
			var cPos 		= 0;
			var lfPos 		= 0;
			var lfmPos		= 0;
			var guildPos 	= 0;
			var aPos 		= 0;
			var pvePos 		= 0;
			var pvpPos		= 0;
			var hPos 		= 0;
			var iPos		= 0;	
			var dataStruct 	= structNew();
			var serverStruct = structNew();
			
			dataStruct.isIdiot		= 0;
			dataStruct.isAlliance 	= 0;
			dataStruct.isHorde 		= 0;	
			dataStruct.isPvP		= 0;
			dataStruct.isPvE		= 0;
			dataStruct.isDeathKnight = 0;	
			dataStruct.isRogue 		= 0;
			dataStruct.isDruid 		= 0;
			dataStruct.isWarrior 	= 0;	
			dataStruct.isWarlock 	= 0;	
			dataStruct.isPriest 	= 0;
			dataStruct.isShaman 	= 0;
			dataStruct.isPaladin 	= 0;
			dataStruct.isHunter 	= 0;
			dataStruct.isMage 		= 0;
			dataStruct.isMonk		= 0;	
			
			// time
			start = gettickcount();				
			
			// look for LF
			lfPos = findNoCase(' LF',arguments.txt); // space at the start, so that you don't grab LF out of the middle of a word
			
			// try for 'looking for'
			if (not lfPos)
				lfPos = findNoCase('looking for', arguments.txt);
		
			// how about 'guild'?
			guildPos = findNoCase('guild',arguments.txt);
		
			// if we have 'guild' and 'lf'?
			if (lfPos and guildPos)
			{
				// does 'guild' come before 'lf'? if so, poor score
				if (guildPos lt lfPos)
					score = 0.0;
				else {
					// one more edge condition, if LF is in position 1, and there is a question mark in the title, it *may* be a guild asking the question: 'Looking for a new Guild?'
					if (lfPos eq 1 and find('?', arguments.txt))
						score = 0.0;
					else
						score = 90.0;
				}
			}
			
			// find a class?
			cPos = refindnocase(class, arguments.txt);
			// if a class is in the title, and "LF" is in the title...and the LF comes after the class...
			if (cPos and lfPos and (lfPos gt cPos))
				score = 95.0;
				 
			// this is a rare occurrence, but if the LF comes before the class, and the class comes before the guild
			// then someone probably tried this : "LF HolyPriest for Guild"
			if ((lfPos) and (guildPos) and (cPos) and (guildPos gt cPos) and (cPos gt lfPos))
				score = 0;
				
			// LFM is usually an indication of a guild loooking for more people
			lfmPos = findNoCase('LFM',arguments.txt);
			if (lfmPos and score)
				score = 0;
				
			// try to grab the class
			if (cPos) {
				check = refindnocase(rogue, arguments.txt);
				if (check)
					dataStruct.isRogue = 1;
					
				check = refindnocase(deathknight, arguments.txt);
				if (check)
					dataStruct.isDeathKnight = 1;
				
				check = refindnocase(druid, arguments.txt);
				if (check)
					dataStruct.isDruid = 1;
					
				check = refindnocase(warrior, arguments.txt);
				if (check)
					dataStruct.isWarrior = 1;	
									
				check = refindnocase(warlock, arguments.txt);
				if (check)
					dataStruct.isWarlock = 1;	
					
				check = refindnocase(priest, arguments.txt);
				if (check)
					dataStruct.isPriest = 1;
					
				check = refindnocase(shaman, arguments.txt);
				if (check)
					dataStruct.isShaman = 1;
					
				check = refindnocase(paladin, arguments.txt);
				if (check)
					dataStruct.isPaladin = 1;
					
				check = refindnocase(hunter, arguments.txt);
				if (check)
					dataStruct.isHunter = 1;
					
				check = refindnocase(mage, arguments.txt);
				if (check)
					dataStruct.isMage = 1;

				check = refindnocase(monk, arguments.txt);
				if (check)
					dataStruct.isMonk = 1;
			}
			
			// idiot filter
			iPos = refindnocase(typo, arguments.txt);
			if (iPos gt 0) {
				if (score gt 0)
					score = 40;
				dataStruct.isIdiot = 1;	
			}			
			
			if (arguments.region is 'US-H') {
				dataStruct.isHorde = 1;
			} else if (arguments.region is 'US-A') {
				dataStruct.isAlliance = 1;
			} else if (arguments.region is 'EU-EN') {
				
				// look for [H], (H), < H >, >H< or {H}. also handles escaped < > symbols, and allows a space at the start of the special character. i'm now allowing lowercase
				hPos = refindnocase('(\[|\{|\(|\<|\>|(&lt;)) ?H{1}.*(\]|\}|\)|\>|\<|(&gt;))',arguments.txt);
				if (hPos)
					dataStruct.isHorde = 1;
				else {
					hPos = refindnocase(hordeFlag, arguments.txt);
					if (hPos)
						dataStruct.isHorde = 1;
				}
				
				// look for [A], (A), < A >, >A< or {A}. also handles escaped < > symbols, and allows a space at the start of the special character. i'm now allowing lowercase
				aPos = refindnocase('(\[|\{|\(|\<|\>|(&lt;)) ?A{1}.*(\]|\}|\)|\>|\<|(&gt;))',arguments.txt);
				if (aPos)
					dataStruct.isAlliance = 1;
				else {
					aPos = refindnocase(allyFlag, arguments.txt);
					if (aPos)
						dataStruct.isAlliance = 1;
				}	
							
			}
		
			// look for PvE
			pvePos = findNoCase('pve',arguments.txt);
			if (pvePos) {
				// check to make sure they didn't do something sillly like "NON PVE"
				check = refindnocase('(no|non) ?-? ?pve', arguments.txt);
				if (not check)
					dataStruct.isPvE = 1;
				else
					dataStruct.isPvP = 1;
			} else { 
				// last chance, try to find the server name
				serverStruct = getServerTypeFromTitle(arguments.region, arguments.txt);
				
				dataStruct.isPvE = serverStruct.isPvE;					
			}
			
			// look for PvP
			pvpPos = findNoCase('pvp',arguments.txt);
			if (pvpPos) {
				// check to make sure they didn't do something sillly like "NON PVP"
				check = refindnocase('(no|non) ?-? ?pvp', arguments.txt);
				if (not check)
					dataStruct.isPvP = 1;
				else
					dataStruct.isPvE = 1;
			} else {
				// last chance, try to find the server name
				serverStruct = getServerTypeFromTitle(arguments.region, arguments.txt);
				
				dataStruct.isPvP = serverStruct.isPvP;				
			}
			
			// banned phrases at the end
			if (reFindNoCase(bannedPhrases, arguments.txt)) {
				score = 0.0;
			}
			
			// if you put a question mark in your post, you're history. sorry, there is no need for it.
			if (find('?', arguments.txt)) {
				score = 0.0;
			}
			
			dataStruct.score = score;
			
			finish = gettickcount();
			
			time = (finish-start);
		</cfscript>
		
		<cftrace inline="false" type="information" var="time" category="scoreTitle" text="Time to Score">
		
		<cfreturn dataStruct />
	</cffunction>
	
	<cfscript>
	/**
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
	function stripTags(stripmode,mytags,mystring) {
		var spanquotes = "([^"">]*""[^""]*"")*";
		var spanstart = "[[:space:]]*/?[[:space:]]*";
		var endstring = "[^>$]*?(>|$)";
		var x = 1;
		var currenttag = structNew();
		var subex = "";
		var findonly = false;
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
	}

		this.timeout 		= 135;
		this.dsn 			= 'Parse';
		this.regexp			= '<a href="(.*[^"])" class="active">(.*)';
	</cfscript>
	
</cfcomponent>