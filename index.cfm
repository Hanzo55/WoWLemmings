<cfsetting enablecfoutputonly="yes">

<cfif NOT findNoCase('lc.wowlemmings.com', CGI.HTTP_HOST) >
	<cfheader name="Expires" value="#GetHttpTimeString(dateAdd('n', 30, now()) )#"> <!--- cache for 30 minutes --->
	<cfheader name="Cache-Control" value="max-age=1800"> <!--- cache for 30 minutes --->
</cfif>

<cfajaximport csssrc="/" />

<cfset Randomize(Second(now())) />

<cfparam name="pref_region" default="US">
<cfparam name="pref_server" default="NONE">
<cfparam name="fac" default="">
<cfparam name="serv" default="">
<cfparam name="clas" default="">
<cfparam name="regi" default="">
<cfparam name="idiotFilter" default="0">
<cfparam name="maxrows" default="50">
<cfparam name="page" default="1">
<cfparam name="keyword" default="">

<cfset variables.preservedTags = "br,b,p" />
<cfset variables.templateName = getFileFromPath(getBaseTemplatePath()) />

<cfif isDefined('COOKIE.WL_Post')>
	<cfset variables.cookiePrefs = COOKIE.WL_Post />
<cfelse>
	<cfset variables.cookiePrefs = '' />
</cfif>

<cfif isDefined('COOKIE.WL_Server')>
	<cfset pref_server = COOKIE.WL_Server />
</cfif>

<cfset variables.cookieArray = listToArray(variables.cookiePrefs) />

<cfset total = request.kathune.GetTotal(argumentCollection=url) />
<cfset qryResults = request.kathune.GetRecruits(argumentCollection=url) />
<cfset stats = request.kathune.GetStatistics() />

<cffunction name="getPrefIconByPost" output="false" returntype="string">
	<cfargument name="postID" type="numeric" required="yes">
	
	<cfset var pref = 0 />
	
	<cfloop from="1" to="#arrayLen(variables.cookieArray)#" index="i">
		<cfif find(':', variables.cookieArray[i]) and listGetAt(variables.cookieArray[i],1,':') eq arguments.postID>
			<cfset pref = listGetAt(variables.cookieArray[i],2,':') />
			<cfbreak />
		</cfif>
	</cfloop>
	
	<cfswitch expression="#pref#">
		<cfcase value="-1">
			<cfreturn 'thumbs_down.gif' />
		</cfcase>
		<cfcase value="0">
			<cfreturn 'unknown.gif' />
		</cfcase>
		<cfcase value="1">
			<cfreturn 'thumbs_up.gif' />
		</cfcase>
	</cfswitch>
</cffunction>

<cffunction name="getLink" output="false" returntype="string">
	<cfargument name="newPage" type="numeric" required="yes">
	<cfscript>
		var link = '#variables.templateName#?';
		
		link = link & 'page=' & arguments.newPage;
		link = link & '&regi=' & regi;
		link = link & '&fac=' & fac;
		link = link & '&serv=' & serv;
		link = link & '&clas=' & clas;
		link = link & '&idiotFilter=' & idiotFilter;
		link = link & '&keyword=' & keyword;
	</cfscript>
	
	<cfreturn link />
</cffunction>

<cffunction name="getRSS" output="false" returntype="string">
	<cfscript>
		var link = 'rss.cfm?'; // rss feeds will only return the newest top 50. no page needed

		link = link & 'regi=' & regi;
		link = link & '&fac=' & fac;
		link = link & '&serv=' & serv;
		link = link & '&clas=' & clas;
		link = link & '&idiotFilter=' & idiotFilter;
		link = link & '&keyword=' & keyword;
	</cfscript>
	
	<cfreturn link />
</cffunction>

<cffunction name="getColor" output="false" returntype="string">
	<cfargument name="data" type="query" required="true">
	<cfargument name="row" type="numeric" required="true">
	
	<cfif data.isRogue[row]>
		<cfreturn "yellow">
	<cfelseif data.isDeathKnight[row]>
		<cfreturn "bf0000">
	<cfelseif data.isDruid[row]>
		<cfreturn "orange">
	<cfelseif data.isShaman[row]>
		<cfreturn "blue">
	<cfelseif data.isMage[row]>
		<cfreturn "00ffff">
	<cfelseif data.isMonk[row]>
		<cfreturn "00ff96">
	<cfelseif data.isPaladin[row]>
		<cfreturn "pink">
	<cfelseif data.isPriest[row]>
		<cfreturn "silver">
	<cfelseif data.isWarrior[row]>
		<cfreturn "brown">
	<cfelseif data.isWarlock[row]>
		<cfreturn "purple">
	<cfelseif data.isHunter[row]>
		<cfreturn "green">
	<cfelse>
		<cfreturn "white">
	</cfif>
</cffunction>

<cffunction name="getClassColor" output="false" returntype="string">
	<cfargument name="data" type="query" required="true">
	<cfargument name="row" type="numeric" required="true">
	
	<cfif data.isRogue[row]>
		<cfreturn "rogue">
	<cfelseif data.isDeathKnight[row]>
		<cfreturn "deathknight">
	<cfelseif data.isDruid[row]>
		<cfreturn "druid">
	<cfelseif data.isShaman[row]>
		<cfreturn "shaman">
	<cfelseif data.isMage[row]>
		<cfreturn "mage">
	<cfelseif data.isMonk[row]>
		<cfreturn "monk">
	<cfelseif data.isPaladin[row]>
		<cfreturn "paladin">
	<cfelseif data.isPriest[row]>
		<cfreturn "priest">
	<cfelseif data.isWarrior[row]>
		<cfreturn "warrior">
	<cfelseif data.isWarlock[row]>
		<cfreturn "warlock">
	<cfelseif data.isHunter[row]>
		<cfreturn "hunter">
	<cfelse>
		<cfreturn "unknown">
	</cfif>
</cffunction>

<cffunction name="getClassCombos" output="false" returntype="string">
	<cfargument name="data" type="query" required="true">
	<cfargument name="row" type="numeric" required="true">
	
	<cfscript>
		var strList = '';
		var count = 0;
	</cfscript>
	
	<cfif data.isRogue[row]>
		<cfset strList = strList & "R" />
		<cfset count = count + 1 />
	</cfif>
	
	<cfif data.isDeathKnight[row]>
		<cfset strList = strList & "Dk" />
		<cfset count = count + 1 />
	</cfif>
	
	<cfif data.isDruid[row]>
		<cfset strList = strList & "D" />
		<cfset count = count + 1 />
	</cfif>	
		
	<cfif data.isShaman[row]>
		<cfset strList = strList & "S" />
		<cfset count = count + 1 />
	</cfif>	
		
	<cfif data.isMage[row]>
		<cfset strList = strList & "M" />
		<cfset count = count + 1 />
	</cfif>

	<cfif data.isMonk[row]>
		<cfset strList = strList & "Mo" />
		<cfset count = count + 1 />
	</cfif>
	
	<cfif data.isPaladin[row]>
		<cfset strList = strList & "Pa" />
		<cfset count = count + 1 />
	</cfif>
	
	<cfif data.isPriest[row]>	
		<cfset strList = strList & "Pr" />
		<cfset count = count + 1 />
	</cfif>

	<cfif data.isWarrior[row]>
		<cfset strList = strList & "W" />
		<cfset count = count + 1 />
	</cfif>	
	
	<cfif data.isWarlock[row]>
		<cfset strList = strList & "Wk" />
		<cfset count = count + 1 />
	</cfif>
	
	<cfif data.isHunter[row]>
		<cfset strList = strList & "H" />
		<cfset count = count + 1 />
	</cfif>
	
	<cfif count gte 2>
		<cfreturn strList />
	<cfelse>
		<cfreturn "&nbsp;" />
	</cfif>
</cffunction>

<cffunction name="getBalloon" output="false" returntype="string">
	<cfargument name="strBody" type="string" required="true">
	
	<cfscript>
		var balloon = '';
		var strip = '';
		
		// start
		balloon = '<span class="tooltip"><span class="top"></span><span class="middle">';
		
		// trim out the whitespace crap/CRs/newlines/linefeeds/tabs.
		strip = trim(stripCR(arguments.strBody));
		strip = replace(strip,chr(10),'','ALL');
		strip = replace(strip,chr(13),'','ALL');
		strip = replace(strip,chr(9),'','ALL');
		
		// get rid of "post edited by"
		strip = rereplacenocase(strip,'\<p\>\<small\>\<font color="red"\>\[ Post edited by [A-Za-z]+ \]\<br/\>\</font\>\</small\>\</p\>','','ALL');
		
		// strip other html crap out
		strip = request.Kathune.stripTags('allow', variables.preservedTags, strip);		
		
		// finally, strip out armory links
		strip = rereplacenocase(strip,'http://(armory.worldofwarcraft.com|www.wowarmory.com|wowarmory.com|armory.wow-europe.com|eu.wowarmory.com)/(.*)\.xml\?r=([A-Z|''| |%20|%27|\+]+)(&amp;|&)n=([A-Z]+)','','ALL');

		// after all is said and done, did we strip everything away?
		if (not len(strip))
			strip = 'No Informational Post.';
		// or is it over 400 chars?
		else if (len(strip) gt 400)
			strip = wordTrim(strip, 400) & "...";

		// prepare the end end
		balloon = balloon & strip & '</span><span class="bottom"></span></span>';
	</cfscript>
	
	<cfreturn balloon />
</cffunction>

<cffunction name="getPagination" output="false" returntype="string">
	<cfscript>
		var pagStr = '';
		var maxRange = 10;
		var offset = 5; // the position in where we start shifting
		var absoluteEnd = ceiling(evaluate(total.records/maxrows));
		var start = 0;
		var end = 0;
	</cfscript>
	
	<cfif total.records gt maxrows>
		<cfset pagStr = "Jump to page: " />
		
		<cfif page gt 1>
			<cfset pagStr = pagStr & '<a href="#getLink(page-1)#">&laquo;</a> '>
		</cfif>
		 
		<cfif (page gte offset) and (absoluteEnd gt maxRange)>
			<cfif (page + 1) eq absoluteEnd>
				<cfset start = page - offset>
			<cfelseif page eq absoluteEnd>
				<cfset start = page - (offset + 1)>
			<cfelse>
				<cfset start = page - (offset - 1)>
			</cfif>
			
			<cfset end = iif(page + (offset - 1) lt absoluteEnd, page + (offset - 1), absoluteEnd)>
		<cfelse>
			<cfset start = 1>
			<cfset end = iif(absoluteEnd gt maxRange, maxRange, absoluteEnd)>
		</cfif>	
		
		<cfloop from="#start#" to="#end#" index="i">
			<cfif i eq page>
				<cfset pagStr = pagStr & '<b>[ #i# ]</b>'>
			<cfelse>
				<cfset pagStr = pagStr & '<a href="#getLink(i)#">#i#</a>'>
			</cfif>
			
			<cfif i lt end>
				<cfset pagStr = pagStr & '&nbsp;'>
			</cfif>
		</cfloop>
		
		<cfif page lt end>
			<cfset pagStr = pagStr & ' <a href="#getLink(page+1)#">&raquo;</a>'>
		</cfif>
	</cfif>

	<cfreturn pagStr />
</cffunction>

<cffunction name="wordTrim" output="false" returntype="string">
	<cfargument name="strTrim" type="string" required="true">
	<cfargument name="maxLen" type="numeric" required="true">
	
	<cfscript>
		var trimmed = '';
		var finalTrimmed = '';
		var i=0;
		
		// trim it first
		trimmed = left(arguments.strTrim, arguments.maxLen);
		
		// start backing up from the end until you find a single space, and break there.
		for (i = len(trimmed); i gt 1; i=i-1) {
			charAt = mid(trimmed, i, 1);
			if (charAt is ' ') {
				finalTrimmed = left(trimmed, i);
				break;
			}
		}
	</cfscript>
	
	<cfreturn finalTrimmed />
</cffunction>

<cfset AdType = RandRange(0,2) />

<!--- Capture the Query_String --->
<cfset request.kathune.AddSearchToQueue(CGI.QUERY_STRING) />

<cfsetting enablecfoutputonly="no"><!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta name="google-site-verification" content="iMw37iuFFGOa6_TDaUrNmoqq1m6oJ109oJq1lrharbo" />
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<META NAME="Description" CONTENT="WoW Lemmings is the definitive World of Warcraft guild recruitment tool. It aggregates player information from all known WoW fan sites and recruitment forums, and delivers it through a fast, filterable interface. Subscribe to your own personalized RSS feed, which gives you only the players and classes you want. Stop wasting time traversing site after site, looking for the perfect candidate; get back in the game and let WoW Lemmings do it for you. Rebuild your guild. Now.">
	<META NAME="Keywords" CONTENT="World of Warcraft, Guild, Recruitment, Guildies, Guild Search, Recruiting, Player, Player Search, Class, Class Search, Faction, Faction Search, PvP, PvE, Alliance, Horde, Rogue, Shaman, Druid, Death Knight, Warrior, Warlock, Hunter, Priest, Paladin, Monk, GROM, Guild Online Recruitment Mechanism, AdServer, Advertising, Advertisement">
	<title>WoW Lemmings : Rebuild your guild.</title>
	<link rel="alternate" type="application/rss+xml" title="WoW Lemmings" href="<cfoutput>#getRSS()#</cfoutput>" />
	<link href="/css/wowlemmings.cfm" rel="stylesheet" type="text/css" /> <!--- hanzo: added to the bottom of /resources/css/cf.css --->
	<script language="Javascript">
	function doAlert() {
		var pay = readCookie('lemmingspay');
		if (!pay || pay != 1) {
		alert('**A Request From WoWLemmings.com**\n\nPlease consider a donation to help support WoWLemmings.com. We have been providing recruits for over a year and accrued only a few dollars in return. Hosting is NOT FREE. Click the *DONATE* button on this page if you wish to help keep WoWLemmings.com running!');
		createCookie('lemmingspay',1,365);
		}
	}	
	</script>
</head>
<body onLoad="populateServers();preselectServer();">
<div id="container">
  <div id="header">
    <h1>WoW Lemmings</h1>
    <h1 class="tagline">Rebuild your guild.</h1>
	<br/>
	<div align="center" id="<cfif AdType NEQ 1>advert_noborder<cfelse>advert</cfif>"><br/>
	<!---
	<script type="text/javascript" src="http://www.wowlemmings.com/adserver/adserver.cfm?a=54100709-FF86-68E4-63F495A84BF9683E"></script>
	--->
	<cfif AdType eq 0>
			<script type="text/javascript"><!--
			google_ad_client = "pub-6215660586764867";
			/* WoWLemmings-Top Banner */
			google_ad_slot = "5199871562";
			google_ad_width = 728;
			google_ad_height = 90;
			//-->
			</script>
			<script type="text/javascript"
			src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
			</script>
	<cfelseif AdType eq 1>
			<a name='b_9270abb00cf9012db580000d60d4c902'></a><object classid='clsid:d27cdb6e-ae6d-11cf-96b8-444553540000' codebase='http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0' width='205' height='350' id='badge9270abb00cf9012db580000d60d4c902' align='middle'>
			<param name='allowScriptAccess' value='always' />
			<param name='allowNetworking' value='all' />
			<param name='movie' value='https://giving.paypallabs.com/flash/badge.swf' />
			<param name='quality' value='high' />
			<param name='bgcolor' value='#FFFFFF' />
			<param name='wmode' value='transparent' />
			<param name='FlashVars' value='Id=9270abb00cf9012db580000d60d4c902'/>
			<embed src='https://giving.paypallabs.com/flash/badge.swf' FlashVars='Id=9270abb00cf9012db580000d60d4c902' quality='high' bgcolor='#FFFFFF' wmode='transparent' width='205' height='350' Id='badge9270abb00cf9012db580000d60d4c902' align='middle' allowScriptAccess='always' allowNetworking='all' type='application/x-shockwave-flash' pluginspage='http://www.macromedia.com/go/getflashplayer'></embed>
			</object>	
	
			<!--<h2>Finding recruits a little easier now?</h2> 
			<h3>Please Support WoW Lemmings so that it may continue!</h3>
			<form action="https://www.paypal.com/cgi-bin/webscr" method="post">
		<input type="hidden" name="cmd" value="_s-xclick">
		<input type="hidden" name="encrypted" value="-----BEGIN PKCS7-----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-----END PKCS7-----">
			<input type="image" src="/images/btn_donate_LG.gif" border="0" name="submit" alt="Make payments with PayPal - it's fast, free and secure!">
			</form>-->
	<cfelse>
			<a href="http://www.enjin.com/?ref=584563" target="_blank"><img src="/images/enjin-banner-wow.jpg" border="0"></a>
			<!--- <a href="http://www.pokersavvy.com/#24329"><img src="http://www.pokersavvy.com/_images2/banners/banner809.gif" border="0" alt="PokerSavvy"></a> --->
	</cfif>
		<br/>
	</div>
  </div>
  <div class="clr"></div>
  <div id="content">
    <table width="920" border="0" cellspacing="0" cellpadding="0" id="mainSearch">
	  <cfform name="frmSearch" action="#variables.templateName#" method="get">
      <tr>
        <td><p>Region
            <select name="regi">
					<option value=""<cfif regi is ""> selected</cfif>>Any</option>
					<option value="us"<cfif regi is "us"> selected</cfif>>US</option>
					<option value="eu-en"<cfif regi is "eu-en"> selected</cfif>>Europe</option>
					</select>
          </p></td>		
        <td><p>Faction
            <select name="fac">
					<option value=""<cfif fac is ""> selected</cfif>>Any</option>
					<option value="a"<cfif fac is "a"> selected</cfif>>Alliance</option>
					<option value="h"<cfif fac is "h"> selected</cfif>>Horde</option>
					</select>
          </p></td>
        <td><p>Server
            <select name="serv">
						<option value=""<cfif serv is ""> selected</cfif>>Any</option>
						<option value="pve"<cfif serv is "pve"> selected</cfif>>PvE</option>
						<option value="pvp"<cfif serv is "pvp"> selected</cfif>>PvP</option>
					</select>
          </p></td>
        <td><p>Class
            <select name="clas">
						<option value=""<cfif clas is ""> selected</cfif>>Any</option>
						<option value="deth"<cfif clas is "deth"> selected</cfif>>Death Knight</option>
						<option value="drui"<cfif clas is "drui"> selected</cfif>>Druid</option>
						<option value="hunt"<cfif clas is "hunt"> selected</cfif>>Hunter</option>
						<option value="mage"<cfif clas is "mage"> selected</cfif>>Mage</option>
						<option value="monk"<cfif clas is "monk"> selected</cfif>>Monk</option>							 
						<option value="pala"<cfif clas is "pala"> selected</cfif>>Paladin</option>
						<option value="prie"<cfif clas is "prie"> selected</cfif>>Priest</option>
						<option value="rogu"<cfif clas is "rogu"> selected</cfif>>Rogue</option>
						<option value="sham"<cfif clas is "sham"> selected</cfif>>Shaman</option>
						<option value="warl"<cfif clas is "warl"> selected</cfif>>Warlock</option>
						<option value="warr"<cfif clas is "warr"> selected</cfif>>Warrior</option>
					</select>
          </p></td>
        <td><p>Idiot Filter
            <input type="checkbox" name="idiotFilter" value="1"<cfif idiotFilter is "1"> checked</cfif>>
          </p></td>
        <td><p>
            <input type="submit" value="Scan!" />
          </p></td>
      </tr>
	  <tr>
		<td colspan="6">
			<table align="center" border="0" cellspacing="0" cellpadding="0" id="keywordSearch">
				<tr>
					<td>Keyword Filter</td>
					<td><cfinput type="text" 
								name="keyword"								
								value="#keyword#"></td>
				</tr>
			</table>
		</td>
	  </tr>
	  </cfform>
    </table>
    <div id="legend">
	  <form name="frmNone">
	  <p>Specify Region</p>
	  <p><select name="pref_region" style="font-size:9px;" onChange="populateServers();recolorLinks();">
	  	<option value="US"<cfif pref_region is 'US'> selected</cfif>>US</option>
	  	<option value="EU-EN"<cfif pref_region is 'EU-EN'> selected</cfif>>EU-EN</option>
	  </select></p>
	  <p>Specify Server</p>
	  <p><select name="pref_server"
	  	 		style="font-size:9px;" 
	  	 		onChange="createCookie('WL_Server', this[this.selectedIndex].text, 90);g_Type=this[this.selectedIndex].value;recolorLinks();"
	  	 		onKeyUp="createCookie('WL_Server', this[this.selectedIndex].text, 90);g_Type=this[this.selectedIndex].value;recolorLinks();">
		  	 <option>-- loading --</option>
	  	 </select>
	  </p>
	  </form>
	  <p>Realm Transfer Legend</p>
	  <table width="120" border="0" cellspacing="0" cellpadding="0">
	  	<tr>
			<td class="realm_match"><span style="border: 1px solid #FDD017;"></span></td>
			<td></td>
			<td>Same Realm</td>	
		</tr>
	  	<tr>
			<td class="transfer_match"></td>
			<td></td>
			<td>Realm Type Match</td>	
		</tr>
	  	<tr>
			<td class="transfer_carebear"></td>
			<td></td>
			<td>PvP &raquo; PvE</td>	
		</tr>
	  	<tr>
			<td class="transfer_gank"></td>
			<td></td>
			<td>PvE &raquo; PvP</td>	
		</tr>
	  	<tr>
			<td class="transfer_nomatch"></td>
			<td></td>
			<td>Transfer Unavailable</td>	
		</tr>
	  </table>
	  <p>Class Color Legend</p>
      <table width="120" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td class="deathknight"></td>
          <td></td>
          <td>Death Knight (Dk)</td>
        </tr>
        <tr>
          <td class="druid"></td>
          <td></td>
          <td>Druid (D)</td>
        </tr>
        <tr>
          <td class="hunter"></td>
          <td></td>
          <td>Hunter (H)</td>
        </tr>
        <tr>
          <td class="mage"></td>
          <td></td>
          <td>Mage (M)</td>
        </tr>
        <tr>
        	<td class="monk"></td>
        	<td></td>
        	<td>Monk (Mo)</td>
        </tr>
        <tr>
          <td class="paladin"></td>
          <td></td>
          <td>Paladin (Pa)</td>
        </tr>
        <tr>
          <td class="priest"></td>
          <td></td>
          <td>Priest (Pr)</td>
        </tr>
        <tr>
          <td class="rogue"></td>
          <td></td>
          <td>Rogue (R)</td>
        </tr>
        <tr>
          <td class="shaman"></td>
          <td></td>
          <td>Shaman (S)</td>
        </tr>
        <tr>
          <td class="warlock"></td>
          <td></td>
          <td>Warlock (Wk)</td>
        <tr>
          <td class="warrior"></td>
          <td></td>
          <td>Warrior(W)</td>
        </tr>
        <tr>
          <td class="unknown"></td>
          <td></td>
          <td>Unknown</td>
        </tr>
      </table>
      <p>(Multiple classes are noted with abbreviations)</p>
	  <p></p>
	  <p>Region Legend</p>
	  <table width="120" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td class="north_america"></td>
          <td></td>
          <td>North America</td>
        </tr>
        <tr>
          <td class="europe"></td>
          <td></td>
          <td>Europe</td>
        </tr>
      </table>
	  <p>Rows marked with [A] are linked to Armory.</p>
	  <p><a href="<cfoutput>#getRSS()#</cfoutput>" onClick="javascript:urchinTracker('<cfoutput>#getRSS()#</cfoutput>');"><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAJDSURBVHjajJJNSBRhGMd/887MzrQxRSLbFuYhoUhEKsMo8paHUKFLdBDrUIdunvq4RdClOq8Hb0FBSAVCUhFR1CGD/MrIJYqs1kLUXd382N356plZFOrUO/MMz/vO83+e93n+f+1zF+kQBoOQNLBJg0CTj7z/rvWjGbEOIwKp9O7WkhtQc/wMWrlIkP8Kc1lMS8eyFHpkpo5SgWCCVO7Z5JARhuz1Qg29fh87u6/9VWL1/SPc4Qy6n8c0FehiXin6dcCQaylDMhqGz8ydS2hKkmxNkWxowWnuBLHK6G2C8X6UJkBlxUmNqLYyNbzF74QLDrgFgh9LLE0NsPKxjW1Hz2EdPIubsOFdH2HgbwAlC4S19dT13o+3pS+vcSfvUcq9YnbwA6muW9hNpym/FWBxfh0CZkKGkPBZeJFhcWQAu6EN52QGZ/8prEKW+cdXq0039UiLXhUYzdjebOJQQI30UXp6mZn+Dtam32Afu0iyrgUvN0r+ZQbr8HncSpUVJfwRhBWC0hyGV8CxXBL5SWYf9sYBidYLIG2V87/ifVjTWAX6AlxeK2C0X8e58hOr/Qa2XJ3iLMWxB1h72tHs7bgryzHAN2o2gJorTrLxRHVazd0o4TXiyV2Yjs90uzauGvvppmqcLjwmbZ3V7BO2HOrBnbgrQRqWUgTZ5+Snx4WeKfzCCrmb3axODKNH+vvUyWjqyK4DiKQ0eXSpFsgVvLJQWpH+xSpr4otg/HI0TR/t97cxTUS+QxIMRTLi/9ZYJPI/AgwAoc3W7ZrqR2IAAAAASUVORK5CYII=" alt="An RSS Feed customized to your current search criteria" width="14" height="14" border="0"></a> <a href="<cfoutput>#getRSS()#</cfoutput>" onClick="javascript:urchinTracker('<cfoutput>#getRSS()#</cfoutput>');">Subscribe</a> to this search result</p>
	  <table border="0" width="120">
		<form action="https://www.paypal.com/cgi-bin/webscr" method="post">
		<input type="hidden" name="cmd" value="_s-xclick">
		<input type="hidden" name="encrypted" value="-----BEGIN PKCS7-----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-----END PKCS7-----">
		<tr>
			<td align="center">
				<input type="image" src="/images/btn_donate_LG.gif" border="0" name="submit" alt="Make payments with PayPal - it's fast, free and secure!">
				<img alt="" border="0" src="/images/pixel.gif" width="1" height="1">
			</td>
		</tr>
		</form>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>Top 5 Filters</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>1. USA Alliance</td>
		</tr>		
		<tr>
			<td>2. Horde</td>
		</tr>
		<tr>
			<td>3. USA Horde</td>
		</tr>		
		<tr>
			<td>4. USA Alliance Shamans</td>
		</tr>
		<tr>
			<td>5. USA Alliance Shamans (No Idiots)</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>Top 5 Keywords</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>1. 'daytime'</td>
		</tr>		
		<tr>
			<td>2. 'gmt'</td>
		</tr>
		<tr>
			<td>3. 'resto'</td>
		</tr>		
		<tr>
			<td>4. 'euro'</td>
		</tr>
		<tr>
			<td>5. 'afternoon'</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>		
		<tr>
			<td>Top 5 Referrers</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>1. <a href="http://www.elitistjerks.com/" onClick="javascript:urchinTracker('<cfoutput>http://www.elitistjerks.com/</cfoutput>');" target="_blank">Elitist Jerks</a></td>
		</tr>		
		<tr>
			<td>2. <a href="http://www.worldofraids.com/" onClick="javascript:urchinTracker('<cfoutput>http://www.worldofraids.com/</cfoutput>');" target="_blank">World of Raids</a></td>
		</tr>
		<tr>
			<td>3. <a href="http://www.wowinsider.com/" onClick="javascript:urchinTracker('<cfoutput>http://www.wowinsider.com/</cfoutput>');" target="_blank">WoW Insider</a></td>
		</tr>		
		<tr>
			<td>4. <a href="http://www.worldofmatticus.com/" onClick="javascript:urchinTracker('<cfoutput>http://www.worldofmatticus.com/</cfoutput>');" target="_blank">World of Matticus</a></td>
		</tr>
		<tr>
			<td>5. <a href="http://www.wowhead.com/" onClick="javascript:urchinTracker('<cfoutput>http://www.wowhead.com/</cfoutput>');" target="_blank">Wowhead</a></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<cfif stats.recordcount>
		<tr>
			<td>Stats for<cfoutput> #dateFormat(stats.EffectiveDate, 'mmmm, yyyy')#</cfoutput></td>
		</tr>		
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>Total Posts: <cfoutput>#stats.NumPosts#</cfoutput></td>
		</tr>	
		<tr>
			<td>&nbsp;</td>
		</tr>
		<cftry>
		<tr>
			<td>Alliance: <cfoutput>#stats.NumAlliance# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumAlliance))#%)</cfoutput></td>
		</tr>	
		<tr>
			<td>Horde: <cfoutput>#stats.NumHorde# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumHorde))#%)</cfoutput></td>
		</tr>	
		<tr>
			<td>&nbsp;</td>
		</tr>		
		<tr>
			<td>PvP: <cfoutput>#stats.NumPvP# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumPvP))#%)</cfoutput></td>
		</tr>	
		<tr>
			<td>PvE: <cfoutput>#stats.NumPvE# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumPvE))#%)</cfoutput></td>
		</tr>	
		<tr>
			<td>&nbsp;</td>
		</tr>		
		<tr>
			<td>Idiots: <cfoutput>#stats.NumIdiots# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumIdiots))#%)</cfoutput></td>
		</tr>	
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>Death Knights: <cfoutput>#stats.NumDeathKnights# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumDeathKnights))#%)</cfoutput></td>
		</tr>	
		<tr>
			<td>Druids: <cfoutput>#stats.NumDruids# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumDruids))#%)</cfoutput></td>
		</tr>	
		<tr>
			<td>Hunters: <cfoutput>#stats.NumHunters# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumHunters))#%)</cfoutput></td>
		</tr>	
		<tr>
			<td>Mages: <cfoutput>#stats.NumMages# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumMages))#%)</cfoutput></td>
		</tr>
		<tr>
			<td>Monks: <cfoutput>#stats.NumMonks# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumMonks))#%)</cfoutput></td>
		</tr>			
		<tr>
			<td>Paladins: <cfoutput>#stats.NumPaladins# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumPaladins))#%)</cfoutput></td>
		</tr>			
		<tr>
			<td>Priests: <cfoutput>#stats.NumPriests# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumPriests))#%)</cfoutput></td>
		</tr>			
		<tr>
			<td>Rogues: <cfoutput>#stats.NumRogues# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumRogues))#%)</cfoutput></td>
		</tr>					
		<tr>
			<td>Shamans: <cfoutput>#stats.NumShamans# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumShamans))#%)</cfoutput></td>
		</tr>	
		<tr>
			<td>Warlocks: <cfoutput>#stats.NumWarlocks# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumWarlocks))#%)</cfoutput></td>
		</tr>				
		<tr>
			<td>Warriors: <cfoutput>#stats.NumWarriors# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumWarriors))#%)</cfoutput></td>
		</tr>	
		<tr>
			<td>&nbsp;</td>
		</tr>						
		<tr>
			<td>North America: <cfoutput>#stats.NumUS# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumUS))#%)</cfoutput></td>
		</tr>				
		<tr>
			<td>Europe: <cfoutput>#stats.NumEU# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumEU))#%)</cfoutput></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>					
		<tr>
			<td>Armory Links: <cfoutput>#stats.NumArmory# (#decimalFormat(evaluate((100/stats.NumPosts) * stats.NumArmory))#%)</cfoutput></td>
		</tr>
		<cfcatch type="any"></cfcatch>
		</cftry>
		<tr>
			<td>&nbsp;</td>
		</tr>
		</cfif>		
	  </table>
    </div>
    <div id="searchResults">
		<table width="930" border="0" style="border: none;" class="aboutUs">
			<tr style="border: none;">
				<td style="border: none; margin: 0; padding:0;"><p style="padding:0;"><cfoutput>#getPagination()#</cfoutput></p> </td>
				<td style="border: none; margin: 0; padding:0;"><a onClick="javascript:urchinTracker('<cfoutput>#JSStringFormat('http://www.twitter.com/WoWLemming')#</cfoutput>')" href="http://www.twitter.com/WoWLemming" target="_blank"><img src="/images/twitter.png" border="0"></a></td>
				<td style="border: none; margin: 0; padding:0; text-align:right;"><p style="padding:0;"><a href="about.html" target="_blank">About</a> | <a href="contact.html" target="_blank">Contact</a> | <a href="faq.html">FAQ</a></p></td>
			</tr>
		</table>
        <div></div>
		<div class="clr"></div>
		<table width="750" border="0" cellspacing="0" cellpadding="0" id="resultsTable">
		<cfoutput query="qryResults">
	        <tr>
		        <td><div id="icon_#PostID#"><img border="0" src="/images/#getPrefIconByPost(PostID)#" name="img_#PostID#" onClick="toggleIcon(#PostID#);" /></div></td>
				<td class="#iif(Region is 'EU-EN',de('europe'),de('north_america'))#">&nbsp;<a onClick="javascript:urchinTracker('#JSStringFormat(PostURL)#')" href="#PostURL#" class="tt" target="_blank">#PostTitle##getBalloon(PostBody)#</a></td>
				<td>#dateFormat(EffectiveDate,"m/dd/yyyy")# #timeFormat(EffectiveDate,"HH:mm:ss")#</td>
				<td><cfif isAlliance>Alliance<cfelseif isHorde>Horde<cfelse>Unknown</cfif></td>
				<td><cfif isPvP>PvP<cfelseif isPvE>PvE<cfelse>Unknown</cfif></td>
				<td><cfif len(ArmoryURL)><a href="#ArmoryURL#" onClick="javascript:urchinTracker('#JSStringFormat(ArmoryURL)#')" target="_blank">[A]</a><cfelse>&nbsp;</cfif></td>
				<td class="#getClassColor(qryResults,currentRow)#" align="center">#getClassCombos(qryResults, currentRow)#</td>
	        </tr>
		</cfoutput>
      	</table>	
		<div></div>
		<div class="clr"></div>	
		<table width="930" border="0" style="border: none;" class="aboutUs">
			<tr style="border: none;">
				<td style="border: none; margin: 0; padding:0;"><p style="padding:0;"><cfoutput>#getPagination()#</cfoutput></p> </td>
				<td style="border: none; margin: 0; padding:0; text-align:right;">&nbsp;</td>
			</tr>
		</table>
    </div>
  </div>
</div>
<cfif NOT findNoCase('lc.wowlemmings.com', CGI.HTTP_HOST)><script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-3535784-1', 'wowlemmings.com');
  ga('require', 'displayfeatures');
  ga('send', 'pageview');

</script></cfif>
<script type="text/javascript" src="/js/wowlemmings_v2.compressed.js"></script>
</body>
</html>