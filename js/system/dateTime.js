/********** START CREATE TIME **********/
	function createDateTime( json ) {
		/***** START DEFAULT VALUES *****/
			var t = '';
			var newDate = new Date();
	
			if ( typeof( json) == "undefined" ) { var json = {}; }
			
			json.format = ( typeof(json.format) != "undefined" ) ? json.format : "javascript";
			json.year = ( typeof(json.year) != "undefined" ) ? json.year : newDate.getFullYear();
			json.month = ( typeof(json.month) != "undefined" ) ? json.month : newDate.getMonth() + 1;
			json.day = ( typeof(json.day) != "undefined" ) ? json.day : newDate.getDate();
			json.hours = ( typeof(json.hours) != "undefined" ) ? json.hours : newDate.getHours();
			json.minutes = ( typeof(json.minutes) != "undefined" ) ? json.minutes : newDate.getMinutes();
			json.seconds = ( typeof(json.seconds) != "undefined" ) ? json.seconds : newDate.getSeconds();
			json.milliseconds = ( typeof(json.milliseconds) != "undefined" ) ? json.milliseconds : newDate.getMilliseconds();
		/***** END DEFAULT VALUES *****/

		/***** START NUMBER FORMAT CHECK *****/
			if (json.month >= 13) { json.month = 1; }
			if (json.day >= 32) { json.day = 1; }
			if (json.hours >= 24) { json.hours = 0; }
			if (json.minutes >= 59) { json.minutes = 0; }
			if (json.seconds >= 59) { json.seconds = 0; }
		/***** END NUMBER FORMAT CHECK *****/

		if ( json.format.toLowerCase() == "javascript") { 
			var thisDate = new Date(json.year, json.month, json.day, json.hours, json.minutes, json.seconds, json.milliseconds);
		}
		else if ( json.format.toLowerCase() == "odbc" || json.format.toLowerCase() == "cold fusion") { 
			/***** START ZERO LEADERS *****/
				if (!/^0\d{1}$/.test(json.month) && json.month < 10) { json.month = "0" + json.month; }
				if (!/^0\d{1}$/.test(json.day) && json.day < 10) { json.day = "0" + json.day; }
				if (!/^0\d{1}$/.test(json.hours) && json.hours < 10) { json.hours = "0" + json.hours; }
				if (!/^0\d{1}$/.test(json.minutes) && json.minutes < 10) { json.minutes = "0" + json.minutes; }
				if (!/^0\d{1}$/.test(json.seconds) && json.seconds < 10) { json.seconds = "0" + json.seconds; }
			/***** END ZERO LEADERS *****/

			var thisDate = "{ts '" + json.year + "-" + json.month + "-" + json.day + " " + json.hours + ":" + json.minutes + ":" + json.seconds + "'}";
		}

		return thisDate;
	}
/********** END CREATE TIME **********/

/********** START DATE FORMAT / MASK **********/
	function dateFormat( json ) {
		/***** START DEFAULT VALUES *****/
			var t = '';
			json.date = ( typeof( json.date ) == "undefined" ) ? "XX" : json.date;
			json.mask = ( typeof( json.mask ) == "undefined" ) ? "MM/DD/YYYY" : json.mask;
	
			var isODBCDateTime = /^[{ts]+\s+[']+\d{4}(\-)+[0-1][0-9](\-)+[0-3][0-9]+\s+[0-2][0-9](\:)[0-5][0-9](\:)[0-5][0-9]['][}]/gi.test( json.date );
		/***** END DEFAULT VALUES *****/
		/***** START FORMAT CONVERT *****/
			if (isODBCDateTime) {
				json.date = json.date.split("'")[1];
				json.date = json.date.split(" ")[0];
	
				/***** START DATE *****/
					var thisYear = json.date.split("-")[0];
					var thisMonth = json.date.split("-")[1];
					var thisDay = json.date.split("-")[2];
				/***** END DATE *****/
			}
			else {
				/***** START JAVSCRIPT DATE *****/
					if (json.date instanceof Date) {
						var thisYear = json.date.getFullYear();
						var thisMonth = json.date.getMonth() + 1;
						var thisDay = json.date.getDate();
					}
				/***** END JAVSCRIPT DATE *****/
			}
		/***** END FORMAT CONVERT *****/
	
		var lastCharacter = '';
		var x = [];
	
		for (var i=0; i <= json.mask.length; i++) {
			x.push(json.mask[i]);
			if ( lastCharacter.indexOf( json.mask[i] ) != -1 ) { lastCharacter += json.mask[i]; }
			else {
				if (lastCharacter != '' || i >= json.mask.length) { t += dateMaskItemLookup( { "maskItem" : lastCharacter.toLowerCase(), "thisYear" : thisYear, "thisMonth" : thisMonth, "thisDay" : thisDay } ); }
	
				lastCharacter = json.mask[i];
			}
		}
	
		return t;
	}
	
	function dateMaskItemLookup( json ) {
		/***** START DEFAULT VALUES *****/
			var t = '';
			var monthsFull = ["January","February","March","April","May","June","July","August","September","October","November","December"];
			var monthsShort = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
			var daysFull = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
			var daysShort = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
			var date = new Date( json.thisYear, (json.thisMonth - 1), json.thisDay, 0, 0, 0, 1 );
		/***** END DEFAULT VALUES *****/
	
		/***** START MASK *****/
			switch ( json.maskItem ) {
				case 'dddd': { t = daysFull[date.getDay()]; break; }
				case 'ddd': { t = daysShort[date.getDay()]; break; }
				case 'dd': { t = (!/^0\d{1}$/.test(json.thisDay) && json.thisDay < 10 ) ? "0" + json.thisDay : json.thisDay; break; }
				case 'd': { t = json.thisDay.replace(/^[0]+/g, ''); break; }
				case 'mmmm': { t = monthsFull[ parseInt(json.thisMonth - 1) ]; break; }
				case 'mmm': { t = monthsShort[ parseInt(json.thisMonth - 1) ]; break; }
				case 'mm': { t = (!/^0\d{1}$/.test(json.thisMonth) && json.thisMonth < 10 ) ? "0" + json.thisMonth : json.thisMonth; break; }
				case 'm': { t = json.thisMonth.replace(/^[0]+/g, ''); break; }
				case 'yyyy': { t = json.thisYear; break; }
				case 'yy': { t = json.thisYear.toString().substring(2,4); break; }
				default: { t = json.maskItem; }
			}
		/***** END MASK *****/
		return t;
	}
/********** END DATE FORMAT / MASK **********/

/********** START TIME FORMAT / MASK **********/
	function timeFormat( json ) {
		/***** START DEFAULT VALUES *****/
			var t = '';
			json.date = ( typeof json.date === "undefined" ) ? "XX" : json.date;
			json.mask = ( typeof json.mask === "undefined" ) ? "HH:MM:SS" : json.mask;

			var isODBCDateTime = /^[{ts]+\s+[']+\d{4}(\-)+[0-1][0-9](\-)+[0-3][0-9]+\s+[0-2][0-9](\:)[0-5][0-9](\:)[0-5][0-9]['][}]/gi.test( json.date );
		/***** END DEFAULT VALUES *****/

		/***** START ODBC TIME FORMAT CONVERT *****/
			if (isODBCDateTime) {
				json.date = json.date.split(" ")[2];
				json.date = json.date.split("'")[0];

				/***** START TIME *****/
					var thisHours = json.date.split(":")[0];
					var thisMinutes = json.date.split(":")[1];
					var thisSeconds = json.date.split(":")[2];
				/***** END TIME *****/
			}
			else {
				/***** START JAVSCRIPT DATE *****/
					if (json.date instanceof Date) {
						var thisHours = json.date.getHours();
						var thisMinutes = json.date.getMinutes();
						var thisSeconds = json.date.getSeconds();
					}
				/***** END JAVSCRIPT DATE *****/
			}
		/***** END ODBC TIME FORMAT CONVERT *****/

		var lastCharacter = '';
		var x = [];

		for (var i=0; i <= json.mask.length; i++) {
			x.push(json.mask[i]);

			if ( lastCharacter.indexOf( json.mask[i] ) != -1 ) { lastCharacter += json.mask[i]; }
			else {
				if (lastCharacter != '') { t += timeMaskItemLookup( { "maskItem" : lastCharacter, "hours" : thisHours, "minutes" : thisMinutes, "seconds" : thisSeconds } ); }
				lastCharacter = json.mask[i];
			}
		}
	
		return t;
	}
	
	function timeMaskItemLookup( json ) {
		/***** START DEFAULT VALUES *****/
			var t = '';
		/***** END DEFAULT VALUES *****/
	
		/***** START MASK *****/
			switch ( json.maskItem ) {
				case 'hh': { if (json.hours <= 12) { t = json.hours.replace(/^[0]+/g, ''); } else { t = (json.hours - 12).replace(/^[0]+/g, ''); } break; }
				case 'h': { if (json.hours == 0) { t = 12; } else if (json.hours <= 12) { t = json.hours } else { t = (json.hours - 12 ); } break; }
				case 'HH': { t = json.hours; break; }
				case 'H': { t = json.hours.replace(/^[0]+/g, ''); break; }
				case 'mm': case 'MM': { t = json.minutes; break; }
				case 'm': case 'M': { t = json.minutes.replace(/^[0]+/g, ''); break; }
				case 'ss': case 'SS': { t = json.seconds; break; }
				case 's': case 'S': { t = json.seconds.replace(/^[0]+/g, ''); break; }
				case 'l': { t = 0; break; }
				case 'tt': { t = (json.hours < 12) ? "AM" : "PM"; break; }
				case 't': { t = (json.hours < 12) ? "A" : "P"; break; }
				default: { t = json.maskItem; }
			}
		/***** END MASK *****/

		return t
	}
/********** END TIME FORMAT / MASK **********/

/********** START DATE TIME COMPARE **********/
	function dateCompare( json ) {
		/***** START DEFAULT VALUES *****/
			var t = 0; // in milliseconds

			var isODBCDateTime1 = /^[{ts]+\s+[']+\d{4}(\-)+[0-1][0-9](\-)+[0-3][0-9]+\s+[0-2][0-9](\:)[0-5][0-9](\:)[0-5][0-9]['][}]/gi.test( json.date1 );
			var isODBCDateTime2 = /^[{ts]+\s+[']+\d{4}(\-)+[0-1][0-9](\-)+[0-3][0-9]+\s+[0-2][0-9](\:)[0-5][0-9](\:)[0-5][0-9]['][}]/gi.test( json.date2 );
		/***** END DEFAULT VALUES *****/

		/***** START ODBC DATE TIME COMPARE *****/
			if (isODBCDateTime1 && isODBCDateTime2) {
				json.date1 = createDateTime ( { "year" : dateFormat( { "date" : json.date1, "mask" : "yyyy" } ), "month" : dateFormat( { "date" : json.date1, "mask" : "m" } ), "day" : dateFormat( { "date" : json.date1, "mask" : "d" } ), "hours" : timeFormat( { "date" : json.date1, "mask" : "h" } ), "minutes" : timeFormat( { "date" : json.date1, "mask" : "m" } ), "seconds" : timeFormat( { "date" : json.date1, "mask" : "s" } ), "milliseconds" : 0 } );
				json.date2 = createDateTime ( { "year" : dateFormat( { "date" : json.date2, "mask" : "yyyy" } ), "month" : dateFormat( { "date" : json.date2, "mask" : "m" } ), "day" : dateFormat( { "date" : json.date2, "mask" : "d" } ), "hours" : timeFormat( { "date" : json.date2, "mask" : "h" } ), "minutes" : timeFormat( { "date" : json.date2, "mask" : "m" } ), "seconds" : timeFormat( { "date" : json.date2, "mask" : "s" } ), "milliseconds" : 0 } );
				//t = toJavascriptDate( { "date" : date1 } ) - toJavascriptDate( splitODBCDateTime( { "date" : json.date1 } ) );
			}
		/***** END ODBC DATE TIME COMPARE *****/

		/***** START JAVASCRIPT DATE TIME COMPARE *****/
			t = json.date2.getTime() - json.date1.getTime();
		/***** END JAVASCRIPT DATE TIME COMPARE *****/
		return t;
	}
/********** END DATE TIME COMPARE **********/


/********** START DATE TIME OFFSET **********/
	function timeOffset( json ) {
		/***** START DEFAULT VALUES *****/
			var t = '';
			json.format = ( typeof( json.format ) != "undefined" ) ? json.format.toLowerCase() : "javascript";
			json.days = ( typeof( json.days ) == "undefined" ) ? 0 : json.days * 24 * 60 * 60 * 1000;
			json.hours = ( typeof( json.hours ) == "undefined" ) ? 0 : json.hours * 60 * 60 * 1000;
			json.minutes = ( typeof( json.minutes ) == "undefined" ) ? 0 : json.minutes * 60 * 1000;
			json.seconds = ( typeof( json.seconds ) == "undefined" ) ? 0 : json.seconds * 1000;
			json.milliseconds = ( typeof( json.milliseconds ) == "undefined" ) ? 0 : json.milliseconds * 1000;

			var fullOffset = json.days + json.hours + json.minutes + json.seconds + json.milliseconds;

			var isODBCDateTime = /^[{ts]+\s+[']+\d{4}(\-)+[0-1][0-9](\-)+[0-3][0-9]+\s+[0-2][0-9](\:)[0-5][0-9](\:)[0-5][0-9]['][}]/gi.test( json.date );
		/***** END DEFAULT VALUES *****/

		/***** START ODBC TIME FORMAT CONVERT *****/
			if (isODBCDateTime) {
				var thisJavascriptDate = createDateTime ( { "year" : dateFormat( { "date" : json.date, "mask" : "yyyy" } ), "month" : dateFormat( { "date" : json.date, "mask" : "m" } ), "day" : dateFormat( { "date" : json.date, "mask" : "d" } ), "hours" : timeFormat( { "date" : json.date, "mask" : "HH" } ), "minutes" : timeFormat( { "date" : json.date, "mask" : "m" } ), "seconds" : timeFormat( { "date" : json.date, "mask" : "s" } ), "milliseconds" : 0 } );
			}
			else {
				var thisJavascriptDate = json.date;
			}
		/***** END ODBC TIME FORMAT CONVERT *****/
		
		var thisNewDate = new Date( thisJavascriptDate.valueOf() + fullOffset );
		
		return (json.format == "javascript") ? new Date( thisNewDate ) : createDateTime ( { "format" : "odbc", "year" : dateFormat( { "date" : thisNewDate, "mask" : "yyyy" } ), "month" : dateFormat( { "date" : thisNewDate, "mask" : "mm" } ), "day" : dateFormat( { "date" : thisNewDate, "mask" : "dd" } ), "hours" : timeFormat( { "date" : thisNewDate, "mask" : "HH" } ), "minutes" : timeFormat( { "date" : thisNewDate, "mask" : "mm" } ), "seconds" : timeFormat( { "date" : thisNewDate, "mask" : "ss" } ), "milliseconds" : 0 } );
	}
/********** START DATE TIME OFFSET **********/

function millisecondsToDHMS( json ) {
	/***** START DEFAULT VALUES *****/
		var t = "";
	/***** END DEFAULT VALUES *****/

	/***** START TYPE LOOKUP *****/
		json.type = ( typeof( json.type ) != "undefined" ) ? json.type : "seconds";

		switch (json.type) {
			case "hours" : { json.duration = json.duration * 60; break; }
			case "minutes" : { json.duration = json.duration * 60; break; }
			case "milliseconds" : { json.duration = json.duration / 1000; break; }
		}
	/***** END TYPE LOOKUP *****/

	/***** START SECONDS TO HH:MM:SS *****/
		var negative = (json.duration < 0) ? "-" : "";

		var DD = Math.floor(Math.abs(json.duration) / 86400);
		var HH = Math.floor((Math.abs(json.duration) % 86400) / 3600);
		var MM = Math.floor(((Math.abs(json.duration) % 86400) % 3600) / 60);
		var SS = ((Math.abs(json.duration) % 86400) % 3600) % 60;
	/***** END SECONDS TO HH:MM:SS *****/

	/***** START STRING OUTPUT *****/
		t += negative;
		t += (DD.toString().length == 1) ? "0" + DD : DD;
		t += ":";
		t += (HH.toString().length == 1) ? "0" + HH : HH;
		t += ":";
		t += (MM.toString().length == 1) ? "0" + MM : MM;
		t += ":";
		t += (SS.toString().length == 1) ? "0" + SS : SS;
	/***** END STRING OUTPUT *****/

	return t;
}

function getSeconds( duration ) {
	return duration / 1000;
}

function getMinutes( duration ) {
	return duration / (60 * 1000);
}

function getCurrentHour( json ) {
	/***** START DEFAULT VALUES *****/
		var d = new Date();
		json.format = ( typeof(json.format) == "undefined" ) ? 12 : 24;
		json.hour = ( typeof(json.hour) != "undefined" ) ? json.hour : d.getHours();
	/***** END DEFAULT VALUES *****/

	if (json.format != 24) {
		if ( json.hour == 0 ) { json.hour = 12; } 
		else if ( json.hour > 12) { json.hour = json.hour - 12; }
	}

	return json.hour;
}

function getCurrentMinute( json ) {
	/***** START DEFAULT VALUES *****/
		var d = new Date();
	/***** END DEFAULT VALUES *****/
	
	return d.getMinutes();
}

function getAMPM( json ) {
	/***** START DEFAULT VALUES *****/
		var d = new Date();
		json.hour = ( typeof(json.hour) != "undefined" ) ? json.hour : d.getHours();
	/***** END DEFAULT VALUES *****/

	return ( json.hour >= 12 ) ? "PM" : "AM";
}