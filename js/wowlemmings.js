var g_Type = '';
		
function populateServers() {
	var pref_region = document.frmNone.pref_region[document.frmNone.pref_region.selectedIndex].value;
	
	document.frmNone.pref_server.options.length = 0;
	
	for (i=0; i < jsServers.getRowCount(); i++) {
		if (jsServers.region[i] == pref_region) {
			
			var obj = new Option();
			
			obj.text = jsServers.servername[i];
			obj.value = jsServers.servertype[i];
			
			document.frmNone.pref_server.options[document.frmNone.pref_server.options.length] = obj;					
		}
	}			
}

function preselectServer() {
	var user_server = readCookie('WL_Server');
	var change = false;
	
	if (user_server != null) {
		for (i=0; i < document.frmNone.pref_server.length; i++) {
			if (document.frmNone.pref_server[i].text == user_server) {
				document.frmNone.pref_server.selectedIndex = i;
				change = true;
				break;
			}
		}
		
		if (change) {
			g_Type=document.frmNone.pref_server[document.frmNone.pref_server.selectedIndex].value;
			recolorLinks();
		}
	}
}

function recolorLinks() {
	var user_server = readCookie('WL_Server');
	var resultsTable = document.getElementById('resultsTable');
	
	for (var i=0; i < resultsTable.rows.length; i++) {
	
		var regCheck = resultsTable.rows[i].cells[1]; // the 2nd column has the region image in it 
		var tdCheck = resultsTable.rows[i].cells[4]; // the 5th column is the server-type
		var armCheck = resultsTable.rows[i].cells[5]; // the 6th column is the armory link				

		if (user_server != null) {
			var realm = '';
			if (armCheck.firstChild.href != null) {
				// convert the user_server string to a url encoded via by means of CF for the regxp in javascript
				user_server_url = escape(user_server);
				// now replace %20 with '+'
				user_server_url = user_server_url.replace('%20','+');
				realm = armCheck.firstChild.href.replace(/.*r=(.*)\&n=.*/, "$1");
				if (realm == user_server_url)
					resultsTable.rows[i].className = "realm_match";
				else
					resultsTable.rows[i].className = "";
			}
		}
		
		// each row one of three, in this order
		// 1. regions known but don't match, color red and move on				
		// 2. unknown region, color blank and move on
		// 3. regions known, process the eligibility function
		
		if (!matchesRegion(regCheck.className)) {
			resultsTable.rows[i].bgColor="#ff0000";
			continue;
		}

		if (tdCheck.textContent == 'Unknown') {
			resultsTable.rows[i].bgColor="";
			continue;
		}

		resultsTable.rows[i].bgColor = getTransferColorRule(tdCheck.textContent, g_Type);
	}		
}

function matchesRegion(altText) {
	var thisRegion = document.frmNone.pref_region[document.frmNone.pref_region.selectedIndex].value;
	
	if ( (thisRegion == "US" && altText == "north_america") || (thisRegion == "EU-EN" && altText == "europe") )
		return true;
	else
		return false;			
}

function getTransferColorRule(startServer, destServer) {
	if (startServer == destServer)
		return "#347C2C"; // same
	else {
		if (startServer == 'PvP' && destServer == 'PvE')
			return "#7F525D"; // carebear
		else
			return "#7e2217"; // gank
	}
}

function matchesServerTransferRule(startServer, destServer) {
	if (destServer == 'PvP') {
		if (startServer == 'PvP')
			return true;
		else
			return false;
	} else if (destServer == 'PvE')
		return true;
}