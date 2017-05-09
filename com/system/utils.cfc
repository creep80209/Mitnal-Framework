component displayname="utils.cfc" hint="Utilities to make things work!" output="true"
{
	remote struct function isUUID(
		string uuid="???"
	)
	 displayname="one function"
	 description="one function"
	 hint=""
	 output="true"
	 returnFormat="JSON"
	{
		/********** BEGIN DEFAULT RETURN VALUE **********/
			local.returnValue = {
				"statusCode" : 1000,
				"requestID" : createUUID(),
				"permissions" : "VALED",
				"message" : "Success",
				"totalRows" : 0,
				"results" : [],
				"eventName" : "/com/system/utils/isUUID",
				"arguments" : {
					"uuid" : { "value" : arguments.uuid, "type" : "string", "default": "", "required" : true, "decription" : "UUID to test" }
				}
			};
		/********** END DEFAULT RETURN VALUE **********/

		/********** BEGIN SECURITY CHECK **********/
			local.thisReturnValue = createObject( "component", "com.system.security" ).check();

			if ( !REFindNoCase( "1\d{3}", local.thisReturnValue.statusCode ) ) {
				local.returnValue.statusCode = local.thisReturnValue.statusCode;
				local.returnValue.message = local.thisReturnValue.message;
			}
		/********** END SECURITY CHECK **********/

		/********** BEGIN UUID TO TEST **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					if ( !REFindNoCase( "^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$", arguments.uuid ) ) {
						local.returnValue.statusCode = 5000;
						local.returnValue.message = "Not an UUID";
						local.returnValue.arguments.uuid["error"] = "The is not valid.";
					}
					else {
						local.returnValue.message = "Is valid UUID";
					}
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast( local.returnValue.eventName, '/' ) & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) { local.returnValue.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message }; }
					if ( isDefined( "e.TagContext" ) ) { local.returnValue.results[ 1 ][ "tagContext" ] = e.TagContext; }
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
//					writeLog( file=application.applicationName, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** BEGIN UUID TO TEST **********/

		return local.returnValue;
	}
	remote struct function getUUID(

	)
	 displayname="Get a UUID from the system."
	 description="Get a UUID from the system."
	 hint=""
	 output="true"
	 returnFormat="JSON"
	{
		/********** BEGIN DEFAULT RETURN VALUE **********/
			local.returnValue = {
				"statusCode" : 1000,
				"requestID" : createUUID(),
				"permissions" : "VALED",
				"message" : "Success",
				"totalRows" : 0,
				"results" : [],
				"eventName" : "/com/system/utils/getUUID",
				"arguments" : {}
			};
		/********** END DEFAULT RETURN VALUE **********/

		/********** BEGIN SECURITY CHECK **********/
			local.thisReturnValue = createObject( "component", "com.system.security" ).check();

			if ( !REFindNoCase( "1\d{3}", local.thisReturnValue.statusCode ) ) {
				local.returnValue.statusCode = local.thisReturnValue.statusCode;
				local.returnValue.message = local.thisReturnValue.message;
			}
		/********** END SECURITY CHECK **********/

		/********** BEGIN UUID **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					local.returnValue.results = createUUID();
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast( local.returnValue.eventName, '/' ) & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) { local.returnValue.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message }; }
					if ( isDefined( "e.TagContext" ) ) { local.returnValue.results[ 1 ][ "tagContext" ] = e.TagContext; }
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
//					writeLog( file=application.applicationName, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** BEGIN UUID TO TEST **********/

		return local.returnValue;
	}
	remote struct function convertToUTF(
		string thisString=""
	)
	 displayname="String to be converted to UTF-8"
	 description="String to be converted to UTF-8"
	 hint=""
	 output="true"
	 returnFormat="JSON"
	{
		/********** BEGIN DEFAULT RETURN VALUE **********/
			local.returnValue = {
				"statusCode" : 1000,
				"requestID" : createUUID(),
				"permissions" : "VALED",
				"message" : "Success",
				"totalRows" : 0,
				"results" : [],
				"eventName" : "/com/system/utils/convertToUTF",
				"arguments" : {
					"thisString" : { "value" : arguments.thisString, "type" : "string", "required" : true, "decription" : "A string value to be converted to UTF-8." }
				}
			};
		/********** END DEFAULT RETURN VALUE **********/

		/********** BEGIN SECURITY CHECK **********/
			local.thisReturnValue = createObject( "component", "com.system.security" ).check();

			if ( !REFindNoCase( "1\d{3}", local.thisReturnValue.statusCode ) ) {
				local.returnValue.statusCode = local.thisReturnValue.statusCode;
				local.returnValue.message = local.thisReturnValue.message;
			}
		/********** END SECURITY CHECK **********/

		/********** BEGIN CHECK FOR MISSING ARGUMENTS **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {

					/***** BEGIN UPDATE OF STATUS CODE*****/
						if ( !REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
							local.returnValue.data.message = "Some required arguments are missing.";
						}
					/***** END UPDATE OF STATUS CODE *****/
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast(local.returnValue.eventName, '/') & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
//					writeLog( file=application.applicationName, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** END CHECK FOR MISSING ARGUMENTS **********/

		/********** BEGIN CONVERSION **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
//					arguments.String = Replace(arguments.thisString, "�", "'", 'all');
//					arguments.String = Replace(arguments.thisString, "�", "'", 'all');
//					arguments.String = Replace(arguments.thisString, '�', '"', 'all');
//					arguments.String = Replace(arguments.thisString, '�', '"', 'all');
//					arguments.String = Replace(arguments.thisString, '�', '&mdash;', 'all');
//					arguments.String = Replace(arguments.thisString, '�', '-', 'all');
//					arguments.String = Replace(arguments.thisString, '�', '...', 'all');
//					arguments.String = Replace(arguments.thisString, '�', '&reg;', 'all');
//					arguments.String = Replace(arguments.thisString, '�', '&trade;', 'all');
//					arguments.String = Replace(arguments.thisString, '�', '&copy;', 'all');

					/* REMOVE LINK TAGS THAT TRY TO LINK TO A LOCAL FILE */
					arguments.String = REReplace(arguments.thisString,'<link[^>]+href="file://[^>]*>', '', 'all');

					/* REMOVE ALL STYLE TAGS */
					arguments.String = ReReplaceNoCase(arguments.thisString,'<style[^>]*?>(.*?)</style.*?>', '', 'all');

					/* REMOVE MICROSOFT OBJECT TAGS */
					arguments.String = REReplace(arguments.thisString,'<object[^>]+id="ie[^>]*?></object.*?>', '', 'all');

					/* REMOVE MICROSOFT o: TAGS */
					arguments.String = REReplace(arguments.thisString,'<o:\b[^>]*?>', '', 'all');
					arguments.String = REReplace(arguments.thisString,'</o:\b[^>]*?>', '', 'all');

					/* REMOVE MICROSOFT MsoNormal CLASS FROM HTML TAGS */
					arguments.String = REReplace(arguments.thisString,' class="MsoNormal"', '', 'all');

					/* REMOVE MICROSOFT stl: HTML TAGS */
					arguments.String = REReplace(arguments.thisString,'<st1:\b[^>]*?>', '', 'all');
					arguments.String = REReplace(arguments.thisString,'</st1:\b[^>]*?>', '', 'all');

					/* REMOVE ALL XML */
					arguments.String = ReReplaceNoCase(arguments.thisString,'<xml[^>]*?></xml.*?>', '', 'all');

					/*
					arguments.String = Trim(ReReplaceNoCase(arguments.thisString, "<span.*?></span.*?>", "\1", "all"));
					arguments.String = Trim(ReReplaceNoCase(arguments.thisString, "<font.*?></font.*?>", "\1", "all"));

					arguments.String = Trim(ReReplaceNoCase(arguments.thisString, "<b.*?>(.*?)</b.*?>", "\1", "all"));
					arguments.String = Trim(ReReplaceNoCase(arguments.thisString, "<i.*?>(.*?)</i.*?>", "\1", "all"));
					arguments.String = Trim(ReReplaceNoCase(arguments.StthisStringring, "<em.*?>(.*?)</em.*?>", "\1", "all"));
					arguments.String = Trim(ReReplaceNoCase(arguments.thisString, "<strong.*?>(.*?)</strong.*?>", "\1", "all"));
					*/

					arguments.String = REReplace(arguments.thisString, '  ', ' ', 'all');
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast(local.returnValue.eventName, '/') & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
//					writeLog( file=application.applicationName, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** END CONVERSION **********/

		/********** BEGIN JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		/********** END JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		return local.returnValue;
	}
	remote struct function characterIntityConverterOutput(
		string thisString=""
	)
	 displayname=""
	 description=""
	 hint=""
	 output="true"
	 returnFormat="JSON"
	{
		/********** BEGIN DEFAULT RETURN VALUE **********/
			local.returnValue = {
				"statusCode" : 1000,
				"requestID" : createUUID(),
				"permissions" : "VALED",
				"message" : "Success",
				"totalRows" : 0,
				"results" : [],
				"eventName" : "/com/system/utils/characterIntityConverterOutput",
				"arguments" : {
					"thisString" : { "value" : arguments.thisString, "type" : "string", "required" : true, "decription" : "" }
				}
			};
		/********** END DEFAULT RETURN VALUE **********/

		/********** BEGIN SECURITY CHECK **********/
			local.thisReturnValue = createObject( "component", "com.system.security" ).check();

			if ( !REFindNoCase( "1\d{3}", local.thisReturnValue.statusCode ) ) {
				local.returnValue.statusCode = local.thisReturnValue.statusCode;
				local.returnValue.message = local.thisReturnValue.message;
			}
		/********** END SECURITY CHECK **********/

		/********** BEGIN CHECK FOR MISSING ARGUMENTS **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					/***** BEGIN STRING CHECK *****/
						if ( trim( arguments.thisString == "" ) ) {
							local.returnValue.statusCode = 4000;
							local.returnValue.arguments.thisString["error"] = "The string value submitted is blank or null";
						}
					/***** END STRING CHECK *****/

					/***** BEGIN UPDATE OF STATUS CODE*****/
						if ( !REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
							local.returnValue.data.message = "Some required arguments are missing.";
						}
					/***** END UPDATE OF STATUS CODE *****/
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast(local.returnValue.eventName, '/') & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
//					writeLog( file=application.applicationName, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** END CHECK FOR MISSING ARGUMENTS **********/

		/********** BEGIN CONVERSION **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					local.temp = arguments.thisString;
					local.temp = Replace( local.temp, "&", "&amp;", "all" );
					local.temp = Replace( local.temp, "<", "&lt;", "all" );
					local.temp = Replace( local.temp, ">", "&gt;", "all" );
					local.temp = Replace( local.temp, '"', "&quot;", "all" );
					local.temp = Replace( local.temp, "'", "&rsquo;", "all" );

					local.returnValue.results = local.temp;
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast(local.returnValue.eventName, '/') & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
//					writeLog( file=application.applicationName, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** END CONVERSION **********/

		/********** BEGIN JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		/********** END JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		return local.returnValue;
	}
	remote struct function characterIntityConverterInput(
		string thisString=""
	)
	 displayname=""
	 description=""
	 hint=""
	 output="true"
	 returnFormat="JSON"
	{
		/********** BEGIN DEFAULT RETURN VALUE **********/
			local.returnValue = {
				"statusCode" : 1000,
				"requestID" : createUUID(),
				"permissions" : "VALED",
				"message" : "Success",
				"totalRows" : 0,
				"results" : [],
				"eventName" : "/com/system/utils/characterIntityConverterInput",
				"arguments" : {
					"thisString" : { "value" : arguments.thisString, "type" : "string", "required" : true, "decription" : "" }
				}
			};
		/********** END DEFAULT RETURN VALUE **********/

		/********** BEGIN SECURITY CHECK **********/
			local.thisReturnValue = createObject( "component", "com.system.security" ).check();

			if ( !REFindNoCase( "1\d{3}", local.thisReturnValue.statusCode ) ) {
				local.returnValue.statusCode = local.thisReturnValue.statusCode;
				local.returnValue.message = local.thisReturnValue.message;
			}
		/********** END SECURITY CHECK **********/

		/********** BEGIN CHECK FOR MISSING ARGUMENTS **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					/***** BEGIN STRING CHECK *****/
						if ( trim( arguments.thisString == "" ) ) {
							local.returnValue.statusCode = 4000;
							local.returnValue.arguments.thisString["error"] = "The string value submitted is blank or null";
						}
					/***** END STRING CHECK *****/

					/***** BEGIN UPDATE OF STATUS CODE*****/
						if ( !REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
							local.returnValue.data.message = "Some required arguments are missing.";
						}
					/***** END UPDATE OF STATUS CODE *****/
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast(local.returnValue.eventName, '/') & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
//					writeLog( file=application.applicationName, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** END CHECK FOR MISSING ARGUMENTS **********/

		/********** BEGIN CONVERSION **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					local.temp = arguments.thisString;
					local.temp = Replace( local.temp, "&lt;", "<", "all" );
					local.temp = Replace( local.temp, "&gt;", ">", "all" );
					local.temp = Replace( local.temp, "&quot;", '"', "all" );
					local.temp = Replace( local.temp, "&rsquo;", "'", "all" );
					local.temp = Replace( local.temp, "&amp;", "&", "all" );

					local.returnValue.results = local.temp;
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast(local.returnValue.eventName, '/') & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
//					writeLog( file=application.applicationName, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** END CONVERSION **********/

		/********** BEGIN JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		/********** END JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		return local.returnValue;
	}
}