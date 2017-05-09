/**************************************\
Created by  Fredrick E. Lewis II
            13Alone Productions LLC
            frerick.e.lewis@gmail.com
\**************************************/

var isChrome = navigator.userAgent.toLowerCase().indexOf( "chrome" ) > -1;

function winOpen( json ) {
	/***** START DEFAULT VALUES *****/
		if ( typeof( json.id ) == "undefined" ) { json.id = "newWindow"; }
		if ( typeof( json.width ) == "undefined" ) { json.width = 660; }
		if ( typeof( json.height ) == "undefined" ) { json.height = 400 } 
		if ( typeof( json.left ) == "undefined" ) { json.left = 200; }
		if ( typeof( json.top ) == "undefined" ) { json.top = 170 }
		if ( typeof( json.resizable ) == "undefined") { json.resizable = 1; }
		if ( typeof( json.scrollbars ) == "undefined" ) { json.scrollbars = 1; }
		if ( typeof( json.toolbars ) == "undefined" ) { json.toolbars = 0; }
		if ( typeof( json.directories ) == "undefined" ) { json.directories = 0; }
		if ( typeof( json.titleBar ) == "undefined" ) { json.titleBar = 0; }
		if ( typeof( json.status ) == "undefined" ) { json.status = 0; }
		if ( typeof( json.location ) == "undefined" ) { json.location = 0; }
		if ( typeof( json.menubar ) == "undefined" ) { json.menubar = 0; }
	/***** END DEFAULT VALUES *****/

	var winType = "width=" + json.width + ", height=" + json.height + ", left=" + json.left + ", top=" + json.top;
	if ( json.resizable ) { winType += ",resizable=yes"; }
	if ( json.scrollbars ) { winType += ",scrollbars=yes"; }
	if ( json.toolbars ) { winType += ",toolbar=yes"; }
	if ( json.directories ) { winType += ",directories=yes"; }
	if ( json.titleBar ) { winType += ",titlebar=yes"; }
	if ( json.status ) { winType += ",status=yes"; }
	if ( !json.status ) { winType += ",location=no"; }
	if ( json.menubar ) { winType += ",menubar=yes"; }

	// OPEN WINDOW	
	json.id = window.open( json.url, json.id, winType );

	// TRY TO CENTER WINDOW
	try {
		var l = ( screen.width ) ? ( screen.width - json.width ) / 2 : 0;
		var t = ( screen.height ) ? ( screen.height - json.height ) / 2 : 0;
		if ( !isChrome ) { json.id.moveTo( l, t ) };
	}
	catch(e) {}

	// FOCUS THE WINDOW
	json.id.focus();
}

function displayErrors( json ) {
	/***** START DEFAULT VALUES *****/
		if ( typeof( json.id ) == "undefined" ) { json.id = "#errorsDialog"; }
		if ( typeof( json.height ) == "undefined" ) { json.height = 300; }
		if ( typeof( json.width ) == "undefined" ) { json.width = 400; }
		if ( typeof( json.align ) == "undefined" ) { json.align = 'center'; }
		if ( typeof( json.valign ) == "undefined" ) { json.valign = 'middle'; }
		if ( typeof( json.buttons ) == "undefined" ) { json.buttons = [ { "text" : "Ok", "click" : function() { $( this ).dialog( "close" ); } } ]; }
	/***** END DEFAULT VALUES *****/

	// check to see if the "errors" container exists
	if ( elementExists( { "id" : "#" + json.id.replace( /#/g, "" ) } ) == 0) { $( "body" ).append( '<div id="' + json.id.replace( /#/g, "" ) + '"></div>' ); }

	// write content to container
	$( "#" + json.id.replace( /#/g, "" ) ).html( '<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0" align="center"><tbody><tr><td align="' + json.align + '" valign="' + json.valign + '">' + json.message + '</td></tr></tbody></table>' );

	// display container as a dialog
	stringToDialog( 
		{ 
			"id" : "#" + json.id.replace( /#/g, "" ), 
			"title" : "Error", 
			"width" : json.width, 
			"height" : json.height, 
			"buttons" : json.buttons
		} 
	);
}

function stringToDialog( json ) {
	/***** BEGIN LOG *****/
		setLoggingRecord( { "title" : getFunctionName( { "string" : arguments.callee.toString() } ) + "() started" } );
	/***** END LOG *****/

	/***** START DEFAULT VALUES *****/
		if ( typeof( json.title ) == "undefined" ) { json.title = ""; }
		if ( typeof( json.height ) == "undefined" ) { json.height = 300; }
		if ( typeof( json.width ) == "undefined" ) { json.width = 400; }
		if ( typeof( json.buttons ) == "undefined" ) { json.buttons = [ { text: "Ok", "click" : function() { $( this ).dialog( "close" ); } } ]; }
	/***** END DEFAULT VALUES *****/

	/********** START WIDTH / HEIGHT CHECKS (INT / STRING) **********/
		// percentage
		if ( typeof( json.width ) == "string" && json.width.indexOf( "%" ) != -1 ) { json.width = ( $(window).width() * ( json.width.replace("%", "") / 100)) } 
		if ( typeof( json.height ) == "string" && json.height.indexOf( "%" ) != -1 ) { json.height = ($(window).height() * ( json.height.replace("%", "") / 100)) }

		// pixels
		if ( typeof( json.width ) == "string" && json.width.indexOf( "px" ) != -1 ) { json.width = json.width.replace("px", "") } 
		if ( typeof( json.height ) == "string" && json.height.indexOf( "px" ) != -1 ) { json.height = json.height.replace("px", "") }
	/********** END WIDTH / HEIGHT CHECKS (INT / STRING) **********/

	// set container if missing
	if (elementExists( { "id" : "#" + json.id.replace( /#/g, "" ) } ) == 0) { $( "body" ).append( '<div id="' + json.id.replace( /#/g, "" ) + '"></div>' ); }

	// dialog dialog
	$( "#" + json.id.replace( /#/g, "" ) ).dialog(
		{
			"title" : json.title, 
			"width" : json.width, 
			"height" : json.height,
			"modal" : true, 
			"open" : function(event, ui) { 
				$( "#" + json.id.replace( /#/g, "" ) ).html();
			},
			"beforeClose" : function(event, ui) { 
				$( "#" + json.id.replace( /#/g, "" ) ).remove();
			}
		}
	);

	dialogButtons( json );
	
	/***** BEGIN LOG *****/
		setLoggingRecord( { "title" : getFunctionName( { "string" : arguments.callee.toString() } ) + "() ended" } );
	/***** END LOG *****/
}

function pageToDialog( json ) {
	/***** START DEFAULT VALUES *****/
		if ( typeof( json.title ) == "undefined" ) { json.title = ""; }
		if ( typeof( json.height ) == "undefined" ) { json.height = 400; }
		if ( typeof( json.width ) == "undefined" ) { json.width = 600; }
		if ( typeof( json.buttons ) == "undefined" ) { json.buttons = [ { text : "Ok", click : function() { $( this ).dialog( "close" ); } } ]; }
	/***** END DEFAULT VALUES *****/

	loadIframe( json );

	$( "#" + json.id.replace( /#/g, "" ) ).dialog(
		{
			"title" : json.title, 
			"width" : json.width, 
			"height" : json.height,
			"modal" : true, 
			"open" : function(event, ui) { 
				$( "#" + json.id.replace( /#/g, "" ) ).html();
			},
			"beforeClose": function(event, ui) { 
				$( "#" + json.id.replace( /#/g, "" ) ).html();
			}
		}
	);
	if ( $.isArray( [ json.buttons ] ) ) { $( "#" + json.id.replace( /#/g, "" ) ).dialog( "option", "buttons", json.buttons ); }
}

function loadIframe( json ) {
	if ( elementExists( { "id": "#" + json.id.replace( /#/g, "" ) } ) == 0) { $( "body" ).append('<div id="' + json.id.replace( /#/g, "" ) + '"></div>' ); }

	$( "#" + json.id.replace( /#/g, "" ) ).html( '<iframe src="' + json.url + '" name="' + json.id.replace(/#/g,"") + 'Iframe" id="' + json.id.replace( /#/g, "" ) + 'Iframe" width="100%" height="100%" marginwidth="0" marginheight="0" align="middle" frameborder="0"></iframe>' );
}

function loadElement( json ) {
	if ( elementExists( { "id" : json.id } ) == 0) { $( "body" ).append('<div id="' + json.id.replace( /#/g, "" ) + '"></div>'); }

	$.ajax(
		{
			"type": "GET", 
			"url": json.url,
			"dataType": json.dataType, 
			"cache": false,
			"success": function(data, textStatus, jqXHR){
				$( "#" + json.id.replace( /#/g, "" ) ).html($.trim(data));
			}, 
			"error": function(xhr, ajaxoptions, thrownError) {
				displayErrors( { "id" : "#errors", "message" : "The page \"" + json.url + "\" could not be found" } );
			}
		}
	);
}

function loadMessage( json ) {
	/***** BEGIN LOG *****/
		setLoggingRecord( { "title" : getFunctionName( { "string" : arguments.callee.toString() } ) + "() started" } );
	/***** END LOG *****/

	
	/***** START DEFAULT VALUES *****/
		if ( !json.align ) { json.align = 'center'; }
		if ( !json.valign ) { json.valign = 'middle'; }
	/***** END DEFAULT VALUES *****/	

	/********** START ELEMENT CHECK **********/
		if ( elementExists( { "id" : "#" + json.id.replace( /#/g, "" ) } ) == 0 ) { $( "body" ).append('<div id="' + json.id.replace("#", "") + '"></div>'); }
	/********** END ELEMENT CHECK **********/
	
	$( json.id ).html( '<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0" align="center"><tbody><tr><td align="' + json.align + '" valign="' + json.valign + '">' + json.message + '</td></tr></tbody></table>' );
	
	
	/***** BEGIN LOG *****/
		setLoggingRecord( { "title" : getFunctionName( { "string" : arguments.callee.toString() } ) + "() ended" } );
	/***** END log *****/

}

function dialogButtons( json ) {
	/***** START DEFAULT VALUES *****/
		if ( typeof( json.buttons ) == "undefined" ) { json.buttons = [ { "text": "Close", "click": function() { $( this ).dialog( "Close" ); } } ]; }
	/***** END DEFAULT VALUES *****/

	if ( $.isArray( [ json.buttons ] ) ) { $( "#" + json.id.replace( /#/g, "" ) ).dialog( "option", "buttons", json.buttons ); }
}