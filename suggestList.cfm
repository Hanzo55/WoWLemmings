<cfsilent>
<cfscript>
	// autosuggest keywords for popular searches
	keywordList = [
	
	//timezones
	'PST', 'MST', 'CST', 'EST', 'Oceanic',
	
	//raid progress
	'Kara', 'ZA', 'Gruul', 'Mag', 'SSC', 'TK', 'MH', 'Mount Hyjal', 'Hyjal', 'BT', 'SW', 'Sunwell',
	
	// **specs**
	
	// shaman
	'resto', 'restoration', 'enhance', 'elem', 'elemental',  		
	// paladin
	'ret', 'retribution', 'retadin', 'prot', 'tankadin', 'holy', 'healadin',
	// priest 		
	'disc', 'discipline', 'shadow', 'spriest', 'coh',			
	// druid (resto from shaman row)
	'feral', 'moon', 'moonkin', 'boom', 'boomkin', 'cat', 'kitty',
	// warrior (prot from paladin row)
	'fury', 'arms',
	 // locks													
	'destro', 'destruction', 'afflic', 'affliction', 'soul link', 'soullink', 'SL', 'demo', 'demonology', 'demonologist',
	// death knight,
	'unholy', 'blood', 'frost',
	// mage (frost from dk)										
	'fire', 'arcane',
	// monk
	'windwalker','brewmaster','mistweaver',
	// hunter										
	'marks', 'marksman', 'bm', 'beast master', 'beast mastery', 'beastmaster', 'beastmastery', 'survival', 
	// rogue
	'combat', 'combat swords', 'combat daggers', 'cs', 'cd', 'assass', 'assassination', 'subtlety', 'hemo', 'mutilate',
	
	//general terms
	'tank', 'healer', 'melee', 'DPS', 'PvP', 'PvE', 'RP', 'wrath', 'wotlk', 'tbc', 'hardcore'
	];
</cfscript>
</cfsilent><cfoutput>#SerializeJSON(keywordList)#</cfoutput>