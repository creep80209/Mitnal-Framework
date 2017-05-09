/********** BEGIN GET URL PARAMETERS **********/
	function getParameterByName( name ) {				// COULD REMPLACE getURLParametes needs work
		name = name.replace( /[\[]/, "\\[" ).replace( /[\]]/, "\\]" );
		var regex = new RegExp( "[\\?&]" + name + "=([^&#]*)" );
		var results = regex.exec( location.search );
		return results === null ? "" : decodeURIComponent( results[ 1 ].replace( /\+/g, " " ) );
	}

	function getURLParameters( paramName ) {
		var sURL = window.document.URL.toString();
		if ( sURL.indexOf( "?" ) > 0) {
			var arrParams = sURL.split( "?" );
			var arrURLParams = arrParams[ 1 ].split( "&" );
			var arrParamNames = new Array( arrURLParams.length );
			var arrParamValues = new Array( arrURLParams.length );

			for ( var i = 0; i < arrURLParams.length; i++ ) {
				var sParam = arrURLParams[ i ].split( "=" );
				arrParamNames[ i ] = sParam[ 0 ];
				arrParamValues[ i ] = ( sParam[ 1 ] != "") ? unescape( sParam[ 1 ] ) : ""; 
			}

			for ( var i=0; i < arrURLParams.length; i++ ) {
				if ( new RegExp( paramName, "i" ).test( arrParamNames[ i ] ) ) { return arrParamValues[ i ]; }
			}
		}
	}
/********** END URL PARAMETERS **********/

/********** BEGIN PAGE ACCESS PERMISSIONS **********/
	function pageAccess( json ) {
		/***** BEGIN DEFAULT VALUES *****/
			if ( typeof( json.page ) == "undefined" ) { json.id = "/"; }
			if ( typeof( json.section ) == "undefined" ) { json.section = "~"; }
		/***** END DEFAULT VALUES *****/

		/***** BEGIN AJAX *****/
			// this ajx method needs to NOT be asynchronous
			var returnValue = jQuery.ajax(
				{
					type: "POST", 
					async: false, 
					url: "/COM/members.cfc?method=getPageAccess&page=" + escape( json.page ) + "&section=" + json.section,
					contentType: "application/json; charset=utf-8",
					dataType: "json", 
					cache: false,
					success: function( data, textStatus, jqXHR ){
						/***** BEGIN PROCESS OF RETURNED DATA *****/
							if ( /^1\d{3}$/.test( data.statusCode ) ) {
								globalReturnValue = data.data.results[ 0 ].pageAccess;
							}
						/***** END PROCESS OF RETURNED DATA *****/
					}
				}
			);
		/***** END AJAX *****/
		return globalReturnValue;
	}
/********** END PAGE ACCESS PERMISSIONS **********/

/********** BEGIN REPLACE MS WORD CHARACTERS **********/
	function replaceWordChars( text ) {
		var s = text;
		// smart single quotes and apostrophe
		s = s.replace( /[\u2018|\u2019|\u201A]/g, "\'" );
		// smart double quotes
		s = s.replace( /[\u201C|\u201D|\u201E]/g, "\"" );
		// ellipsis
		s = s.replace( /\u2026/g, "..." );
		// dashes
		s = s.replace( /[\u2013|\u2014]/g, "-" );
		// circumflex
		s = s.replace( /\u02C6/g, "^" );
		// open angle bracket
		s = s.replace( /\u2039/g, "<" );
		// close angle bracket
		s = s.replace( /\u203A/g, ">" );
		// spaces
		s = s.replace( /[\u02DC|\u00A0]/g, " ");

		return s;
	}
/********** END REPLACE MS WORD CHARACTERS **********/

function processForm( formName, dialogName ) {
	/***** BEGIN AJX CALL *****/
		jQuery.ajax(
			{
				type : "post", 
				url : jQuery( formName ).attr( "action" ), 
				data : jQuery( formName ).serialize(),
				success : function( data ) {
					if( jQuery.trim( data ) == 1 ) { loadMessage( "#" + dialogName, "Record Updated" ); }
					else { loadMessage('#' + dialogName, jQuery.trim( data ) ); }
				},
				error : function ( e ) {
					loadMessage( "#" + dialogName, "ERROR processing request <br><br>" + e );
				}
			}
		);
	/***** END AJX CALL *****/

	jQuery( "#" + dialogName ).dialog( { buttons: { "Close": function() { jQuery( this ).dialog( "close" ); } } } );
}

/********** BEGIN NAME VALUE PAIR JSON DUMP **********/
	function jsonDump( obj ) {
		/***** BEGIN HTML *****/
			var t = '<ul>';
				jQuery.each(
					obj, 
					function( key, val ) {
						t += "<li> " + key + " : ";
							t += ( typeof( val ) == "object" ) ? "<ul>" + jsonDump( val ) + "</ul>" : val;
						t += "</li>";
					}
				);
			t+= '</ul>';
		/***** END HTML *****/

		return t;
	}
/********** END NAME VALUE PAIR JSON DUMP **********/

/********** BEGIN CAMEL CASE BUILDER **********/
	function toCamelCase( str ) {
		return str.replace( /^.|-|\s./g, function( letter, index ) { return index == 0 ? letter.toLowerCase() : letter.substr( 1 ).toUpperCase(); } );
	}
/********** END CAMEL CASE BUILDER **********/

/********** BEGIN OBDC DATE TIME TO JAVASCRIPT DATE **********/
	function createJavascriptDateFromODBCDateTime( odbcDateTime ) {
		odbcDateTime = odbcDateTime.split( "'" )[ 1 ];
		var thisDate = odbcDateTime.split( " " )[0];
		var thisTime = odbcDateTime.split( " " )[ 1 ];

		/***** BEGIN DATE *****/
			var yyyy = thisDate.split( "-" )[ 0 ];
			var mm = thisDate.split( "-" )[ 1 ];
			var dd = thisDate.split( "-" )[ 2 ];
		/***** END DATE *****/

		/***** BEGIN TIME *****/
			var hours = thisTime.split( ":" )[ 0 ];
			var minutes = thisTime.split( ":" )[ 1 ];
			var seconds = thisTime.split( ":" )[ 2 ];
			var milliseconds = 0;
		/***** END TIME *****/

		return new Date( yyyy, mm, dd, hours, minutes, seconds, milliseconds );
	}
/********** END OBDC DATE TIME TO JAVASCRIPT DATE **********/

/********** BEGIN DOS FILE NAME **********/
	function createDOSFileName( json ) {
		return json.name.replace( /\s+/gi, "_" ).replace( /[^a-zA-Z0-9\-\.]/gi, "_");
	}
/********** END DOS FILE NAME **********/

/********** BEGIN FUNCTION NAME ***********/
	function getFunctionName( json ) {
		json.string = json.string.substr( "function ".length );
		json.string = json.string.substr( 0, json.string.indexOf( "(" ) );

		return json.string; 		// RUN THIS IN EACH FUCNTION: getFunctionName( { "string" : arguments.callee.toString() } );
	}
/********** BEGIN FUNCTION NAME ***********/