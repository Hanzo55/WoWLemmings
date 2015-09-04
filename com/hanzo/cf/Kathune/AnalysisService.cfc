<cfcomponent name="AnalysisService" output="false">

	<cfset this.Tokenizer = '([aeiouy]{1,3})' />

	<cffunction name="SyllableCount" returntype="numeric" access="remote" output="false">
		<cfargument name="text" type="string" required="true" />

		<cfscript>
			var word 	= arguments.text;
			var wlen 	= 0;
			var got 	= 0;
			var matches = 0;
	
			if ( (!CompareNoCase( right(word, 3), 'ing' )) and (Len(word) gt 3) ) {
				wlen++;
				word = left( word, len(word)-3 );
			}

			got = REMatch( this.Tokenizer, word );
			matches = ArrayLen(got);    
	    	wlen += matches;
	
			if ( matches > 1 && !CompareNoCase( right(got[matches], 1), 'e' ) &&
				!CompareNoCase( right(word, 1), 'e') &&
				CompareNoCase( right(word, 2), 'l') )
				wlen--;
				
			return wlen;
		</cfscript>
	</cffunction>

	<cffunction name="CountOfWordsBySyllableMinimum" returntype="numeric" access="remote" output="false">
		<cfargument name="content" type="string" required="true" />
		<cfargument name="minSyllables" type="numeric" required="true" />
		
		<cfset var count = 0 />
		<cfset var thisWord = '' />
		
		<cfloop list="#arguments.content#" index="thisWord" delimiters=" ">
			<cfif len(thisWord) and SyllableCount(thisWord) gte arguments.minSyllables>
				<cfset count = count + 1 />
			</cfif>
		</cfloop>
		
		<cfreturn count />
	</cffunction>

	<cffunction name="GunningFogScore" returntype="numeric" access="remote" output="false"
				hint="How many years of schooling it would take to understand the text. Lower = More Understandable. Results over 17 should be reported as 17 (Post-Grad).">
		<cfargument name="content" type="string" required="true" />
		
		<cfset var score = 0 />
		<cfset var i = 0 />
		<cfset var avgWords = 0 />
		<cfset var difficultWords = 0 />
		<cfset var numWordsInSentence = arrayNew(1) />
		
		<!--- tokenize by a period. --->
		<cfset var sentenceArray = listToArray(arguments.content, '. ') />
		
		<cfloop from="1" to="#arrayLen(sentenceArray)#" index="i">
			
			<!--- words this sentence --->
			<cfset numWordsInSentence[i] = listLen(sentenceArray[i], ' ') />
			
		</cfloop>
		
		<!--- calculate average number of words per sentence --->
		<cfset avgWords = ArrayAvg(numWordsInSentence) />
		
		<!--- get count of difficult words in sample (3+ syllables) --->
		<cfset difficultWords = CountOfWordsBySyllableMinimum(arguments.content, 3) />
		
		<!--- add totals together, multiple by four --->
		<cfset score = (avgWords + difficultWords) * 0.4 />
		
		<cfreturn score />
	</cffunction>
	
	<cffunction name="FleschReadingEaseScore" returntype="numeric" access="remote" output="false"
				hint="1-100 scale rating on readability. Authors should aim for 60-70.">
		<cfargument name="content" type="string" required="true" />
		
		<cfset var score = 0 />
		<cfset var i = 0 />
		<cfset var j = 0 />
		<cfset var avgWords = 0 />
		<cfset var avgSyllables = 0 />
		<cfset var numWordsInSentence = arrayNew(1) />
		<cfset var numSyllablesInWord = arrayNew(1) />
		<cfset var thisWord = '' />
		
		<!--- tokenize by a period. --->
		<cfset var sentenceArray = listToArray(arguments.content, '. ') />
		
		<cfloop from="1" to="#ArrayLen(sentenceArray)#" index="i">
			
			<!--- words this sentence --->
			<cfset numWordsInSentence[i] = ListLen(sentenceArray[i], ' ') />
	
			<cfloop list="#sentenceArray[i]#" index="thisWord" delimiters=" ">
	
				<!--- num of syllables in this word of that above sentence --->			
				<cfset ArrayAppend(numSyllablesInWord, SyllableCount(thisWord)) />
				
			</cfloop>
			
		</cfloop>
		
		<!--- calculate average number of words per sentence --->
		<cfset avgWords = ArrayAvg(numWordsInSentence) />
		
		<!--- Calculate the average number of syllables per word --->
		<cfset avgSyllables = ArrayAvg(numSyllablesInWord) />
		
		<cfset score = 206.835 - (1.015 * avgWords) - (84.6 * avgSyllables) />
		
		<cfreturn score />
	</cffunction>
	
</cfcomponent>