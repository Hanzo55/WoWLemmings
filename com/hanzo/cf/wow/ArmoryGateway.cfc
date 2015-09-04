<cfcomponent output="false">

	<!--- ** ArmoryGateway.cfc: ColdFusion wrapper for fetching/parsing XML from the WoWArmory.com ** --->
	
	<!--- ** CONSTRUCTOR ** --->
	
	<cfset variables.user_agent = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6 (.NET CLR 3.5.30729)' />
	<cfset variables.current_region = 'us' />
	
	<cfset variables.wowarmory['us'] = 'http://www.wowarmory.com' />
	<cfset variables.wowarmory['eu-en'] = 'http://eu.wowarmory.com' />
		
	<!--- ** PUBLIC METHODS ** --->
	
	<cffunction name="SetRegion" returntype="void" access="public" output="false">
		<cfargument name="region" type="string" required="true" />
		
		<cfif NOT StructKeyExists( variables.wowarmory, arguments.region )>
			<cfthrow type="ArmoryGateway.UnknownRegion" 
					message="The specified region is unknown or has no equivalent armory URL" 
					detail="The specified region, #arguments.region#, doesn't match any of the registered WoW Armory URLs in the tool." />
		</cfif>

		<cfset variables.current_region = LCase(arguments.region) />	
	</cffunction>	

	<cffunction name="GetArmoryURL" returntype="string" access="public" output="false">
		
		<cfreturn variables.wowarmory[variables.current_region] />
	</cffunction>
	
	<cffunction name="GetPlayersInGuild" returntype="struct" access="public" output="false">
		<cfargument name="guildName" type="string" required="true" />
		<cfargument name="realmName" type="string" required="true" />
		<cfargument name="maxRank" type="numeric" required="false" />

		<cfset var players = StructNew() />
		<cfset var httpResult = 0 />
		<cfset var data = 0 />
		<cfset var thisCharacter = 0 />
		<cfset var thisCharacterStruct = 0 />
		<cfset var thisAttribute = 0 />
		<cfset var rank = 10 />
		
		<cfif StructKeyExists( arguments, 'maxRank' )>
			<cfset rank = arguments.maxRank />
		</cfif>

		<cftry>
			<cfhttp url="#variables.wowarmory[variables.current_region]#/guild-info.xml?r=#URLEncodedFormat(arguments.realmName)#&n=#URLEncodedFormat(arguments.guildName)#"
					method="GET"
					result="httpResult"
					useragent="#variables.user_agent#"
					timeout="15" 
					throwonerror="true" />
			
			<cfcatch type="any">
				<cfthrow type="ArmoryGateway.ConnectionFailure" message="Unable to process a response from the WoW Armory." detail="There was a problem connecting to/processing the XML response from the WoW Armory." />
			</cfcatch>
		</cftry>
		
		<cfset data = XMLParse( httpResult.fileContent ) />
		
		<cfloop array="#data.page.guildInfo.guild.members.XmlChildren#" index="thisCharacter">
			
			<cfif thisCharacter.XmlAttributes['rank'] LTE rank>
			
				<cfset thisCharacterStruct = StructNew() />

				<cfloop list="#StructKeyList(thisCharacter.XmlAttributes)#" index="thisAttribute">

					<cfif CompareNoCase(thisAttribute,'name')>

						<cfset thisCharacterStruct['#thisAttribute#'] = thisCharacter.XmlAttributes[thisAttribute] />

					</cfif>

				</cfloop>

				<cfset players['#thisCharacter.XmlAttributes['name']#'] = thisCharacterStruct />

			</cfif>

		</cfloop>

		<cfreturn players />
	</cffunction>

</cfcomponent>