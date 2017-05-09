/********** BEGIN GLOBAL VARIABLES **********/ 
	var global = { 
		"name" : "Mitnal",
		"files" : [], 
		"containers" : {}, 
		"data" : {},
		"settings" : {
			"cfc" : "/com/", 
			"logging" : {
				"recordCount" : 100
			}, 
			"Modules" : { }
		}, 
		"logging" : [ 
			{ "type" : "system", "statusCode" : 1000, "title" : "System", "message" : "Global Variable Created"  } 
		]
	};
/********** END GLOBAL VARIABLES **********/

/********** BEGIN DOCUMENT **********/
	jQuery(document).ready(
		function() {
			jQuery.support.cors = true;

			/***** BEGIN SUPPORT FILES *****/
				resourceLoad( 
					[
						//{ "url" : "" }
					]
				);
			/***** END SUPPORT FILES *****/
		}
	);
/********** END DOCUMENT **********/

/********** BEGIN FUNCTION NAME ***********/
	function getFunctionName( json ) {
		json.string = json.string.substr( "function ".length );
		json.string = json.string.substr( 0, json.string.indexOf( "(" ) );

		return json.string; 		// RUN THIS IN EACH FUCNTION: getFunctionName( { "string" : arguments.callee.toString() } );
	}
/********** END FUNCTION NAME ***********/

/********** BEGIN IS DEFINED **********/
	function isDefined( x ) {
		return ( typeof( x ) !== "undefined" ) ? true : false;
	}
/********** END IS DEFINED **********/

/********** BEGIN IS OBJECT **********/
	function isObject( x ) {
		return ( typeof( x ) !== "object" ) ? true : false;
	}
/********** END IS OBJECT **********/

/********** BEGIN ELEMENT EXISTS **********/
	function elementExists( json ) {
		return ( $( json.id ).length ) ? true : false;
	}
/********** END ELEMENT EXISTS **********/

/********** BEGIN GET URL PARAMETERS **********/
	function getURLParameters( paramName ) {
		/***** BEGIN RECORD ERROR *****/
			setLoggingRecord( { "title" : getFunctionName( { "string" : arguments.callee.toString() } ) + "() started" } );
		/***** END RECORD ERROR *****/

		/***** BEGIN URL TO VARIABLE *****/
			sURL = window.document.URL.toString();
			if ( sURL.indexOf( "?" ) > 0 ) {
				arrParams = sURL.split( "?" );
				arrURLParams = arrParams[ 1 ].split( "&" );
				arrParamNames = new Array( arrURLParams.length );
				arrParamValues = new Array( arrURLParams.length );

				for ( i in arrURLParams ) {
					sParam = arrURLParams[ i ].split( "=" );
					arrParamNames[ i ] = sParam[ 0 ];
					arrParamValues[ i ] = ( sParam[ 1 ] != "" ) ? unescape( sParam[ 1 ] ) : ""; 
				}

				for ( i in arrURLParams ) {
					if ( new RegExp( paramName, "i" ).test( arrParamNames[ i ] ) ) { return arrParamValues[ i ]; }
				}
			}
		/***** END URL TO VARIABLE *****/

		/***** BEGIN RECORD ERROR *****/
			setLoggingRecord( { "title" : getFunctionName( { "string" : arguments.callee.toString() } ) + "() ended" } );
		/***** END RECORD ERROR *****/
	}
/********** END URL PARAMETERS **********/

/********** BEGIN LOADING RESOURCES **********/
	function resourceLoad( json ) {
		/***** BEGIN LOG *****/
			setLoggingRecord( { "title" : getFunctionName( { "string" : arguments.callee.toString() } ) + "() started" } );
		/***** END LOG *****/

		for ( i in json ) {
			if ( /\.(css)$/i.test( json[ i ].url ) ) {
				jQuery( "head" ).append( "<link>" );
				jQuery( "head" ).children( ":last" ).attr( { rel: "stylesheet", type: "text/css", href: json[ i ].url } );

				/***** BEGIN LOG *****/
					setLoggingRecord( { "title" : json[ i ].url + " loaded" } );
				/***** END LOG *****/
			}
			else if ( /\.(js)$/i.test( json[ i ].url ) ) {
				// LOAD RESOURCE
				if ( isResourceLoaded( [ { "url" : json[ i ].url } ] ) === 0 ) {
					/***** BEGIN GET SCRIPT *****/
						jQuery.ajax(
							{
								type: "GET", 
								url: json[ i ].url,
								contentType: "application/html; charset=utf-8",
								dataType: "script", 
								async: false, 
								cache: false,
								success: function( data, textStatus, jqXHR ){
									/****** END DATA PROCESS *****/
										if ( textStatus === "success" ) {
											//UPDATE GLOBAL CONTAINER LIST
											if ( isDefined( json[ i ].container ) ) { global[ "containers" ][ json[ i ].container.name ] = json[ i ].container.value; }

											/***** BEGIN UPDATE GLOBAL CONTAINER LIST *****/
												addToSriptsArray = 1;

												if ( global.files.length !== 0 ) {
													for ( A in global.files ) {
														if ( global.files[ A ].url == json[ i ].url ) {
															addToSriptsArray = 0;
															break;
														}
													}
												}
												if ( addToSriptsArray === 1 ) {
													global.files.push( { "url" : json[ i ].url } );
												}
											/***** END UPDATE GLOBAL CONTAINER LIST *****/
										}
									/****** END DATA PROCESS *****/

									/***** BEGIN LOG *****/
										setLoggingRecord( { "title" : "downloaded <strong>" + json[ i ].url + "</strong>" } );
									/***** END LOG *****/
								}, 
								error: function( xhr, ajaxoptions, thrownError ) {
									/***** BEGIN ERROR MESSAGE *****/
										displayErrors( { "id" : "#errorsDialog", "message" : thrownError } );
									/***** END ERROR MESSAGE *****/
								}
							}
						);
					/***** END GET SCRIPT *****/
				}
			}
		}

		/***** BEGIN RECORD ERROR *****/
			setLoggingRecord( { "title" : getFunctionName( { "string" : arguments.callee.toString() } ) + "() ended" } );
		/***** END RECORD ERROR *****/

		return true;
	}
	function isResourceLoaded( json ) {
		/***** BEGIN LOG *****/
			setLoggingRecord( { "title" : getFunctionName( { "string" : arguments.callee.toString() } ) + "() started" } );
		/***** END LOG *****/

		/***** BEGIN DEFAULT VALUES *****/
			returnValue = 0;
		/***** END DEFAULT VALUES *****/

		/***** BEGIN LOG *****/
			setLoggingRecord( { "title" : "checking <strong>" + json[0].url + "</strong>" } );
		/***** END LOG *****/

		/***** BEGIN CHECKING FILES *****/
			for ( i in json.length ) {
				thisURL = json[ i ].url;
				found = 0;

				/***** BEGIN TEST TO SEE IF FILE EXISTS *****/
					if ( /\.(css)$/i.test( thisURL ) ) {
						jQuery('link').each( function( i ) { if ( jQuery( this ).attr( "src" ) === thisURL) { found = 1; return( false ); } } );
					}
					else if ( /\.(js)$/i.test( thisURL ) ) {
						// CHECK MANUALLY LOADED JS FILES
						jQuery( "script[src]" ).each( function( i ) { if ( jQuery(this).attr( "src" ) == thisURL ) { found = 1; return( false ); } } );

						// CHECK DOWNLOAD FILES LISTED IN THE GLOBAL 
						if ( found === 0 && global.files.length !== 0 ) {
							for ( A in global.files ) {
								if ( global.files[ A ].url === thisURL ) {
									returnValue = 1;

									break;
								}
							}
						}
					}
				/***** END TEST TO SEE IF FILE EXISTS *****/

				/***** BEGIN TEST TO SEE IF WE SHOULD LOAD MISSING FILE *****/
					if ( found === 0 ) {
						if ( isDefined( json[ i ].loadMissing ) != "undefined" && json[ i ].loadMissing ) {
							resourceLoad( [ { "url" : thisURL } ] );
							returnValue = 1;
						}
					}
					else { returnValue = 1; }
				/***** END TEST TO SEE IF WE SHOULD LOAD MISSING FILE *****/
			}
		/***** END CHECKING FILES *****/

		/***** BEGIN LOG *****/
			setLoggingRecord( { "title" : getFunctionName( { "string" : arguments.callee.toString() } ) + "() ended" } );
		/***** END log *****/

		return returnValue;
	}
/********** END LOADING RESOURCES **********/

/********** BEGIN LOGGING **********/
	function setLoggingRecord( json ) {
		try {
			if ( /^1\d{3}$/.test( getLoggingStatusCode() ) ) {
				if ( !isDefined( json.type ) ) { json.type = "generic"; }
				if ( !isDefined( json.statusCode ) ) { json.statusCode = 1000; }
				if ( !isDefined( json.timestamp ) ) { json.timestamp = Date.now(); }
				if ( !isDefined( json.continue ) ) { json.continue = true; }

				/***** BEGIN GLOBAL UPDATE *****/
					if ( !isDefined( global.settings.logging.recordCount ) ) { global.settings.logging.recordCount = 25; }

					if ( global.logging.length >= global.settings.logging.recordCount ) {
						global.logging.shift(); // DELETE THE FIRST ELEMENT
					}

					global.logging[ global.logging.length ] = json;
				/***** END GLOBAL UPDATE *****/

				/***** BEGIN ERROR DIALOG *****/
					if ( isDefined( json.dialog ) || json.type === "error" ) {
						if ( !isDefined( json.dialog ) ) { json.dialog = {}; }
						if ( !isDefined( json.dialog.align ) ) { json.dialog.align = "center"; }
						if ( !isDefined( json.dialog.valign ) ) { json.dialog.valign = "middle"; }
						if ( !isDefined( json.dialog.height ) ) { json.dialog.height = 300; }
						if ( !isDefined( json.dialog.width ) ) { json.dialog.width = 400; }

						/***** BEGIN LOADING SCREEN *****/
//							hideLoadingScreenDialog( {} );
						/***** END LOADING SCREEN *****/

						/***** BEGIN LOADING MESSAGE TO CONTAINER *****/
							loadMessage( { "id" : "#loggingDialog", "align" : json.dialog.align, "valign" : json.dialog.valign, "message" : ( !isDefined( json.dialog.message ) ) ? json.message : json.dialog.message }  );
						/***** END LOADING MESSAGE TO CONTAINER *****/

						/***** BEGIN DISPLAY CONTENT INTO DIALOG *****/
							stringToDialog( 
								{ 
									"id" : "#loggingDialog", 
									"title" : ( !isDefined( json.dialog.title ) ) ? json.title: json.dialog.title, 
									"height" : json.dialog.height, 
									"width" : json.dialog.width, 
									"dialogClass" : json.type + "-dialog", 
									"buttons" : [ 
										{ 
											text: "Close", 
											click: function() {
												if ( json.continue ) {
													// CLEAN LAST ERROR TO ALLOW USERS TO CONTINUE
													global.logging[ global.logging.length ] = { "type" : "system", "statusCode" : 1000, "title" : "Continue", "message" : "You may continue." };
												}

												$( this ).dialog( "close" ); 
											} 
										} 
									] 
								} 
							);
						/***** END DISPLAY CONTENT INTO DIALOG *****/
					}
				/***** END ERROR DIALOG *****/
			}
		}
		catch ( e ) { 
			try { console.log( e ); } catch ( e ) { alert( e ); }
		}
	}
	function getLoggingStatusCode() {
		try { return global.logging[ global.logging.length - 1 ].statusCode; }
		catch ( e ){ try { console.log( e ); } catch ( e ) { alert( e ); } }
	}
	function getLoggingRecord( json ) {
		/***** BEGIN DEFAULT VALUES *****/
			if ( !isDefined( json ) ) { json = {}; } 
			if ( !isDefined( json.record ) ) { json.record = global.length; }

			t = '';
		/***** END DEFAULT VALUES *****/

		return global.logging[ json.record ];
	}
	function dumpLogging() {
		/***** BEGIN DEBUG DIALOG *****/
			thisDebug = '';

			for ( A in global.logging ) {
				thisDateTime = new Date(global.logging[ A ].timestamp);
				
				thisDebug += '<div class="' + global.logging[ A ].type  + '">';
					thisDebug += '<span>' + A + '</span>';
					thisDebug += '<span>' + global.logging[ A ].type + '</span>';
					thisDebug += '<span>';
						thisDebug += '<header>' + global.logging[ A ].title + '</header>';
						//thisDebug += ( global.logging[ A ].message !== "" ) ? '<div>' + global.logging[ A ].message + '</div>' : '';
					thisDebug += '</span>';
					thisDebug += '<span>' + timeFormat( { "date" : thisDateTime } ) + '</span>';
				thisDebug += '</div>';
			}

			$( "#debug > section > article " ).append( thisDebug );
		/***** END DEBUG DIALOG *****/
	}
	function underConstruction( json ) {
		/***** START DEFAULT VALUES *****/
			t = '';
		/***** END DEFAULT VALUES *****/

		/***** BEGIN DATA TO DIALOG *****/
			loadMessage( { "id" : "#UnderConstructionDialog", "align" : "center", "valign" : "middle", "message" : "<h2>This Feature has yet to be completed.</h2>" } );
			stringToDialog( { "id" : "#UnderConstructionDialog", "title" : "Under Construction", "dialogClass" : "notice-dialog", "height" : "320", "width" : "480", "buttons" : [ { text: "Close", click: function() { $( this ).dialog( "close" ); } } ] } );
		/***** END DATA TO DIALOG *****/

		/***** BEGIN RECORD ERROR *****/
			setLoggingRecord( { "title" : getFunctionName( { "string" : arguments.callee.toString() } ) + "() started" } );
		/***** END RECORD ERROR *****/
	}
/********** END LOGGING **********/