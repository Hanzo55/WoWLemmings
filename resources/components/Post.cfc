<cfcomponent displayname="Post" output="false">
	
	<cffunction name="init" returntype="resources.components.Post" access="public" output="false">
		<cfargument name="postID" type="numeric" required="false" default="-1" />
		<cfargument name="postTitle" type="string" required="false" default="" />
		<cfargument name="postBody" type="string" required="false" default="" />
		<cfargument name="isAlliance" type="boolean" required="false" default="false" />
		<cfargument name="isHorde" type="boolean" required="false" default="false" />
		<cfargument name="isPvP" type="boolean" required="false" default="false" />
		<cfargument name="isPvE" type="boolean" required="false" default="false" />
		<cfargument name="isIdiot" type="boolean" required="false" default="false" />
		<cfargument name="isDeathKnight" type="boolean" required="false" default="false" />
		<cfargument name="isDruid" type="boolean" required="false" default="false" />
		<cfargument name="isHunter" type="boolean" required="false" default="false" />
		<cfargument name="isMage" type="boolean" required="false" default="false" />
		<cfargument name="isMonk" type="boolean" required="false" default="false" />
		<cfargument name="isPaladin" type="boolean" required="false" default="false" />
		<cfargument name="isPriest" type="boolean" required="false" default="false" />
		<cfargument name="isRogue" type="boolean" required="false" default="false" />
		<cfargument name="isShaman" type="boolean" required="false" default="false" />
		<cfargument name="isWarlock" type="boolean" required="false" default="false" />
		<cfargument name="isWarrior" type="boolean" required="false" default="false" />
		<cfargument name="score" type="numeric" required="false" default="0" />
		<cfargument name="hook" type="string" required="false" default="" />
		<cfargument name="region" type="string" required="false" default="" />
		<cfargument name="armoryURL" type="string" required="false" default="" />
		<cfargument name="source" type="string" required="false" default="" />
		
		<cfscript>
		variables.instanceData = structNew();
		
		variables.instanceData.postID 			= arguments.postID;
		variables.instanceData.postTitle 		= arguments.postTitle;
		variables.instanceData.postBody 		= arguments.postBody;
		variables.instanceData.isAlliance 		= arguments.isAlliance;
		variables.instanceData.isHorde 			= arguments.isHorde;
		variables.instanceData.isPvP 			= arguments.isPvP;
		variables.instanceData.isPvE 			= arguments.isPvE;
		variables.instanceData.isIdiot 			= arguments.isIdiot;
		variables.instanceData.isDeathKnight 	= arguments.isDeathKnight;
		variables.instanceData.isDruid 			= arguments.isDruid;
		variables.instanceData.isHunter 		= arguments.isHunter;
		variables.instanceData.isMage 			= arguments.isMage;
		variables.instanceData.isMonk			= arguments.isMonk;
		variables.instanceData.isPaladin 		= arguments.isPaladin;
		variables.instanceData.isPriest 		= arguments.isPriest;
		variables.instanceData.isRogue 			= arguments.isRogue;
		variables.instanceData.isShaman 		= arguments.isShaman;
		variables.instanceData.isWarlock 		= arguments.isWarlock;
		variables.instanceData.isWarrior 		= arguments.isWarrior;
		variables.instanceData.score 			= arguments.score;
		variables.instanceData.hook 			= arguments.hook;
		variables.instanceData.region 			= arguments.region;
		variables.instanceData.armoryURL 		= arguments.armoryURL;
		variables.instanceData.source 			= arguments.source;
		</cfscript>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getPostID" returntype="numeric" access="public" output="false">
		
		<cfreturn variables.instanceData.postID />
		
	</cffunction>

	<cffunction name="setPostID" returntype="void" access="public" output="false">
		<cfargument name="postID" type="numeric" required="true" />
		
		<cfset variables.instanceData.postID = arguments.postID />
	</cffunction>
	
	<cffunction name="getPostTitle" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.postTitle />
		
	</cffunction>

	<cffunction name="setPostTitle" returntype="void" access="public" output="false">
		<cfargument name="postTitle" type="string" required="true" />
		
		<cfset variables.instanceData.postTitle = arguments.postTitle />
	</cffunction>
	
	<cffunction name="getPostBody" returntype="string" access="public" output="false">
		
		<cfreturn variables.instanceData.postBody />
		
	</cffunction>

	<cffunction name="setPostBody" returntype="void" access="public" output="false">
		<cfargument name="postBody" type="string" required="true" />
		
		<cfset variables.instanceData.postBody = arguments.postBody />
	</cffunction>	

	<cffunction name="getIsAlliance" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.isAlliance />
		
	</cffunction>

	<cffunction name="setIsAlliance" returntype="void" access="public" output="false">
		<cfargument name="isAlliance" type="boolean" required="true" />
		
		<cfset variables.instanceData.isAlliance = arguments.isAlliance />
	</cffunction>
	
	<cffunction name="getIsHorde" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.isHorde />
		
	</cffunction>

	<cffunction name="setIsHorde" returntype="void" access="public" output="false">
		<cfargument name="isHorde" type="boolean" required="true" />
		
		<cfset variables.instanceData.isHorde = arguments.isHorde />
	</cffunction>	

	<cffunction name="getIsPvP" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.isPvP />
		
	</cffunction>

	<cffunction name="setIsPvP" returntype="void" access="public" output="false">
		<cfargument name="isPvP" type="boolean" required="true" />
		
		<cfset variables.instanceData.isPvP = arguments.isPvP />
	</cffunction>
	
	<cffunction name="getIsPvE" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.isPvE />
		
	</cffunction>

	<cffunction name="setIsPvE" returntype="void" access="public" output="false">
		<cfargument name="isPvE" type="boolean" required="true" />
		
		<cfset variables.instanceData.isPvE = arguments.isPvE />
	</cffunction>	
	
	<cffunction name="getIsIdiot" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.IsIdiot />
		
	</cffunction>

	<cffunction name="setIsIdiot" returntype="void" access="public" output="false">
		<cfargument name="isIdiot" type="boolean" required="true" />
		
		<cfset variables.instanceData.isIdiot = arguments.isIdiot />
	</cffunction>	
	
	<cffunction name="getIsDeathKnight" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.isDeathKnight />
		
	</cffunction>

	<cffunction name="setIsDeathKnight" returntype="void" access="public" output="false">
		<cfargument name="isDeathKnight" type="boolean" required="true" />
		
		<cfset variables.instanceData.isDeathKnight = arguments.isDeathKnight />
	</cffunction>	
	
	<cffunction name="getIsDruid" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.isDruid />
		
	</cffunction>

	<cffunction name="setIsDruid" returntype="void" access="public" output="false">
		<cfargument name="isDruid" type="boolean" required="true" />
		
		<cfset variables.instanceData.isDruid = arguments.isDruid />
	</cffunction>	
	
	<cffunction name="getIsHunter" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.isHunter />
		
	</cffunction>

	<cffunction name="setIsHunter" returntype="void" access="public" output="false">
		<cfargument name="isHunter" type="boolean" required="true" />
		
		<cfset variables.instanceData.isHunter = arguments.isHunter />
	</cffunction>	
	
	<cffunction name="getIsMage" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.isMage />
		
	</cffunction>

	<cffunction name="setIsMage" returntype="void" access="public" output="false">
		<cfargument name="isMage" type="boolean" required="true" />
		
		<cfset variables.instanceData.isMage = arguments.isMage />
	</cffunction>	

	<cffunction name="getIsMonk" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.isMonk />
		
	</cffunction>

	<cffunction name="setIsMonk" returntype="void" access="public" output="false">
		<cfargument name="isMonk" type="boolean" required="true" />
		
		<cfset variables.instanceData.isMonk = arguments.isMonk />
	</cffunction>	
	
	<cffunction name="getIsPaladin" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.isPaladin />
		
	</cffunction>

	<cffunction name="setIsPaladin" returntype="void" access="public" output="false">
		<cfargument name="isPaladin" type="boolean" required="true" />
		
		<cfset variables.instanceData.isPaladin = arguments.isPaladin />
	</cffunction>	
	
	<cffunction name="getIsPriest" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.isPriest />
		
	</cffunction>

	<cffunction name="setIsPriest" returntype="void" access="public" output="false">
		<cfargument name="isPriest" type="boolean" required="true" />
		
		<cfset variables.instanceData.isPriest = arguments.isPriest />
	</cffunction>
	
	<cffunction name="getIsRogue" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.isRogue />
		
	</cffunction>

	<cffunction name="setIsRogue" returntype="void" access="public" output="false">
		<cfargument name="isRogue" type="boolean" required="true" />
		
		<cfset variables.instanceData.isRogue = arguments.isRogue />
	</cffunction>		
	
	<cffunction name="getIsShaman" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.isShaman />
		
	</cffunction>

	<cffunction name="setIsShaman" returntype="void" access="public" output="false">
		<cfargument name="isShaman" type="boolean" required="true" />
		
		<cfset variables.instanceData.isShaman = arguments.isShaman />
	</cffunction>	
	
	<cffunction name="getIsWarlock" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.isWarlock />
		
	</cffunction>

	<cffunction name="setIsWarlock" returntype="void" access="public" output="false">
		<cfargument name="isWarlock" type="boolean" required="true" />
		
		<cfset variables.instanceData.isWarlock = arguments.isWarlock />
	</cffunction>	
	
	<cffunction name="getIsWarrior" returntype="boolean" access="public" output="false">
		
		<cfreturn variables.instanceData.isWarrior />
		
	</cffunction>

	<cffunction name="setIsWarrior" returntype="void" access="public" output="false">
		<cfargument name="isWarrior" type="boolean" required="true" />
		
		<cfset variables.instanceData.isWarrior = arguments.isWarrior />
	</cffunction>	
	
	<cffunction name="getScore" returntype="numeric" access="public" output="false">
		
		<cfreturn variables.instanceData.score />
		
	</cffunction>

	<cffunction name="setScore" returntype="void" access="public" output="false">
		<cfargument name="score" type="numeric" required="true" />
		
		<cfset variables.instanceData.score = arguments.score />
	</cffunction>	

	<cffunction name="getHook" returntype="string" access="public" output="false">
		
		<cfreturn variables.instanceData.hook />
		
	</cffunction>

	<cffunction name="setHook" returntype="void" access="public" output="false">
		<cfargument name="hook" type="string" required="true" />
		
		<cfset variables.instanceData.hook = arguments.hook />
	</cffunction>
	
	<cffunction name="getRegion" returntype="string" access="public" output="false">
		
		<cfreturn variables.instanceData.region />
		
	</cffunction>

	<cffunction name="setRegion" returntype="void" access="public" output="false">
		<cfargument name="region" type="string" required="true" />
		
		<cfset variables.instanceData.region = arguments.region />
	</cffunction>	
	
	<cffunction name="getArmoryURL" returntype="string" access="public" output="false">
		
		<cfreturn variables.instanceData.armoryURL />
		
	</cffunction>

	<cffunction name="setArmoryURL" returntype="void" access="public" output="false">
		<cfargument name="armoryURL" type="string" required="true" />
		
		<cfset variables.instanceData.armoryURL = arguments.armoryURL />
	</cffunction>
	
	<cffunction name="getSource" returntype="string" access="public" output="false">
		
		<cfreturn variables.instanceData.source />
		
	</cffunction>

	<cffunction name="setSource" returntype="void" access="public" output="false">
		<cfargument name="source" type="string" required="true" />
		
		<cfset variables.instanceData.source = arguments.source />
	</cffunction>	
	
	
	
	<!--- *** Convenience Wrappers *** --->
	<cffunction name="isAlliance" returntype="boolean" access="public" output="false">
		
		<cfreturn getIsAlliance() />
		
	</cffunction>

	<cffunction name="isHorde" returntype="boolean" access="public" output="false">
		
		<cfreturn getIsHorde() />
		
	</cffunction>
	
	<cffunction name="isPvP" returntype="boolean" access="public" output="false">
		
		<cfreturn getIsPvP() />
		
	</cffunction>
	
	<cffunction name="isPvE" returntype="boolean" access="public" output="false">
		
		<cfreturn getIsPvE() />
		
	</cffunction>
	
	<cffunction name="isIdiot" returntype="boolean" access="public" output="false">
		
		<cfreturn getIsIdiot() />
		
	</cffunction>
	
	<cffunction name="isDeathKnight" returntype="boolean" access="public" output="false">
		
		<cfreturn getIsDeathKnight() />
		
	</cffunction>
	
	<cffunction name="isDruid" returntype="boolean" access="public" output="false">
		
		<cfreturn getIsDruid() />
		
	</cffunction>
	
	<cffunction name="isHunter" returntype="boolean" access="public" output="false">
		
		<cfreturn getIsHunter() />
		
	</cffunction>
	
	<cffunction name="isMage" returntype="boolean" access="public" output="false">
		
		<cfreturn getIsMage() />
		
	</cffunction>

	<cffunction name="isMonk" returntype="boolean" access="public" output="false">
		
		<cfreturn getIsMonk() />
		
	</cffunction>
	
	<cffunction name="isPaladin" returntype="boolean" access="public" output="false">
		
		<cfreturn getIsPaladin() />
		
	</cffunction>
	
	<cffunction name="isPriest" returntype="boolean" access="public" output="false">
		
		<cfreturn getIsPriest() />
		
	</cffunction>
	
	<cffunction name="isRogue" returntype="boolean" access="public" output="false">
		
		<cfreturn getIsRogue() />
		
	</cffunction>
	
	<cffunction name="isShaman" returntype="boolean" access="public" output="false">
		
		<cfreturn getIsShaman() />
		
	</cffunction>
	
	<cffunction name="isWarlock" returntype="boolean" access="public" output="false">
		
		<cfreturn getIsWarlock() />
		
	</cffunction>
	
	<cffunction name="isWarrior" returntype="boolean" access="public" output="false">
		
		<cfreturn getIsWarrior() />
		
	</cffunction>

</cfcomponent>