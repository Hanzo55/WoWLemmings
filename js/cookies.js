/* Used by permission from http://www.quirksmode.org/js/cookies.html, 
 * originally from: Scott Andrew -- http://www.scottandrew.com/ */
function createCookie(name,value,days) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else var expires = "";
	document.cookie = name+"="+value+expires+"; path=/";
}

function readCookie(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

function eraseCookie(name) {
	createCookie(name,"",-1);
}

// WoW Lemmings : Copyright Shawn Holmes 2008
function rotateIcon(oImg) {
	if (oImg.src.indexOf('unknown') != -1) {
		oImg.src = 'images/thumbs_up.gif';
		return 1;
	} else if (oImg.src.indexOf('thumbs_up') != -1) {
		oImg.src = 'images/thumbs_down.gif';
		return -1;				
	} else {
		oImg.src = 'images/unknown.gif';
		return 0;
	}
}
		
function toggleIcon(tID) {
	var icon = '';			
	var image = '';
	var nextValue = 0;			
	
	icon = document.getElementById('icon_' + tID);
	image = icon.firstChild;
	nextValue = rotateIcon(image);
	writeTopicPreferenceToCookie(tID, nextValue);
}
		
// format is topicId:pref,topicId:pref,topicId:pref, etc
function readTopicPreferenceFromCookie(tID) {
	var prefs = readCookie('WL_Topic');
	
	if (!prefs) {
		return 0; // by default, all prefs are 0 
	} else {
		// cookie found, prefs inc.
		topicArr = prefs.split(',');
		for (var i=0; i < topicArr.length; i++) {
			var topicPref = topicArr[i].split(":");
			if (parseInt(topicPref[0]) == tID)
				return parseInt(topicPref[1]); // topicId matches, so return the pref
		}
	}
	
	return 0; // topic never had a pref in cookie so 0 by default
}
		
function writeTopicPreferenceToCookie(tID,newpref) {
	var prefs = readCookie('WL_Topic');
	var finalArr = new Array();
	var r=0;
	
	if (!prefs) {
		// no cookie to begin with, so setup
		var prefString = tID + ':' + newpref;
		createCookie('WL_Topic', prefString, 90); // default to 90 days
	} else {
		// cookie found, convert prefs to array
		var prefArr = prefs.split(',');
		var updated = false;
		for (var i=0; i < prefArr.length; i++) {
			// look at each element by converting to a 2nd array (the actual update will rewrite the value as a string)
			var currPref = prefArr[i].split(":");
			if (parseInt(currPref[0]) == tID) {
				// rewrite the value
				prefArr[i] = tID + ':' + newpref;
				updated = true;
				// break out of the loop now
				break;
			}
		}
		
		if (!updated) {
			//if you get here, it means it's a new topic to the cookie, so add to the end
			prefArr[prefArr.length] = tID + ':' + newpref;
			updated = true;
		}
		
		// just before we convert the array back to a string to write to the cookies, let's save a few bytes
		// and remove any entries that were reset back to 0 (which is the default anyway)
		for (var i=0; i < prefArr.length; i++) {
			if (prefArr[i].indexOf(':0') == -1)
				finalArr[r++] = prefArr[i];
		}
		
		if (finalArr.length == 0)
			finalArr = prefArr;
		
		// finish by converting the array back to a string and writing the cookie
		var newPrefs = finalArr.join(',');
		createCookie('WL_Topic', newPrefs, 90);
	}
}
