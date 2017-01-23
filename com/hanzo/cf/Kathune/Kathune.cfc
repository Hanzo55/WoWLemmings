<cfcomponent displayname="Kathune" output="false">
	
	<cffunction name="init" returntype="com.hanzo.cf.Kathune.Kathune" access="public" output="false">
		<cfargument name="xmlPath" type="string" required="true" />

		<cfscript>
			// local
			
			var xmlObj 					= 0;
			var datasource 				= 0;
			var tentacleArray 			= 0;
			var tent 					= 0;
			var settings 				= structNew();
			var authStruct				= structNew();
			var i 						= 0;
			
			// stateful
			variables.activeTentacle	= 0;
			variables.user_agent 		= 'Mozilla/5.0 (compatible; WoW Lemmings Kathune/2.0; http://www.wowlemmings.com/kathune.html)';
			variables.httpFetchMaximum 	= 8; 		// maximum amount of posts to fetch from the db in an attempt to grab bodies, the higher the number, the more expensive / cpuhog like this spider becomes. this number should not go any higher than the CFADMIN thread max.
			variables.timeout 			= 8;			
			variables.tentacles			= arrayNew(1);
			variables.NewRecruitQueue	= arrayNew(1);
			variables.RecruiterSearch	= StructNew();			
			variables.analysis			= CreateObject('component', 'com.hanzo.cf.Kathune.AnalysisService');
			//variables.twitter			= CreateObject('component', 'com.hanzo.cf.Kathune.Twitter').init('USERNAME','PASSWORD');
			variables.oAuthToken		= '';
			variables.oAuthSecret		= '';
			variables.accessToken 		= '';
			variables.accessSecret 		= '';
			variables.screen_name 		= '';
			variables.user_id 			= '';
			
			variables.twitter			= CreateObject('component', 'com.coldfumonkeh.monkehTweet')
				.init(
					consumerKey			=	'CONSUMERKEY',
					consumerSecret		=	'CONSUMERSECRET',
					oauthToken			=	'OAUTHTOKEN',
					oauthTokenSecret	= 	'OAUTHTOKENSECRET',
					userAccountName		= 	'WoWLemming',
					parseResults		=	true
				);
			
			/*	
			authStruct = variables.twitter.getAuthorisation(callbackURL='http://www.wowlemmings.com/authorize.cfm');
			
			if (authStruct.success) {
				//	Here, the returned information is being set into the session scope.
				//	You could also store these into a DB (if running an application for multiple users)
				variables.oAuthToken			= authStruct.token;
				variables.oAuthTokenSecret		= authStruct.token_secret;
			}
			* */				
			
			// prime the variables.RecruiterSearch var
			ResetRecruiterSearch(variables.RecruiterSearch);
		</cfscript>
		
		<!--- <cfhttp method="get" url="#authStruct.authURL#" redirect="false"> --->

		<!--- read config, convert to xml object --->		
		<cffile action="read" file="#expandPath(arguments.xmlPath)#" variable="configFile" />
		<cfset xmlObj = XmlParse(configFile)>
		
		<!--- setup xpath arrays --->
		<cfset datasource = XmlSearch(xmlObj, '//datasource') />
		<cfset tentacleArray = XmlSearch(xmlObj, '//tentacle') />
		
		<!--- assign Kathune properties --->
		<cfset variables.dsn = datasource[1].XmlText />
		
		<!--- prep default settings struct for init on all tentacles --->
		<cfset settings.dsn = variables.dsn />
		<cfset settings.user_agent = getUserAgent() />
		
		<cfloop from="1" to="#arrayLen(tentacleArray)#" index="i">
			<cfscript>
				tent = structNew();
				
				settings.SiteUUID = tentacleArray[i].XmlAttributes.SiteUUID;
				
				tent = CreateObject( 'component','com.hanzo.cf.Kathune.tentacle.#tentacleArray[i].XmlText#' ).init( settings );
				
				arrayAppend( variables.tentacles, tent );
			</cfscript>
			
			<cflog file="Kathune" type="information" text="init() - Loaded com.hanzo.cf.Kathune.tentacle.#tentacleArray[i].XmlText# into memory (SiteUUID: #settings.SiteUUID#)">
		</cfloop>
		
		<cflog file="Kathune" type="information" text="init() - Successfully loaded #ArrayLen(variables.tentacles)# tentacles into memory">

		<!--- regardless of thread max, don't spawn more threads than tentacles you've *actually* loaded --->
		<cfif variables.httpFetchMaximum gt ArrayLen(variables.tentacles)>
			<cfset variables.httpFetchMaximum = ArrayLen(variables.tentacles) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="ResetRecruiterSearch" returntype="void" access="public" output="false">
		<cfargument name="searchData" type="struct" required="true" />
		
		<!--- if the struct is empty, init it first --->
		<cfif StructIsEmpty(arguments.searchData)>
			<cfset StructInsert( arguments.searchData, 'us', '' ) />
			<cfset StructInsert( arguments.searchData, 'eu-en', '' ) />
			<cfset StructInsert( arguments.searchData, 'alliance', '' ) />
			<cfset StructInsert( arguments.searchData, 'horde', '' ) />
			<cfset StructInsert( arguments.searchData, 'pve', '' ) />
			<cfset StructInsert( arguments.searchData, 'pvp', '' ) />
			<cfset StructInsert( arguments.searchData, 'deth', '' ) />
			<cfset StructInsert( arguments.searchData, 'demo', '' ) />	
			<cfset StructInsert( arguments.searchData, 'drui', '' ) />
			<cfset StructInsert( arguments.searchData, 'hunt', '' ) />
			<cfset StructInsert( arguments.searchData, 'mage', '' ) />
			<cfset StructInsert( arguments.searchData, 'monk', '' ) />
			<cfset StructInsert( arguments.searchData, 'pala', '' ) />
			<cfset StructInsert( arguments.searchData, 'prie', '' ) />
			<cfset StructInsert( arguments.searchData, 'rogu', '' ) />
			<cfset StructInsert( arguments.searchData, 'sham', '' ) />
			<cfset StructInsert( arguments.searchData, 'warl', '' ) />
			<cfset StructInsert( arguments.searchData, 'warr', '' ) />
			<cfset StructInsert( arguments.searchData, 'idiotFilter', '' ) />
			<cfset StructInsert( arguments.searchData, 'keywords', StructNew() ) />
		</cfif>
		
		<!--- reset the values --->
		<cfloop list="#StructKeyList(arguments.searchData)#" index="tKey">
			<cfif tKey IS NOT 'keywords'>
				<cfset arguments.searchData[tKey] = 0 />
			</cfif>
		</cfloop>
		
		<!--- empty out keywords --->
		<cfset StructClear(arguments.searchData.keywords) />
	</cffunction>
	
	<cffunction name="PreyOnTheWeak" returntype="void" access="public" output="false" 
				hint="I am the main() function that executes all db maintenance, spidering logic, data refresh, and statistics updates. You. Will. Die.">
	
		<cfscript>
		/*** Kathune biz logic: ***/
		
		// 1. todo: perform db cleanup/maintenance (if necessary) -todo
		//WashMouth();
		
		// 2. parse all of the recruitment data for all sites (ExtendTentacles) and update by forum post titles/ids
		ExtendTentacles();
		
		// 3. review the bottom X amount of entries in the DB that have no postBodies, and fetch/update them, along with armoryURLs and any additional flags to further categorize the post 
		//Feed( variables.httpFetchMaximum );
		
		// 4. perform a final pass on bottom X entries with a score of 1.0 and re-calculate the score, using armory if needed
		//Digest( variables.httpFetchMaximum ); 
		</cfscript>
	</cffunction>
	
	<cffunction name="Glare" returntype="void" access="public" output="false"
				hint="I am responsible for announcing newly discovered recruits via Twitter.">
		<cfargument name="emptyQueue" type="boolean" required="false" default="true" />
		<cfargument name="emailXML" type="boolean" required="false" default="false" />

		<cfset var theRecruit = 0 />
		<cfset var countDK = 0 />
		<cfset var countDH = 0 />
		<cfset var countDruid = 0 />
		<cfset var countHunter = 0 />
		<cfset var countMage = 0 />
		<cfset var countMonk = 0 />
		<cfset var countPaladin = 0 />
		<cfset var countPriest = 0 />
		<cfset var countRogue = 0 />
		<cfset var countShaman = 0 />
		<cfset var countWarlock = 0 />
		<cfset var countWarrior = 0 />
		<cfset var middleString = '' />
		<cfset var finalString = '' />
		<cfset var xmlResponse = '' />

		<!--- step 1. Befriend All --->
		
		<!--- step 2. Look at the NewRecruitQueue. Are there entries? If so, build a message and update via Twitter --->
		<cfif ArrayLen(variables.NewRecruitQueue)>
			<cfloop array="#variables.NewRecruitQueue#" index="theRecruit">
				<cfif (theRecruit.isDeathKnight[1])>
					<cfset countDK++ />
				</cfif>
				<cfif (theRecrut.isDemonHunter[1])>
					<cfset countDH++ />
				</cfif>
				<cfif (theRecruit.isDruid[1])>
					<cfset countDruid++ />
				</cfif>
				<cfif (theRecruit.isHunter[1])>
					<cfset countHunter++ />
				</cfif>
				<cfif (theRecruit.isMage[1])>
					<cfset countMage++ />
				</cfif>
				<cfif (theRecruit.isMonk[1])>
					<cfset countMonk++ />
				</cfif>
				<cfif (theRecruit.isPaladin[1])>
					<cfset countPaladin++ />
				</cfif>
				<cfif (theRecruit.isPriest[1])>
					<cfset countPriest++ />
				</cfif>
				<cfif (theRecruit.isRogue[1])>
					<cfset countRogue++ />
				</cfif>
				<cfif (theRecruit.isShaman[1])>
					<cfset countShaman++ />
				</cfif>
				<cfif (theRecruit.isWarlock[1])>
					<cfset countWarlock++ />
				</cfif>
				<cfif (theRecruit.isWarrior[1])>
					<cfset countWarrior++ />
				</cfif>
			</cfloop>
			
			<!--- build middle part of the string --->
			<cfset middleString = ListAppendClass(middleString, 'Death Knight', countDK) />
			<cfset middleString = ListAppendClass(middleString, 'Demon Hunter', countDH) />
			<cfset middleString = ListAppendClass(middleString, 'Druid', countDruid) />
			<cfset middleString = ListAppendClass(middleString, 'Hunter', countHunter) />
			<cfset middleString = ListAppendClass(middleString, 'Mage', countMage) />
			<cfset middleString = ListAppendClass(middleString, 'Monk', countMonk) />
			<cfset middleString = ListAppendClass(middleString, 'Paladin', countPaladin) />
			<cfset middleString = ListAppendClass(middleString, 'Priest', countPriest) />
			<cfset middleString = ListAppendClass(middleString, 'Rogue', countRogue) />
			<cfset middleString = ListAppendClass(middleString, 'Shaman', countShaman) />
			<cfset middleString = ListAppendClass(middleString, 'Warlock', countWarlock) />
			<cfset middleString = ListAppendClass(middleString, 'Warrior', countWarrior) />
			
			<cfif ListLen(middleString,'|') GT 1>
				<cfset middleString = listInsertAt(middleString,listLen(middleString,'|'),'and','|') />
				<cfset middleString = replaceNoCase(middleString,'|and|',' and ','ONE') />
				<cfset middleString = listChangeDelims(middleString,', ','|') />				
			</cfif>
			
			<cfset finalString = GetStartMessage() & " " & middleString & ". " & GetEndMessage() />
			
			<!--- send message --->
			<cfif len(trim(middleString))>
				<cfset xmlResponse = variables.twitter.postUpdate(finalString) />
			</cfif>
			
			<cfif (arguments.emailXML) and len(xmlResponse)>
				<cfmail to="shawn.a.holmes@gmail.com" from="hattori_hanzo@milclan.com" subject="WoWLemmings: Debug">#toString(xmlResponse)#</cfmail>
			</cfif>
					
			<cfif (arguments.emptyQueue)>
				<!--- step 3. Empty the Queue. --->	
				<cfset ArrayClear(variables.NewRecruitQueue) />
			</cfif>	
			
		</cfif>

	</cffunction>
	
	<cffunction name="Thrash" returntype="void" access="public" output="false"
				hint="I am responsible for announcing search results via Twitter.">
		<cfargument name="resetQueue" type="boolean" required="false" default="true" />
		<cfargument name="emailXML" type="boolean" required="false" default="false" />
		
		<cfset var tKey = 0 />
		<cfset var middleString = '' />
		<cfset var finalString = '' />
		<cfset var xmlResponse = '' />		
		
		<!--- step 1. look at the recruiter search. is it empty? if not, build up a message --->
		<cfif NOT RecruiterSearchIsEmpty(variables.RecruiterSearch)>
		
			<!--- step 2. build middle part of string --->
			<cfloop list="#StructKeyList(variables.RecruiterSearch)#" index="tKey">
			
				<cfif tKey is not 'keywords'>
					
					<cfif variables.RecruiterSearch[tKey] GT 0>
						<cfset middleString = ListAppendQueryTerm(middleString, tKey, variables.RecruiterSearch[tKey]) />
					</cfif>
					
				</cfif>
			
			</cfloop>
			
			<!--- step 3. clean up the string so it looks like it was properly written/punctuated --->
			<cfif ListLen(middleString,'|') GT 1>
				<cfset middleString = listInsertAt(middleString,listLen(middleString,'|'),'and','|') />
				<cfset middleString = replaceNoCase(middleString,'|and|',' and ','ONE') />
				<cfset middleString = listChangeDelims(middleString,', ','|') />				
			</cfif>	
			
			<!--- step 4. add the start and end --->
			<cfset finalString = GetStartSearchMessage() & " " & middleString & ". " & GetEndSearchMessage() />	
			
			<!--- step 5. send message --->
			<cfif len(trim(middleString))>
				<cfset xmlResponse = variables.twitter.postUpdate(finalString) />
			</cfif>
			
			<cfif (arguments.emailXML) and len(xmlResponse)>
				<cfmail to="shawn.a.holmes@gmail.com" from="hattori_hanzo@milclan.com" subject="WoWLemmings: Debug">#toString(xmlResponse)#</cfmail>
			</cfif>
				
			<!--- step 6. Empty the Queue. --->					
			<cfif (arguments.resetQueue)>
					
				<cfset ResetRecruiterSearch(variables.RecruiterSearch) />
			
			</cfif>							
		
		</cfif>
		
	</cffunction>
	
	<cffunction name="RecruiterSearchIsEmpty" returntype="boolean" access="private" output="false">
		<cfargument name="searchData" type="struct" required="true" />
		
		<cfset var isEmpty = true />
		
		<cfloop list="#StructKeyList(arguments.searchData)#" index="tKey">
			<cfif tKey IS NOT 'keywords'>
				<cfif arguments.searchData[tKey] GT 0>
					<cfset isEmpty = false />
					<cfbreak />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn isEmpty />
	</cffunction>	
	
	<cffunction name="GetStartMessage" returntype="string" output="false" access="public">
	
		<cfreturn 'I found' />
	
	</cffunction>
	
	<cffunction name="GetEndMessage" returntype="string" output="false" access="public">
	
		<cfreturn '##wow' />
	
	</cffunction>
	
	<cffunction name="GetStartSearchMessage" returntype="string" output="false" access="public">
	
		<cfreturn 'People are looking for' />
	
	</cffunction>
	
	<cffunction name="GetEndSearchMessage" returntype="string" output="false" access="public">
	
		<cfreturn '##wow' />
	
	</cffunction>	
	
	<cffunction name="AddSearchToQueue" returntype="void" access="public" output="false"
				hint="I am responsible for capturing any HTTP requets along with search parameters, to pass to the Twitter queue.">
		<cfargument name="query_string" type="string" required="false" default="" />
		
		<cfset var tKey = 0 />
		<cfset var tValue = 0 />
		<cfset var tPair = 0 />
		<cfset var query_struct = StructNew() />

		<!--- if there's no query_string, just return --->
		<cfif not len(arguments.query_string)>
			<cfreturn />
		</cfif>
		
		<!--- loop over the string and generate a data struct --->
		<cfloop list="#arguments.query_string#" index="tPair" delimiters="&">
			<cfif ListLen(tPair,'=') EQ 2>
				
				<cfset tKey = ListGetAt(tPair, 1, '=') />
				<cfset tValue = ListGetAt(tPair, 2, '=') />
				
				<cftrace var="tValue" text="query_struct:#tKey#" category="AddSearchToQueue:Add">
			
				<cfset StructInsert(query_struct, tValue, 1, true) />
			
			</cfif>
		</cfloop>
		
		<cfset IncrementRecruiterSearch(query_struct) />
	</cffunction>
	
	<cffunction name="IncrementRecruiterSearch" returntype="void" access="private" output="false">
		<cfargument name="query_data" type="struct" required="true">
		
		<cfset var tKey = 0 />
		<cfset var keywordKey = 0 />
		
		<!--- loop over the keys in the recruiter struct --->
		<cfloop list="#StructKeyList(variables.RecruiterSearch)#" index="tKey">
			
			<cftrace var="tKey" text="term" category="IncrementRecruiterSearch:Exists">
		
			<cfif tKey IS NOT 'keywords'>
			
				<!--- see if the key exists in the data structure passed in --->
				<cfif StructKeyExists(arguments.query_data, tKey)>
					
					<cftrace var="tKey" text="term" category="IncrementRecruiterSearch:Add">
					
					<!--- yup, so let's increment the count --->
					<cfset variables.RecruiterSearch[tKey] += 1 />
					
				</cfif>
			
			</cfif>
		
		</cfloop>
		
		<!--- and now, loop over keywords (if it exists and is not empty)--->
		<cfif StructKeyExists(arguments.query_data, 'keywords') AND NOT StructIsEmpty(arguments.query_data.keywords)>
		
			<cfloop list="#StructKeyList(arguments.query_data)#" index="keywordKey">
			
				<!--- does it exist in the queue? --->
				<cfif StructKeyExists(variables.RecruiterSearch, keywordKey)>
					
					<!--- it does, so increment the count --->
					<cfset variables.RecruiterSearch[keywordKey] += 1 />
					
				<cfelse>
				
					<!--- it does not, so add a new reference and set it to 1 --->
					<cfset StructInsert( variables.RecruiterSearch, keywordKey, 1, false ) />
				
				</cfif>
			
			</cfloop>
		
		</cfif>
	</cffunction>	
	
	<cffunction name="ListAppendClass" returntype="string" output="false" access="public">
		<cfargument name="theList" type="string" required="true" />
		<cfargument name="class" type="string" required="true" />
		<cfargument name="count" type="numeric" required="true" />
		<cfargument name="displayCount" type="boolean" required="false" default="true" />
		
		<cfset var newList = '' />
		<cfset var word = arguments.class />
		
		<cfif (NOT arguments.count)>
			<cfreturn arguments.theList />
		</cfif>
		
		<cfif arguments.count GT 1>
			<cfset word = word & 's' />
		</cfif>
		
		<cfif arguments.displayCount>
			<cfset newList = ListAppend(arguments.theList, arguments.count & ' ' & word, '|') />
		<cfelse>
			<cfset newList = ListAppend(arguments.theList, word, '|') />
		</cfif>
		
		<cfreturn newList />
	</cffunction>
	
	<cffunction name="ListAppendQueryTerm" returntype="string" output="false" access="public">
		<cfargument name="theList" type="string" required="true" />
		<cfargument name="term" type="string" required="true" />
		<cfargument name="count" type="numeric" required="true" />
		
		<cfset var newList = '' />
		<cfset var word = arguments.term />
		
		<cfif (NOT arguments.count)>
			<cfreturn arguments.theList />
		</cfif>
		
		<!--- we're only going to look at classes, everything is disregarded for now --->
		<cfif ListFind('deth,demo,drui,hunt,mage,monk,pala,prie,rogu,sham,warl,warr', arguments.term)>
			<cfreturn ListAppendClass(arguments.theList, GetClassFromTerm(arguments.term), arguments.count+1, false) /> <!--- the +1 guarantees that there are always a plural # of classes to make the grammar correct --->
		<cfelse>
			<!--- just return the list unchanged if not --->
			<cfreturn arguments.theList />
		</cfif>
	</cffunction>	
	
	<cffunction name="Feed" returntype="void" access="public" output="false"
				hint="I am responsible for examining the bottom-most rows of spider data in the db that are missing post bodies, spawning threads to fetch that data, and updated the db where applicable. Death is close.">
		<cfargument name="maxThreads" type="numeric" required="true" />
		
		<cfset var tentacle = 0 />
		<cfset var postBody = '' />
		<cfset var armoryURL = '' />
		<cfset var row = 0 />
		<cfset var id = '' />
	
		<cfquery name="qLinks__FetchAllWithoutBodies" datasource="#variables.dsn#" blockfactor="#arguments.maxThreads#">
			SELECT l.*, s.SiteUUID, s.Hook
			FROM Links l
				INNER JOIN Sites s ON (l.PostID = s.PostID)
			WHERE (l.PostBody = '' OR l.PostBody IS NULL)
			ORDER BY l.PostID
			FETCH FIRST #arguments.maxThreads# ROWS ONLY
		</cfquery>
		
		<cfif qLinks__FetchAllWithoutBodies.recordcount>
		
			<cfloop query="qLinks__FetchAllWithoutBodies">
				
				<cfset id = getTimestamp() />
				
				<cfthread name="__Feed_thread_#qLinks__FetchAllWithoutBodies.currentRow#_#id#"
						  row="#qLinks__FetchAllWithoutBodies.currentRow#"
						  tSiteUUID="#qLinks__FetchAllWithoutBodies.SiteUUID[qLinks__FetchAllWithoutBodies.currentRow]#"
						  tHook="#qLinks__FetchAllWithoutBodies.Hook[qLinks__FetchAllWithoutBodies.currentRow]#"
						  tPostID="#qLinks__FetchAllWithoutBodies.PostID[qLinks__FetchAllWithoutBodies.currentRow]#"
						  tID="#id#"
						  action="run">
					
					<cfset var armoryURL = '' />
					<cfset var tentacle = 0 />
					<cfset var postBody = '' />
					
					<cflog file="Kathune" type="information" text="__Feed_thread_#row#_#tID# - Feeding off of SiteUUID: #tSiteUUID#, Hook: #tHook#, PostID: #tPostID#">
					
					<cfset tentacle = getTentacleBySiteUUID( tSiteUUID ) />
					<cfset postBody = tentacle.fetchPostByHook( tHook ) />
					
					<cfif len(postBody)>
					
						<!--- let's get rid of some shit first --->
						<cfif find('\n', postBody)>
							<cfset postBody = Replace(postBody, '\n', ' ', 'ALL')/>
						</cfif>
	
						<cfset armoryURL = tentacle.fetchArmoryURLFromPost( postBody ) />
						
						<cfquery name="qUpdateLink__Feed_thread#tID#" datasource="#variables.dsn#">
							UPDATE Links
								SET PostBody = '#postBody#',
									ArmoryURL = '#armoryURL#'
							WHERE PostID = #tPostID#
						</cfquery>
						
						<cflog file="Kathune" type="information" text="__Feed_thread_#row#_#tID# - Post Eaten (Body: #len(postBody)# bytes, Armory: #iif(len(armoryURL),de('TRUE'),de('FALSE'))#)">
					
					<cfelse>
					
						<cfquery name="qPurgeLink__Feed_thread#tID#" datasource="#variables.dsn#">
							DELETE FROM Sites WHERE PostID = #tPostID#;
							DELETE FROM Links WHERE PostID = #tPostID#;
						</cfquery>	
						
						<cflog file="Kathune" type="information" text="__Feed_thread_#row#_#tID# - Post Not Found, PostID:#tPostID# purged from database">				
					
					</cfif>
					
				</cfthread>
			
			</cfloop>
			
		</cfif>
	</cffunction>
	
	<cffunction name="FetchXmlFromArmory" returntype="xml" access="public" output="false">
		<cfargument name="url" type="string" required="true" />

		<cfscript>	
		var xmlObject 	= XmlNew();
		var httpVar 	= StructNew();
		var httpResult 	= '';
		var treatedURL	= replace(arguments.url,'&amp;','&','ALL');
		</cfscript>
		
		<cftry>
			<cflog file="Kathune" type="information" text="FetchXmlFromArmory() - Fetching XML From Armory: #treatedURL#">
			
			<cfhttp method="get" url="#treatedURL#" timeout="#variables.timeout#" resolveurl="false" result="httpVar" useragent="#getUserAgent(true)#">
			
			<cfset httpResult = httpVar.fileContent />
			
			<cfif httpResult is "Connection Failure">
				<cfreturn xmlObject />
			</cfif>
			
			<cfcatch type="any">
				<cfreturn xmlObject />
			</cfcatch>
		</cftry>
		
		<cfif isXML(httpResult)>
			<cfset xmlObject = XmlParse(httpResult) />
		</cfif>
		
		<cfif isDefined('xmlObj.page.characterInfo.XmlAttributes.errCode') 
				and xmlobj.page.characterInfo.XmlAttributes.errCode eq 'noCharacter'>
			<cfreturn XmlNew() />
		</cfif>
	
		<cfreturn xmlObject />
	</cffunction>
	
	<cffunction name="BuildUpdateSQLForSingleClass" returntype="string" access="public" output="false">
		<cfargument name="class" type="string" required="true" />
		
		<cfset var sql = '' />
		<cfset var classes = 'DeathKnight,DemonHunter,Druid,Hunter,Mage,Monk,Paladin,Priest,Rogue,Shaman,Warlock,Warrior' />
		<cfset var thisClass = '' />
		
		<cfloop list="#classes#" index="thisClass">
			<cfset sql = sql & 'is' & thisClass & ' = ' & iif(not compareNoCase(thisClass, arguments.class), de('1'), de('0')) />
			<cfif thisClass neq ListLast(classes)>
				<cfset sql = sql & ',' />
			</cfif>
		</cfloop>

		<cfreturn sql />
	</cffunction>	
	
	<cffunction name="ClassIsUnknownInQueryRow" returntype="boolean" access="public" output="false">
		<cfargument name="dataQuery" type="query" required="true">
		<cfargument name="row" type="numeric" required="false" default="1">
		
		<cfif arguments.dataQuery.isDeathKnight[arguments.row] eq 0 and 
			  arguments.dataQuery.isDemonHunter[arguments.row] eq 0 and
			  arguments.dataQuery.isDruid[arguments.row] eq 0 and
			  arguments.dataQuery.isHunter[arguments.row] eq 0 and
			  arguments.dataQuery.isMage[arguments.row] eq 0 and
			  arguments.dataQuery.isMonk[arguments.row] eq 0 and
			  arguments.dataQuery.isPaladin[arguments.row] eq 0 and
			  arguments.dataquery.isPriest[arguments.row] eq 0 and
			  arguments.dataQuery.isRogue[arguments.row] eq 0 and
			  arguments.dataQuery.isShaman[arguments.row] eq 0 and
			  arguments.dataQuery.isWarlock[arguments.row] eq 0 and
			  arguments.dataQuery.isWarrior[arguments.row] eq 0>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="UpdateScoreViaReadability" returntype="numeric" access="public" output="false">
		<cfargument name="currentScore" type="numeric" required="true" />
		<cfargument name="resumeContent" type="string" required="true" />
		
		<cfset var gf = 0 />
		<cfset var fre = 0 />
		<cfset var resume = arguments.resumeContent />
		<cfset var finalScore = arguments.currentScore />
		
		<!--- analyze your post (html/xml stripped completely away)--->
		<cfset resume = stripTags( 'allow', '', resume ) />
		
		<!--- get gunning-fog --->
		<cfset gf = variables.analysis.GunningFogScore( resume ) />
		
		<!--- get flesch-reading-ease --->
		<cfset fre = variables.analysis.FleschReadingEaseScore( resume ) />
		
		<!--- *** GUNNING-FOG *** --->
		<!--- if your gunning fog is 6.0 or less --->
		<cfif gf lte 6>
			<!--- bad stuff happens here --->
			<cfset finalScore = finalScore - 5 />
		</cfif>
		
		<!--- if your gf is 15 (or greater) --->
		<cfif gf gte 15>
			<!--- great stuff happens here (max:75) --->
			<cfset finalScore = finalScore + 25 />	
		</cfif>
		
		<cfif gf gt 10 and gf lt 15>
			<!--- good stuff happens here --->
			<cfset finalScore = finalScore + 10 />
		</cfif>
		
		<cfif gf gt 6 and gf lt 10>
			<!--- adequate stuff happens here --->
			<cfset finalScore = finalScore + 5 />
		</cfif>
		
		<!--- *** FLESCH READING EASE *** --->
		<cfif fre gte 60 and fre lte 70>
			<!--- great stuff happens here (max:100) --->	
			<cfset finalScore = finalScore + 25 />
		</cfif>
		
		<cfif fre lt 60>
			<cfif fre gte 50>
				<!--- 50-60 good stuff --->
				<cfset finalScore = finalScore + 10 />
			</cfif>
			<cfif fre gte 30>
				<!--- 30-50 adequate stuff --->
				<cfset finalScore = finalScore + 5 />
			</cfif>
			<cfif fre lt 30>
				<!--- 0-35 bad stuff --->
				<cfset finalScore = finalScore - 5 />
			</cfif>
		</cfif>

		<cfif fre gt 70>
			<cfif fre lt 80>
				<!--- 70-80 good stuff --->
				<cfset finalScore = finalScore + 10 />
			</cfif>
			<cfif fre lt 95>
				<!--- 80-95 adequate stuff --->
				<cfset finalScore = finalScore + 5 />
			</cfif>
			<cfif fre gte 95>
				<!--- 95-100 bad stuff --->
				<cfset finalScore = finalScore - 5 />
			</cfif>
		</cfif>		
		
		<cfreturn finalScore />
	</cffunction>
	
	<cffunction name="AddRecruitToQueue" returntype="void" access="public" output="false">
		<cfargument name="postID" type="numeric" required="true" />
		
		<cfset var recruit = GetPost( arguments.postID ) />
		
		<cfset ArrayAppend(variables.NewRecruitQueue, recruit) />	
	</cffunction>
	
	<cffunction name="UpdateRecordWithArmory" returntype="void" access="public" output="false">
		<cfargument name="armoryXML" type="xml" required="true" />
		<cfargument name="postID" type="numeric" required="true" />
		
		<cfset var finalScore = 25 /> <!--- you get 25 points just for having posted an armory link --->
		<cfset var character = 0 />
		<cfset var professionScore = 0 />
		<cfset var professions = 0 />
		<cfset var gf = 0 />
		<cfset var fre = 0 />
		<cfset var i = 0 />
		<cfset var data = StructNew() />
		<cfset var faction = '' />
		<cfset var class = '' />
		<cfset var classSQL = '' />
		<cfset var resume = '' />
		
		<cfset var infoQuery = GetPost( arguments.postID ) />
		
		<!--- repair server type --->
		<cfif (infoQuery.isPvP eq 0 and infoQuery.isPvE eq 0)>
			<cfset character = XmlSearch(arguments.armoryXML, '//character')>
				<cfif isArray(character) and
					  ArrayLen(character) and
					  structKeyExists(character[1], 'XmlAttributes')>
				<cfset data = getServerTypeFromTitleByRegion(infoQuery.Region, character[1].XmlAttributes.realm) />
				<!--- 5 points for having a server type (max:30) --->
				<cfset finalScore = finalScore + 5 />
			</cfif>
		</cfif>
		
		<!--- repair faction --->
		<cfif (infoQuery.isAlliance eq 0 and infoQuery.isHorde eq 0)>
			<cfset character = XmlSearch(arguments.armoryXML, '//character')>
			<cfif isArray(character) and
				  ArrayLen(character) and
				  structKeyExists(character[1], 'XmlAttributes')>			
				<cfset faction = character[1].XmlAttributes.faction />
				<!--- 5 points for having a faction (max:35) --->
				<cfset finalScore = finalScore + 5 />
			</cfif>			
		</cfif>
		
		<!--- repair class --->
		<cfif ClassIsUnknownInQueryRow(infoQuery)>
			<cfset character = XmlSearch(arguments.armoryXML, '//character')>
			<cfif isArray(character) and
				  ArrayLen(character) and
				  structKeyExists(character[1], 'XmlAttributes')>			
				<cfset class = character[1].XmlAttributes.class />
				<cfset classSQL = BuildUpdateSQLForSingleClass(class)>
				<!--- 5 points for specifying an individual class (max:40) --->
				<cfset finalScore = finalScore + 5 />				
			</cfif>	
		</cfif>
		
		<!--- use armory info to provide additional data to take the score past 50 --->
		<!--- have you maxed both your professions? --->
		<cfset professions = XmlSearch(arguments.armoryXML, '//professions')>
		<cfif isArray(professions) and
				ArrayLen(professions) and
				StructKeyExists(professions[1], 'XmlChildren') and
				ArrayLen(professions[1].XmlChildren) >
			<cfloop from="1" to="#ArrayLen(professions[1].XmlChildren)#" index="i">
				<cfif professions[1].XmlChildren[i].XmlAttributes.value eq professions[1].XmlChildren[i].XmlAttributes.max>
					<cfset professionScore = professionScore + 1 >
				</cfif>
			</cfloop>
			<!--- 5 points for each maxxed profession (10 total) (max:50) --->
			<cfset finalScore = finalScore + (5 * professionScore) />
		</cfif>
		
		<!--- tack on readability analysis --->
		<cfset finalScore = UpdateScoreViaReadability(finalScore, infoQuery.PostBody) />
		
		<!--- penalize them if they are an idiot --->
		<cfif infoQuery.isIdiot eq 1>
			<cfset finalScore = finalScore - 5 />
		</cfif>
		
		<!--- *sigh* you just failed as a guidly, player, and human being --->
		<cfif finalScore lte 1>
			<cfset finalScore = 5 />
		</cfif>
		
		<cfquery name="qUpdateLink__WithArmory" datasource="#variables.dsn#">
			UPDATE Links
				SET score = #finalScore#<cfif not structIsEmpty(data)>,
				isPvP = #data.isPvP#,
				isPvE = #data.isPvE#</cfif><cfif len(faction)>,
				<cfif faction is 'Horde'>isHorde = 1<cfelse>isAlliance = 1</cfif></cfif><cfif len(classSQL)>,
				#classSQL#</cfif>
			WHERE PostID = #arguments.postID#
		</cfquery>
		
		<cflog file="Kathune" type="information" text="UpdateRecordWithArmory() - PostID: #arguments.postID# updated with a score of #finalScore#">		
	</cffunction>	
	
	<cffunction name="UpdateRecordWithoutArmory" returntype="void" access="public" output="false">
		<cfargument name="postID" type="numeric" required="true" />
		
		<cfset var finalScore = 5 /> <!--- 5 just for showing up --->
		
		<!--- without a provided armory URL, the maximum score you can achieve is xx --->
		<cfset var infoQuery = GetPost( arguments.postID ) />
		
		<!--- validate server type --->
		<cfif (infoQuery.isPvP eq 1 OR infoQuery.isPvE eq 1)>
			<!--- 5 points for having a server type (max:10) --->
			<cfset finalScore = finalScore + 5 />
		</cfif>
		
		<!--- validate faction --->
		<cfif (infoQuery.isAlliance eq 1 OR infoQuery.isHorde eq 1)>
			<!--- 5 points for having a faction (max:15) --->
			<cfset finalScore = finalScore + 5 />			
		</cfif>
		
		<!--- validate class --->
		<cfif NOT ClassIsUnknownInQueryRow(infoQuery)>
			<!--- 5 points for having any class of any type (max:20) --->
			<cfset finalScore = finalScore + 5 />					
		</cfif>
		
		<!--- tack on readability analysis (max:70) --->
		<cfset finalScore = UpdateScoreViaReadability(finalScore, infoQuery.PostBody) />
		
		<!--- penalize them if they are an idiot --->
		<cfif infoQuery.isIdiot eq 1>
			<cfset finalScore = finalScore - 5 />
		</cfif>
		
		<!--- *sigh* you just failed as a guidly, player, and human being --->
		<cfif finalScore lte 1>
			<cfset finalScore = 5 />
		</cfif>

		<cfquery name="qUpdateLink__WithoutArmory" datasource="#variables.dsn#">
			UPDATE Links
				SET score = #finalScore#
			WHERE PostID = #arguments.postID#
		</cfquery>
		
		<cflog file="Kathune" type="information" text="UpdateRecordWithoutArmory() - PostID: #arguments.postID# updated with a score of #finalScore#">		
	</cffunction>	
	
	<cffunction name="Digest" returntype="void" access="public" output="false"
				hint="I am responsible performing final scoring on newly entered records of data. When I complete scoring, the record is considered valid and is produced in search results. Your heart will explode.">
		<cfargument name="maxThreads" type="numeric" required="true" />
		
		<cfset var tentacle = 0 />
		<cfset var postBody = '' />
		<cfset var armoryURL = '' />
		<cfset var row = 0 />
		<cfset var id = '' />
	
		<cfquery name="qLinks__FetchAllWithBaseScore" datasource="#variables.dsn#" blockfactor="#arguments.maxThreads#">
			SELECT l.*, s.SiteUUID, s.Hook
			FROM Links l
				INNER JOIN Sites s ON (l.PostID = s.PostID)
			WHERE (l.PostBody <> '' AND l.PostBody IS NOT NULL)
			AND (l.Score = 1)
			ORDER BY l.PostID
			FETCH FIRST #arguments.maxThreads# ROWS ONLY		
		</cfquery>
		
		<cfif qLinks__FetchAllWithBaseScore.recordcount>
		
			<cfloop query="qLinks__FetchAllWithBaseScore">
				
				<cfset id = getTimestamp() />
				
				<cfthread name="__Digest_thread_#qLinks__FetchAllWithBaseScore.currentRow#_#id#"
						  row="#qLinks__FetchAllWithBaseScore.currentRow#"
						  tSiteUUID="#qLinks__FetchAllWithBaseScore.SiteUUID[qLinks__FetchAllWithBaseScore.currentRow]#"
						  tHook="#qLinks__FetchAllWithBaseScore.Hook[qLinks__FetchAllWithBaseScore.currentRow]#"
						  tPostID="#qLinks__FetchAllWithBaseScore.PostID[qLinks__FetchAllWithBaseScore.currentRow]#"
						  tArmoryURL="#qLinks__FetchAllWithBaseScore.ArmoryURL[qLinks__FetchAllWithBaseScore.currentRow]#"
						  tID="#id#"
						  action="run">
					
					<cfset var tentacle = 0 />
					<cfset var postBody = '' />
					<cfset var score = 0 />
					<cfset var xmlData = XmlNew() />
					
					<cflog file="Kathune" type="information" text="__Digest_thread_#row#_#tID# - Digesting SiteUUID: #tSiteUUID#, Hook: #tHook#, PostID: #tPostID#">
					
					<!--- does it have an ArmoryURL? --->
					<cfif len(tArmoryURL)>
					
						<!--- attempt to fetch the record --->
						<cfset xmlData = FetchXmlFromArmory( tArmoryURL ) />

						<!--- if you get a response from the armory, perform the scoring, otherwise, we'll skip this record and it will be re-attempted at a future pass --->
						<cfif NOT StructIsEmpty(xmlData)>
							
							<cflog file="Kathune" type="information" text="__Digest_thread_#row#_#tID# - Armory Info Detected for PostID: #tPostID#, calling UpdateRecordWithArmory()">
							
							<cfset UpdateRecordWithArmory( xmlData, tPostID ) />
							
							<cfset AddRecruitToQueue( tPostID ) />
							
						</cfif>
						
					<cfelse>
					
						<cflog file="Kathune" type="information" text="__Digest_thread_#row#_#tID# - No Armory Info for PostID: #tPostID#, calling UpdateRecordWithoutArmory()">
					
						<!--- there is no armory data to speak of, so they'll get the peasant-level rating system applied --->
						<cfset UpdateRecordWithoutArmory( tPostID ) />
						
						<cfset AddRecruitToQueue( tPostID ) />
						
					</cfif>
					
				</cfthread>
			
			</cfloop>
			
		</cfif>
	</cffunction>	
	
	<cffunction name="Boast" returntype="void" output="false" access="public"
				hint="I update historical data when appropriate. You will betray your friends.">
		<cfscript>
			var NumPosts 			= 0;
			var NumAlliance 		= 0;
			var NumHorde 			= 0;
			var NumPvP 				= 0;
			var NumPvE 				= 0;
			var NumIdiots 			= 0;
			var NumDruids 			= 0;
			var NumDeathKnights 	= 0;
			var NumDemonHunters		= 0;
			var NumHunters 			= 0;
			var NumMages 			= 0;
			var NumMonks			= 0;
			var NumPaladins 		= 0;
			var NumPriests 			= 0;
			var NumRogues 			= 0;
			var NumShamans 			= 0;
			var NumWarlocks 		= 0;
			var NumWarriors 		= 0;
			var NumUS 				= 0;
			var NumEU 				= 0;
			var NumArmory 			= 0;
			
			//step 1. find out what last month was, and determine if we have data for that month, which should correlate to the 1st of that month.
			
			var lastMonthDate 		= dateAdd( "m", -1, now() );
			var checkDateStart 		= createDate( year(lastMonthDate), month(lastMonthDate), 1 );
			var checkDateEnd 		= createDate( year(lastMonthDate), month(lastMonthDate), daysInMonth(lastMonthDate) );
		</cfscript>
		
		<cfquery name="dateCheck" datasource="#variables.dsn#">
			SELECT HistoryID
			FROM History
			WHERE EffectiveDate = #CreateODBCDate(checkDateStart)#
		</cfquery>
		
		<cfif not dateCheck.recordCount>
		
			<!--- it does not exist, so let's load up the stats for the month --->
			<cfquery name="statOne" datasource="#variables.dsn#">
				SELECT count(PostID) as NumPosts
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
			</cfquery>
			
			<cfset NumPosts = statOne.NumPosts />
			
			<cfquery name="statTwo" datasource="#variables.dsn#">
				SELECT count(PostID) as NumAlliance
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isAlliance = 1
			</cfquery>
			
			<cfset NumAlliance = statTwo.NumAlliance />			
			
			<cfquery name="statThree" datasource="#variables.dsn#">
				SELECT count(PostID) as NumHorde
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isHorde = 1
			</cfquery>
			
			<cfset NumHorde = statThree.NumHorde />			
			
			<cfquery name="statFour" datasource="#variables.dsn#">
				SELECT count(PostID) as NumPvP
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isPvP = 1
			</cfquery>
			
			<cfset NumPvP = statFour.NumPvP />		
			
			<cfquery name="statFive" datasource="#variables.dsn#">
				SELECT count(PostID) as NumPvE
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isPvE = 1
			</cfquery>
			
			<cfset NumPvE = statFive.NumPvE />				
			
			<cfquery name="statSix" datasource="#variables.dsn#">
				SELECT count(PostID) as NumIdiots
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isIdiot = 1
			</cfquery>
			
			<cfset NumIdiots = statSix.NumIdiots />		
			
			<cfquery name="statSeven" datasource="#variables.dsn#">
				SELECT count(PostID) as NumDruids
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isDruid = 1
			</cfquery>
			
			<cfset NumDruids = statSeven.NumDruids />
			
			<cfquery name="statSevenPointFive" datasource="#variables.dsn#">
				SELECT count(PostID) as NumDeathKnights
				FROM LINKS
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isDeathKnight = 1				
			</cfquery>
			
			<cfset NumDeathKnights = statSevenPointFive.NumDeathKnights />					
			
			<cfquery name="statSevenPointSevenFive" datasource="#variables.dsn#">
				SELECT count(PostID) as NumDemonHunters
				FROM LINKS
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isDemonHunter = 1				
			</cfquery>
			
			<cfset NumDemonHunters = statSevenPointSevenFive.NumDemonHunters />					

			<cfquery name="statEight" datasource="#variables.dsn#">
				SELECT count(PostID) as NumHunters
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isHunter = 1
			</cfquery>
			
			<cfset NumHunters = statEight.NumHunters />		
			
			<cfquery name="statNine" datasource="#variables.dsn#">
				SELECT count(PostID) as NumMages
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isMage = 1
			</cfquery>
			
			<cfset NumMages = statNine.NumMages />

			<cfquery name="statNinePointFive" datasource="#variables.dsn#">
				SELECT count(PostID) as NumMonks
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isMonk = 1
			</cfquery>
			
			<cfset NumMonks = statNinePointFive.NumMonks />
			
			<cfquery name="statTen" datasource="#variables.dsn#">
				SELECT count(PostID) as NumPaladins
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isPaladin = 1
			</cfquery>
			
			<cfset NumPaladins = statTen.NumPaladins />		
			
			<cfquery name="statEleven" datasource="#variables.dsn#">
				SELECT count(PostID) as NumPriests
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isPriest = 1
			</cfquery>
			
			<cfset NumPriests = statEleven.NumPriests />					
			
			<cfquery name="statTwelve" datasource="#variables.dsn#">
				SELECT count(PostID) as NumRogues
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isRogue = 1
			</cfquery>
			
			<cfset NumRogues = statTwelve.NumRogues />					
			
			<cfquery name="statThirteen" datasource="#variables.dsn#">
				SELECT count(PostID) as NumShamans
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isShaman = 1
			</cfquery>
			
			<cfset NumShamans = statThirteen.NumShamans />	
			
			<cfquery name="statFourteen" datasource="#variables.dsn#">
				SELECT count(PostID) as NumWarlocks
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isWarlock = 1
			</cfquery>
			
			<cfset NumWarlocks = statFourteen.NumWarlocks />
			
			<cfquery name="statFifteen" datasource="#variables.dsn#">
				SELECT count(PostID) as NumWarriors
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND isWarrior = 1
			</cfquery>
			
			<cfset NumWarriors = statFifteen.NumWarriors />		
			
			<cfquery name="statSixteen" datasource="#variables.dsn#">
				SELECT count(PostID) as NumUS
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND Region = 'US'
			</cfquery>
			
			<cfset NumUS = statSixteen.NumUS />		
			
			<cfquery name="statSeventeen" datasource="#variables.dsn#">
				SELECT count(PostID) as NumEU
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND Region = 'EU-EN'
			</cfquery>
			
			<cfset NumEU = statSeventeen.NumEU />		
			
			<cfquery name="statEighteen" datasource="#variables.dsn#">
				SELECT count(PostID) as NumArmory
				FROM Links
				WHERE EffectiveDate >= #CreateODBCDate(checkDateStart)#
				AND EffectiveDate <= #CreateODBCDate(checkDateEnd)#
				AND ArmoryURL IS NOT NULL
				AND ArmoryURL <> ''
			</cfquery>
			
			<cfset NumArmory = statEighteen.NumArmory />						

			<!--- we've got em! now let's cache them into History --->
			<cfquery name="ins" datasource="#variables.dsn#">
				INSERT INTO History (
					EffectiveDate,
					NumPosts,
					NumAlliance,
					NumHorde,
					NumPvP,
					NumPvE,
					NumIdiots,
					NumDeathKnights,
					NumDemonHunters,
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
					#NumDemonHunters#,
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
	
	<cffunction name="ExtendTentacles" returntype="void" access="public" output="false"
				hint="I am responsible for spawning threads for each registered spider URL, firing the spiders, and retrieving the data they collect. Your friends will abandon you.">
	
		<cfset var i = 0 />
		<cfset var id = '' />

		<cfloop from="1" to="#variables.httpFetchMaximum#" index="i">
			
			<cfset variables.activeTentacle = variables.activeTentacle + 1 />
			
			<cfif variables.activeTentacle gt ArrayLen(variables.tentacles)>
				<cfset variables.activeTentacle = 1 />
			</cfif>
			
			<!--- <cflog file="Kathune" type="information" text="ExtendTentacles() - Spawning thread for tentacle in Array index #variables.activeTentacle#"> --->
			
			<cfset id = getTimestamp() />
			
			<cfthread name="__ExtendTentacle_thread#i#_#id#" tentacle="#variables.tentacles[variables.activeTentacle]#" action="run">
				
				<cfset tentacle.Grab() />
				
				<!--- <cfset thread.html = tentacle.getHTML() /> ---> <!--- for debugging only --->
				
				<cfset RetrieveFoodFromTentacle( tentacle ) />
			
			</cfthread>
		
		</cfloop>
		
	</cffunction>
	
	<cffunction name="RetrieveFoodFromTentacle" returntype="void" access="private" output="false"
				hint="I examine an individual spider for fetched data, confirm that it has people looking for guilds, and insert only those into the db that I have not yet already collected. You are already dead.">
		<cfargument name="tentacle" type="struct" required="true" />
		
		<cfset var postArray = arguments.tentacle.getPostsAsObjectArray() />
		<cfset var thisPostObj = 0 />
		<cfset var i = 0 />

		<cfloop from="1" to="#arrayLen(postArray)#" index="i">
			<cfset thisPostObj = postArray[i] />
			
			<!--- if the post has been scored as a person looking for a guild, and it doesn't already exist, insert --->
			<cfif thisPostObj.getScore() gt 0 AND NOT PostExists( arguments.tentacle.getSiteUUID(), thisPostObj.getHookValue() )>
				
				<cftransaction>
					
					<cfquery name="qInsert" datasource="#variables.dsn#">
						insert into Links(PostURL, 
							  PostTitle, 
							  PostBody,
							  isAlliance,
							  isHorde,
							  isPvP,
							  isPvE,
							  isIdiot,
							  isDeathKnight,
							  isDemonHunter,
							  isDruid,
							  isHunter,
							  isMage,
							  isMonk,
							  isPaladin,
							  isPriest,
							  isRogue,
							  isShaman,
							  isWarlock,
							  isWarrior,
							  Score,
							  Region,
							  ArmoryURL)
						values('#thisPostObj.getPostURL()#',
							   '#replace(thisPostObj.getPostTitle(),"'","''","ALL")#',
							   '#thisPostObj.getPostBody()#',
							   #thisPostObj.isAlliance()#,
							   #thisPostObj.isHorde()#,
							   #thisPostObj.isPvP()#,
							   #thisPostObj.isPvE()#,
							   #thisPostObj.isIdiot()#,
							   #thisPostObj.isDeathKnight()#,
							   #thisPostObj.isDemonHunter()#,
							   #thisPostObj.isDruid()#,
							   #thisPostObj.isHunter()#,
							   #thisPostObj.isMage()#,
							   #thisPostObj.isMonk()#,
							   #thisPostObj.isPaladin()#,
							   #thisPostObj.isPriest()#,
							   #thisPostObj.isRogue()#,
							   #thisPostObj.isShaman()#,
							   #thisPostObj.isWarlock()#,
							   #thisPostObj.isWarrior()#,
							   #thisPostObj.getScore()#,
							   '#thisPostObj.getRegion()#',
							   '#thisPostObj.getArmoryURL()#')
						returning postid AS IDENTITY_PKEY;
					</cfquery>
					
					<cfset thisPostObj.setPostID(qInsert.IDENTITY_PKEY) />
					
					<cfquery name="ins_join" datasource="#variables.dsn#">
						INSERT INTO Sites(PostID, SiteUUID, Hook)
						VALUES(#thisPostObj.getPostID()#, '#arguments.tentacle.getSiteUUID()#', '#thisPostObj.getHookValue()#')
					</cfquery>
					
				</cftransaction>
				
			</cfif>
			
		</cfloop>		
	</cffunction>
	
	<cffunction name="getTentacleBySiteUUID" returntype="com.hanzo.cf.Kathune.KathuneTentacle" access="private" output="false">
		<cfargument name="siteUUID" type="any" required="true" />
		
		<cfset var i = 0 />
		
		<cfloop from="1" to="#arrayLen(variables.tentacles)#" index="i">
			<cfif not compareNoCase( variables.tentacles[i].getSiteUUID(), arguments.siteUUID )>
				<cfreturn variables.tentacles[i] />
			</cfif>
		</cfloop>
	
		<!--- should never happen, but we'll add incase threading causes me grief --->
		<cfthrow type="Tentacle.NotFound" message="A tentacle with the provided SiteUUID was not found" detail="You have provided a SiteUUID to this function (#arguments.SiteUUID#) which does not match a tentacle in the Kathune::variables.tentacles array." />
	</cffunction>	
	
	<cffunction name="PostExists" returntype="boolean" access="private" output="false">
		<cfargument name="siteuuid" type="string" required="true" />
		<cfargument name="hook" type="string" required="true" />

		<cfquery name="qTestForPost" datasource="#variables.dsn#">
			SELECT l.PostID
			FROM Links l
				INNER JOIN Sites s ON (l.PostID = s.PostID)
			WHERE s.Hook = '#arguments.hook#'
			AND s.SiteUUID = '#arguments.siteuuid#'
		</cfquery>

		<!--- <cflog file="Kathune" type="information" text="PostExists() Records: #qTestForPost.RecordCount# - SQL: SELECT l.PostID FROM Links l INNER JOIN Sites s ON (l.PostID = s.PostID) WHERE s.Hook = '#arguments.hook#' AND s.SiteUUID = '#arguments.siteuuid#'"> --->
		
		<cfreturn (qTestForPost.recordCount gt 0) />
	</cffunction>
	
	<cffunction name="GetPost" returntype="query" access="private" output="false">
		<cfargument name="postID" type="numeric" required="true" />
		
		<cfset var qPost__Fetch = 0 />
		
		<cfquery name="qPost__Fetch" datasource="#variables.dsn#" blockfactor="1">
			SELECT l.*, s.SiteUUID, s.Hook
			FROM Links l
				INNER JOIN Sites s ON (l.PostID = s.PostID)
			WHERE l.PostID = #arguments.postID#
		</cfquery>
		
		<cfreturn qPost__Fetch />
	</cffunction>
	
	<cffunction name="GetStatistics" returntype="query" access="public" output="false">

		<cfset var qStatistics__Fetch = 0 />
		<cfset var lastMonthDate = dateAdd("m", -1, now()) />
		<cfset var checkDateStart = createDate(year(lastMonthDate), month(lastMonthDate), 1) />
		
		<cfquery name="qStatistics__Fetch" datasource="#variables.dsn#" blockfactor="1" cachedWithin="#createTimeSpan(1,0,0,0)#">
			SELECT *
			FROM History
			WHERE EffectiveDate = #CreateODBCDate(checkDateStart)#
			AND 1=1
		</cfquery>
		
		<cfreturn qStatistics__Fetch />	
	</cffunction>
	
	<cffunction name="GetRSSFeedTitle" returntype="string" access="public" output="false">
		<cfargument name="fac" type="string" required="false" default="" />
		<cfargument name="serv" type="string" required="false" default="" />
		<cfargument name="clas" type="string" required="false" default="" />
		<cfargument name="regi" type="string" required="false" default="" />
		<cfargument name="idiotFilter" type="numeric" required="false" default="0" />
		<cfargument name="maxrows" type="numeric" required="false" default="50" />
		<cfargument name="page" type="numeric" required="false" default="1" />
		<cfargument name="keyword" type="string" required="false" default="" />	

		<cfscript>
			var title = '';
	
			if (len(arguments.regi)) {
				if (arguments.regi is 'US')
					title = title & 'US ';
				else if (arguments.regi is 'EU-EN')
					title = title & 'Europe ';
			}
			
			if (len(arguments.fac)) {
				if (arguments.fac is 'a')
					title = title & 'Alliance ';
				else if (arguments.fac is 'h')
					title = title & 'Horde ';
			}
			
			if (len(arguments.serv)) {
				if (arguments.serv is 'pvp')
					title = title & 'PvP ';
				else if (arguments.serv is 'pve')
					title = title & 'PvE ';
			}
			
			if (len(arguments.clas)) {
				if (arguments.clas is "rogu")
					title = title & 'Rogues ';
				else if (arguments.clas is "deth")
					title = title & 'Death Knights ';
				else if (arguments.clas is "demo")
					title = title & 'Demon Hunters ';
				else if (arguments.clas is "drui")
					title = title & 'Druids ';
				else if (arguments.clas is "mage")
					title = title & 'Mages ';
				else if (arguments.clas is "monk")
					title = title & 'Monks ';
				else if (arguments.clas is "warr")
					title = title & 'Warriors ';
				else if (arguments.clas is "warl")
					title = title & 'Warlocks ';
				else if (arguments.clas is "hunt")
					title = title & 'Hunters ';
				else if (arguments.clas is "sham")
					title = title & 'Shamans ';
				else if (arguments.clas is "pala")
					title = title & 'Paladins ';
				else if (arguments.clas is "prie")
					title = title & 'Priests ';
			}
	
			if (arguments.idiotFilter eq 1)
				title = title & '(No Idiots)';
				
			// prepend - if there is one at all
			if (len(title))
				title = ' - ' & title;
		</cfscript>

		<cfreturn title />
	</cffunction>
	
	<cffunction name="GetRSS" returntype="xml" access="public" output="false">
		<cfargument name="fac" type="string" required="false" default="" />
		<cfargument name="serv" type="string" required="false" default="" />
		<cfargument name="clas" type="string" required="false" default="" />
		<cfargument name="regi" type="string" required="false" default="" />
		<cfargument name="idiotFilter" type="numeric" required="false" default="0" />
		<cfargument name="maxrows" type="numeric" required="false" default="50" />
		<cfargument name="page" type="numeric" required="false" default="1" />
		<cfargument name="keyword" type="string" required="false" default="" />
		
		<cfset var columnMapStruct = structNew() />
		<cfset var meta = structNew() />
		<cfset var rssXML = '' />
		<cfset var data = GetRecruits(argumentCollection=arguments) />
		
		<!--- prep query for RSS --->
		<cfset QueryAddColumn(data, 'SOURCE', ArrayNew(1) ) />
		<cfset QueryAddColumn(data, 'SOURCEURL', ArrayNew(1) ) />
		
		<cfloop query="data">
			<cfset QuerySetCell(data, 'SOURCE', getTentacleBySiteUUID(data.SiteUUID[data.currentRow]).getSource(), data.currentRow) />
			<cfset QuerySetCell(data, 'SOURCEURL', getTentacleBySiteUUID(data.SiteUUID[data.currentRow]).getForumURL(), data.currentRow) />
		</cfloop>
		
		<!--- Map the orders column names to the feed query column names. --->
		<cfset columnMapStruct.title = "POSTTITLE" />
		<cfset columnMapStruct.content = "POSTBODY" />
		<cfset columnMapStruct.publisheddate = "EFFECTIVEDATE" /> 
		<cfset columnMapStruct.rsslink = "POSTURL" />
		<cfset columnMapStruct.source = "SOURCE" />
		<cfset columnMapStruct.sourceURL = "SOURCEURL" />

		<!--- Set the feed metadata. --->
		<cfset meta.title = "WoW Lemmings" & GetRSSFeedTitle(argumentCollection=arguments) />
		<cfset meta.link = "http://www.wowlemmings.com/" />
		<cfset meta.description = "Rebuild your guild." /> 
		<cfset meta.version = "rss_2.0" />
		
		<!--- Create the feed. --->
		<cffeed action="create" query="#data#" properties="#meta#" columnMap="#columnMapStruct#" xmlvar="rssXML">
		
		<cfreturn XmlParse(rssXML) />
	</cffunction>
	
	<cffunction name="GetTotal" returntype="query" output="false" access="public">
		<cfargument name="fac" type="string" required="false" default="" />
		<cfargument name="serv" type="string" required="false" default="" />
		<cfargument name="clas" type="string" required="false" default="" />
		<cfargument name="regi" type="string" required="false" default="" />
		<cfargument name="idiotFilter" type="numeric" required="false" default="0" />
		<cfargument name="maxrows" type="numeric" required="false" default="50" />
		<cfargument name="page" type="numeric" required="false" default="1" />
		<cfargument name="keyword" type="string" required="false" default="" />
		
		<cfset var qTotal__Fetch = 0 />
		
		<cfquery name="qTotal__Fetch" datasource="#variables.dsn#" blockfactor="#maxrows#" cachedWithin="#createTimeSpan(0,0,30,0)#">  <!--- it's cached based on the timer of the repopulation schedule --->
		  SELECT Count(PostID) as records
		   FROM 
		     Links
				WHERE 0=0
			<cfif arguments.fac is "a">
				AND isAlliance = 1
			<cfelseif arguments.fac is "h">
				AND isHorde = 1
			</cfif>
			<cfif arguments.serv is "pvp">
				AND isPvP = 1
			<cfelseif arguments.serv is "pve">
				AND isPvE = 1
			</cfif>
			<cfif arguments.clas is "rogu">
				AND isRogue = 1
			<cfelseif arguments.clas is "deth">
				AND isDeathKnight = 1
			<cfelseif arguments.clas is "demo">
				AND isDemonHunter = 1
			<cfelseif arguments.clas is "drui">
				AND isDruid = 1
			<cfelseif arguments.clas is "mage">
				AND isMage = 1
			<cfelseif arguments.clas is "monk">
				AND isMonk = 1
			<cfelseif arguments.clas is "warr">
				AND isWarrior = 1
			<cfelseif arguments.clas is "warl">
				AND isWarlock = 1
			<cfelseif arguments.clas is "hunt">
				AND isHunter = 1
			<cfelseif arguments.clas is "sham">
				AND isShaman = 1
			<cfelseif arguments.clas is "pala">
				AND isPaladin = 1
			<cfelseif arguments.clas is "prie">
				AND isPriest = 1
			</cfif>
			<cfif arguments.idiotFilter eq 1>
				AND isIdiot = 0
			</cfif>	
			<cfif arguments.regi is "us">
				AND Region = 'US'
			<cfelseif arguments.regi is "eu-en">
				AND Region = 'EU-EN'
			</cfif>
			<cfif len(trim(arguments.keyword))>
				AND (PostTitle LIKE '%#trim(arguments.keyword)#%' OR CONTAINS(PostBody, '"#trim(arguments.keyword)#"'))
			</cfif>
				AND Score > 1
		</cfquery>

		<cfreturn qTotal__Fetch />	
	</cffunction>
	
	<cffunction name="GetRecruits" returntype="query" output="false" access="public">
		<cfargument name="fac" type="string" required="false" default="" />
		<cfargument name="serv" type="string" required="false" default="" />
		<cfargument name="clas" type="string" required="false" default="" />
		<cfargument name="regi" type="string" required="false" default="" />
		<cfargument name="idiotFilter" type="numeric" required="false" default="0" />
		<cfargument name="maxrows" type="numeric" required="false" default="50" />
		<cfargument name="page" type="numeric" required="false" default="1" />
		<cfargument name="keyword" type="string" required="false" default="" />

		<cfset var qRecruits__Fetch = 0 />

		<cfquery name="qRecruits__Fetch" datasource="#variables.dsn#" blockfactor="#maxrows#" cachedWithin="#createTimeSpan(0,0,30,0)#">
			WITH LinksBlock AS
			(
			    SELECT ROW_NUMBER() OVER(ORDER BY EffectiveDate DESC, Links.PostID) AS RowNum, Links.*, Sites.SiteUUID, Sites.Hook
			    FROM Links
			    	INNER JOIN Sites ON (Links.PostID = Sites.PostID)
				WHERE 0=0
				<cfif arguments.fac is "a">
					AND isAlliance = 1
				<cfelseif arguments.fac is "h">
					AND isHorde = 1
				</cfif>
				<cfif arguments.serv is "pvp">
					AND isPvP = 1
				<cfelseif arguments.serv is "pve">
					AND isPvE = 1
				</cfif>
				<cfif arguments.clas is "rogu">
					AND isRogue = 1
				<cfelseif arguments.clas is "deth">
					AND isDeathKnight = 1
				<cfelseif arguments.clas is "demo">
					AND isDemonHunter = 1
				<cfelseif arguments.clas is "drui">
					AND isDruid = 1
				<cfelseif arguments.clas is "mage">
					AND isMage = 1
				<cfelseif arguments.clas is "monk">
					AND isMonk = 1
				<cfelseif arguments.clas is "warr">
					AND isWarrior = 1
				<cfelseif arguments.clas is "warl">
					AND isWarlock = 1
				<cfelseif arguments.clas is "hunt">
					AND isHunter = 1
				<cfelseif arguments.clas is "sham">
					AND isShaman = 1
				<cfelseif arguments.clas is "pala">
					AND isPaladin = 1
				<cfelseif arguments.clas is "prie">
					AND isPriest = 1
				</cfif>
				<cfif arguments.idiotFilter eq 1>
					AND isIdiot = 0
				</cfif>	
				<cfif arguments.regi is "us">
					AND Region = 'US'
				<cfelseif arguments.regi is "eu-en">
					AND Region = 'EU-EN'
				</cfif>
				<cfif len(trim(arguments.keyword))>
					AND (PostTitle LIKE '%#trim(arguments.keyword)#%' OR CONTAINS(PostBody, '"#trim(arguments.keyword)#"'))
				</cfif>
				AND Score > 1
			)
			
			SELECT * 
			FROM LinksBlock
			WHERE RowNum 
			BETWEEN (#arguments.page# - 1) * #arguments.maxrows# + 1 
			AND #arguments.page# * #arguments.maxrows#
			ORDER BY EffectiveDate DESC
		</cfquery>
		
		<cfreturn qRecruits__Fetch />
	</cffunction>
	
	<cffunction name="getUserAgent" returntype="string" output="false" access="public">
		<cfargument name="isStealthed" type="boolean" required="false" default="false" />
		
		<cfif arguments.isStealthed>
			<cfreturn 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.1' />
		<cfelse>
			<cfreturn variables.user_agent />
		</cfif>
	</cffunction>

	<cffunction name="produceAccessToken" returntype="void" output="false" access="public">
		<cfargument name="verifier" type="string" required="true" />
		
		<cfset var returnData = variables.twitter.getAccessToken( 
				requestToken	= 	variables.oAuthToken,
				requestSecret	= 	variables.oAuthTokenSecret,
				verifier		=	arguments.verifier ) />	
	
		<cfif (returnData.success)>
			<cfset variables.accessToken = returnData.token />
			<cfset variables.accessSecret = returnData.token_secret />			
			<cfset variables.screen_name = returnData.screen_name />			
			<cfset variables.user_id = returnData.user_id />			
			
			<cfset variables.twitter.setFinalAccessDetails(
				oauthToken			= 	variables.accessToken,
				oauthTokenSecret	=	variables.accessSecret,
				userAccountName		=	variables.screen_name ) />
		</cfif>
	</cffunction>
		
	
	
	
	
	
	
	
	
	
	
	<!--- UTILITIES --->
	<cffunction name="getClassFromTerm" returntype="string" access="public" output="false">
		<cfargument name="term" type="string" required="true" />
		
		<cfswitch expression="#arguments.term#">
			<cfcase value="deth">
				<cfreturn "Death Knight" />
			</cfcase>
			<cfcase value="demo">
				<cfreturn "Demon Hunter" />
			</cfcase>
			<cfcase value="drui">
				<cfreturn "Druid" />
			</cfcase>
			<cfcase value="hunt">
				<cfreturn "Hunter" />
			</cfcase>
			<cfcase value="mage">
				<cfreturn "Mage" />
			</cfcase>
			<cfcase value="monk">
				<cfreturn "Monk" />
			</cfcase>
			<cfcase value="pala">
				<cfreturn "Paladin" />
			</cfcase>
			<cfcase value="prie">
				<cfreturn "Priest" />
			</cfcase>
			<cfcase value="rogu">
				<cfreturn "Rogue" />
			</cfcase>
			<cfcase value="sham">
				<cfreturn "Shaman" />
			</cfcase>
			<cfcase value="warl">
				<cfreturn "Warlock" />
			</cfcase>
			<cfcase value="warr">
				<cfreturn "Warrior" />
			</cfcase>
			<cfdefaultcase>
				<cfreturn "Player" /><!--- should NEVER happen --->
			</cfdefaultcase>
		</cfswitch>
	</cffunction>
	
	<cffunction name="getTimestamp" returntype="string" access="public" output="false">
		
		<cfreturn DateFormat( now(), 'yyyymmdd' ) & TimeFormat( now(), 'HHmmssL') />
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
			<cfif findNoCase(qryServers.ServerName[currentRow], arguments.txt) OR 
					( len(qryServers.ServerRegExp[currentRow]) and reFindNoCase(qryServers.ServerRegExp[currentRow], arguments.txt) )>
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
				
				<cfbreak /> <!--- cut out of the loop now to save cycles --->
			</cfif>
		</cfloop>
		
		<cfreturn data />		
	</cffunction>	

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
	
	<cffunction name="dumpInternals" output="true" access="public" returntype="void">
		<cfdump var=#variables#>
	</cffunction>
	
</cfcomponent>