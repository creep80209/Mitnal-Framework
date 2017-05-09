component hint="CRUD File and Directory Management" output="true"
{
	remote any function createFile(
		string header="",
		any body="",
		string footer="",
		string fileName="",
		string filePath="",
		boolean writeOver=TRUE
	)
	displayname="createFile"
	description=""
	output="true"
	returnformat="JSON"
	{
		/***** BEGIN DEFAULT RETURN VALUE *****/
			local.returnValue = {
				"statusCode" : 1000,
				"requestID" : createUUID(),
				"permissions" : "VALED",
				"message" : "Success",
				"totalRows" : 0,
				"results" : [],
				"eventName" : "/com/file/createFile",
				"arguments" : {
					"header" : { "value" : arguments.header, "required" : false },
					"body" : { "value" : arguments.body, "required" : false },
					"footer" : { "value" : arguments.footer, "required" : false },
					"fileName" : { "value" : arguments.fileName, "required" : true },
					"filePath" : { "value" : arguments.filePath, "required" : true },
					"writeOver" : { "value" : arguments.writeOver, "required" : true }
				}
			};
		/***** END DEFAULT RETURN VALUE *****/

		/***** BEGIN SECURITY CHECK *****/
			try {
				thisResult = createObject("component", "com.utils").getUserIP();

				if ( !REFindNoCase( "^10.147.180.", thisResult.data.results.thisUsersIP ) ) {
					local.returnValue.statusCode = 6000;
					local.returnValue.data.message = "You do not have access to this service item";
					local.returnValue.permissions = "";
				}
			}
			catch ( any e ) {
				writeDump(e);
			}
		/***** END SECURITY CHECK *****/

		/***** BEGIN CHECK FOR MISSING ARGUMENTS *****/
			/***** BEGIN FILE PATH CHECK *****/
				if ( trim( arguments.filePath ) == "" ) {
					local.returnValue.statusCode = 4000;
					local.returnValue.arguments.filePath["error"] = "The file path is blank";
				}
				else if ( REFindNoCase( "(~|`|\[|\]|\^|<|>|\*|\|)", arguments.filePath ) ) {
					local.returnValue.statusCode = 4000;
					local.returnValue.arguments.filePath["error"] = "The file path contain invalid character(s)";
				}
				else if ( REFindNoCase( "^[cC]:", arguments.filePath ) ) {
					local.returnValue.statusCode = 4000;
					local.returnValue.arguments.filePath["error"] = "You do not have permissing to write to the C drive.";
				}
				else if ( !REFindNoCase( "^[[:alpha:]]{1}:\\(.*)", arguments.filePath ) ) {
					local.returnValue.statusCode = 4000;
					local.returnValue.arguments.filePath["error"] = "The file path is not valid";
				}
			/***** END FILE PATH CHECK *****/

			/***** BEGIN FILE NAME CHECK *****/
				if ( trim( arguments.fileName ) == "" ) {
					local.returnValue.statusCode = 4000;
					local.returnValue.arguments.fileName["error"] = "The file name is blank";
				}
				else if ( REFindNoCase( "(\\|~|`|\[|\]|\^|<|>|\*|\|)", arguments.fileName ) ) {
					local.returnValue.statusCode = 4000;
					local.returnValue.arguments.fileName["error"] = "The file name contain invalid character(s)";
				}
				else if ( !REFindNoCase( "^\w{1}(.)*\.(txt|text|json|css|htm|html)$", arguments.fileName ) ) {
					local.returnValue.statusCode = 4000;
					local.returnValue.arguments.fileName["error"] = "The file name is not an exceptible file type";
				}
			/***** END FILE NAME CHECK *****/

			/***** BEGIN UPDATE OF STATUS CODE*****/
				if ( !REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					local.returnValue.data.message = "Some required arguments are missing.";
				}
			/***** END UPDATE OF STATUS CODE *****/
		/***** END CHECK FOR MISSING ARGUMENTS *****/

		/***** BEGIN FILE PATH CHECK *****/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					if ( !directoryExists( arguments.filePath ) ) {
						local.returnValue.statusCode = 5000;
						local.returnValue.data.message = "The file path '" & arguments.filePath & "' does not exist.";
					}
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.data.message = "An error occured while running the method <tt>" & ListLast( local.returnValue.eventName, "/" ) & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.data.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.data.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
					writeLog( file=application.name, type="Error", text=local.returnValue.data.message );
				/***** END LOG UPDATE *****/
			}
		/***** END FILE PATH CHECK *****/

		/***** BEGIN FILE WRITING *****/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {

					/***** BEGIN CONTENT *****/
						local.thisContent = '';

						if ( trim( arguments.header ) != "" ) {
							local.thisContent &= arguments.header & chr(10);
						}

						if ( trim( arguments.body ) != "" ) {
							local.thisContent &= arguments.body & chr(10);
						}

						local.thisContent &= arguments.footer & chr(10);
					/***** END CONTENT *****/


					// WRITE CONTENT TO FILE
					fileWrite( arguments.filePath & "\" & arguments.fileName, local.thisContent );
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.data.message = "An error occured while running the method <tt>" & ListLast( local.returnValue.eventName, "/" ) & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.data.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.data.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
					writeLog( file=application.name, type="Error", text=local.returnValue.data.message );
				/***** END LOG UPDATE *****/
			}
		/***** END FILE WRITING *****/

		return local.returnValue;
	}
	remote any function getFileInfo(
		string path=""
	)
	displayname="getFileInfo"
	description=""
	output="true"
	returnformat="JSON"
	{
		/***** BEGIN DEFAULT RETURN VALUE *****/
			local.returnValue = {
				"statusCode" : 1000,
				"requestID" : createUUID(),
				"permissions" : "VALED",
				"data" = {
					"message" : "Success",
					"totalRows" : 0,
					"results" : []
				},
				"eventName" : "/com/file/getFileInfo",
				"arguments" : {
					"path" : { "value" : arguments.path, "required" : true }
				}
			};
		/***** END DEFAULT RETURN VALUE *****/

		/***** BEGIN SECURITY CHECK *****/
			try {
				thisResult = createObject("component", "com.utils").getUserIP();

				if ( !REFindNoCase( "^10.147.180.", thisResult.data.results.thisUsersIP ) ) {
					local.returnValue.statusCode = 6000;
					local.returnValue.data.message = "You do not have access to this service item";
					local.returnValue.permissions = "";
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.data.message = "An error occured while running the method <tt>" & ListLast( local.returnValue.eventName, "/" ) & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.data.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.data.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/
			}
		/***** END SECURITY CHECK *****/

		/***** BEGIN CHECK FOR MISSING ARGUMENTS *****/
			/***** BEGIN FILE PATH CHECK *****/
				if ( trim( arguments.path ) == "" ) {
					local.returnValue.statusCode = 4000;
					local.returnValue.arguments.path["error"] = "The file path is blank";
				}
			/***** END FILE PATH CHECK *****/

			/***** BEGIN UPDATE OF STATUS CODE*****/
				if ( !REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					local.returnValue.data.message = "Some required arguments are missing.";
				}
			/***** END UPDATE OF STATUS CODE *****/
		/***** END CHECK FOR MISSING ARGUMENTS *****/

		/***** BEGIN FILE PATH CHECK *****/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					if ( !fileExists( arguments.path ) ) {
						local.returnValue.statusCode = 5000;
						local.returnValue.data.message = "The file path '" & arguments.path & "' does not exist.";
					}
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.data.message = "An error occured while running the method <tt>" & ListLast( local.returnValue.eventName, "/" ) & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.data.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.data.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
					writeLog( file=application.name, type="Error", text=local.returnValue.data.message );
				/***** END LOG UPDATE *****/
			}
		/***** END FOLDER PATH CHECK *****/

		/***** BEGIN FOLDER LIST *****/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {

					local.returnValue.data.results = GetFileInfo(
						arguments.path
					);
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.data.message = "An error occured while running the method <tt>" & ListLast( local.returnValue.eventName, "/" ) & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.data.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.data.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
					writeLog( file=application.name, type="Error", text=local.returnValue.data.message );
				/***** END LOG UPDATE *****/
			}
		/***** END FOLDER LIST *****/

		return local.returnValue;
	}
	remote any function getFolder(
		string path="",
		boolean recurse=false,
		string listInfo="query",
		any filter="",
		string type="both",
		string sort="directory ASC",
		date startDate = "01/01/1800",
		date endDate = DateFormat( now(), "MM/DD/YYYY" )
	)
	displayname="getFolder"
	description=""
	output="true"
	returnformat="JSON"
	{
		/***** BEGIN DEFAULT RETURN VALUE *****/
			local.returnValue = {
				"statusCode" : 1000,
				"requestID" : createUUID(),
				"permissions" : "VALED",
				"data" = {
					"message" : "Success",
					"totalRows" : 0,
					"results" : []
				},
				"eventName" : "/com/file/getFolder",
				"arguments" : {
					"path" : { "value" : arguments.path, "type" : "string", "required" : true },
					"recurse" : { "value" : arguments.recurse, "type" : "boolean", "required" : false },
					"listInfo" : { "value" : arguments.listInfo, "type" : "string","required" : false },
					"filter" : { "value" : arguments.filter, "type" : "any", "required" : false },
					"type" : { "value" : arguments.type, "type" : "string", "required" : false },
					"sort" : { "value" : arguments.sort, "type" : "string", "required" : false },
					"startDate"  : { "value" : arguments.endDate, "type" : "string", "required" : false },
					"endDate"  : { "value" : arguments.endDate, "type" : "string", "required" : false }
				}
			};
		/***** END DEFAULT RETURN VALUE *****/

		/***** BEGIN SECURITY CHECK *****/
			try {
				thisResult = createObject("component", "com.utils").getUserIP();

				if ( !REFindNoCase( "^10.147.180.", thisResult.data.results.thisUsersIP ) ) {
					local.returnValue.statusCode = 6000;
					local.returnValue.data.message = "You do not have access to this service item";
					local.returnValue.permissions = "";
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.data.message = "An error occured while running the method <tt>" & ListLast( local.returnValue.eventName, "/" ) & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.data.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.data.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/
			}
		/***** END SECURITY CHECK *****/

		/***** BEGIN CHECK FOR MISSING ARGUMENTS *****/
			/***** BEGIN FILE PATH CHECK *****/
				if ( trim( arguments.path ) == "" ) {
					local.returnValue.statusCode = 4000;
					local.returnValue.arguments.path["error"] = "The file path is blank";
				}
				else if ( REFindNoCase( "(~|`|\[|\]|\^|<|>|\*|\|)", arguments.path ) ) {
					local.returnValue.statusCode = 4000;
					local.returnValue.arguments.path["error"] = "The file path contain invalid character(s)";
				}
				else if ( REFindNoCase( "^[cC]:", arguments.path ) ) {
					local.returnValue.statusCode = 4000;
					local.returnValue.arguments.path["error"] = "You do not have permissing to write to the C drive.";
				}
				else if ( !REFindNoCase( "^[[:alpha:]]{1}:\\(.*)", arguments.path ) ) {
					local.returnValue.statusCode = 4000;
					local.returnValue.arguments.path["error"] = "The file path is not valid";
				}
			/***** END FILE PATH CHECK *****/

			/***** BEGIN UPDATE OF STATUS CODE*****/
				if ( !REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					local.returnValue.data.message = "Some required arguments are missing.";
				}
			/***** END UPDATE OF STATUS CODE *****/
		/***** END CHECK FOR MISSING ARGUMENTS *****/

		/***** BEGIN FOLDER PATH CHECK *****/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					if ( !directoryExists( arguments.path ) ) {
						local.returnValue.statusCode = 5000;
						local.returnValue.data.message = "The folder path '" & arguments.path & "' does not exist.";
					}
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.data.message = "An error occured while running the method <tt>" & ListLast( local.returnValue.eventName, "/" ) & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.data.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.data.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
					writeLog( file=application.name, type="Error", text=local.returnValue.data.message );
				/***** END LOG UPDATE *****/
			}
		/***** END FOLDER PATH CHECK *****/

		/***** BEGIN FOLDER LIST *****/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {

					local.thisQuery = DirectoryList(
						arguments.path,
						arguments.recurse,
						arguments.listInfo,
						arguments.filter,
						arguments.type
					);

					local.i = 0;

					for ( A in local.thisQuery ) {
						if ( A.DATELASTMODIFIED <= arguments.endDate && A.DATELASTMODIFIED >= arguments.startDate ) {
							local.i++;
							local.returnValue.data.results[ local.i ][ "type" ] = A.TYPE;
							local.returnValue.data.results[ local.i ][ "directory" ] = A.DIRECTORY;
							local.returnValue.data.results[ local.i ][ "name" ] = A.NAME;
							local.returnValue.data.results[ local.i ][ "size" ] = A.SIZE;
							local.returnValue.data.results[ local.i ][ "dateLastModified" ] = A.DATELASTMODIFIED;
							local.returnValue.data.results[ local.i ][ "attributes" ] = A.ATTRIBUTES;
							local.returnValue.data.results[ local.i ][ "mode" ] = A.MODE;
						}
					}

					// SET TOTAL ROWS
					local.returnValue.data.totalRows = local.i;
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.data.message = "An error occured while running the method <tt>" & ListLast( local.returnValue.eventName, "/" ) & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.data.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.data.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
					writeLog( file=application.name, type="Error", text=local.returnValue.data.message );
				/***** END LOG UPDATE *****/
			}
		/***** END FOLDER LIST *****/

		return local.returnValue;
	}
	remote any function deletePath(
		string path="",
		boolean recursive=false
	) {
		/***** BEGIN DEFAULT RETURN VALUE *****/
			local.returnValue = {
				"statusCode" : 1000,
				"requestID" : createUUID(),
				"permissions" : "VALED",
				"data" = {
					"message" : "Success",
					"totalRows" : 0,
					"results" : []
				},
				"eventName" : "/com/file/deletePath",
				"arguments" : {
					"path" : { "value" : arguments.path, "required" : true, "type" : "string" },
					"recursive" : { "value" : arguments.recursive, "required" : false, "type" : "boolean" }
				}
			};
		/***** END DEFAULT RETURN VALUE *****/

		/***** BEGIN SECURITY CHECK *****/
			try {
				thisResult = createObject("component", "com.utils").getUserIP();

				if ( !REFindNoCase( "^10.147.180.", thisResult.data.results.thisUsersIP ) ) {
					local.returnValue.statusCode = 3000;
					local.returnValue.data.message = "You do not have access to this service item";
					local.returnValue.permissions = "";
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.data.message = "An error occured while running the method <tt>" & ListLast( local.returnValue.eventName, "/" ) & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.data.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.data.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/
			}
		/***** END SECURITY CHECK *****/

		/***** BEGIN ARGUMENTS CHECK *****/
			/***** BEGIN PATH CHECK *****/
				try {
					if ( REFind( "^1\d{3}$", local.returnValue.statusCode ) ) {
						if( !REfindNoCase( '^(D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z):\\', trim( arguments.path ) ) ) {
							local.returnValue.statusCode = 3000;
							local.returnValue.data.message = "The directory path ( " & arguments.path & " ) to be delete did not match the required a pattern.";
						}
					}
				}
				catch ( any e ) {
					/***** END BEGIN ERROR MESSAGE *****/
						local.returnValue.statusCode = 5000;
						local.returnValue.data.message = "An error occured while running the method <tt>" & ListLast( local.returnValue.eventName, "/" ) & "</tt>. The error message is " & e.Message & ".";

						if ( isDefined( "e.RootCause.Message" ) ) {
							 local.returnValue.data.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
						}

						if ( isDefined( "e.TagContext" ) ) {
							local.returnValue.data.results[ 1 ][ "tagContext" ] = e.TagContext;
						}
					/***** END BEGIN ERROR MESSAGE *****/
				}
			/***** END PATH CHECK *****/
		/***** END ARGUMENTS CHECK *****/

		/***** BEGIN PROCESS *****/
			try {
				if ( REFind( "^1\d{3}$", local.returnValue.statusCode ) ) {
					if ( arguments.recursive ) {
						local.thisNewPath = arguments.path;

						for ( local.A=listLen( local.thisNewPath, "\" ); local.A > 1; local.A-- ) {
							/***** BEGIN STOP WHEN YOU GET TO ROOT OF DRIVE *****/
								if ( REfindNoCase( "^\w:(\\)?$", local.thisNewPath ) ) {
									break;
								}
							/***** END STOP WHEN YOU GET TO ROOT OF DRIVE *****/

							/***** BEGIN FOLDER CHECK FOR MORE FILES OR DIRECTORIES *****/
								if ( fileExists( local.thisNewPath ) ) {
									fileDelete( local.thisNewPath );

									/***** BEGIN UPDATE THE RETURN MESSAGE *****/
										local.returnValue.data.message = "The file ( " & local.thisNewPath & " ) was deleted" & chr(12);
									/***** END UPDATE THE RETURN MESSAGE *****/
								}
								else if ( directoryExists( local.thisNewPath ) ) {
									/***** BEGIN CHECK TO SEE IF PATH IS EMPTY *****/
										local.thisReturnValue = getFolder(
											path=local.thisNewPath
										);
									/***** END CHECK TO SEE IF PATH IS EMPTY *****/

									if ( REFind( "^1\d{3}$", local.thisReturnValue.statusCode ) ) {
										if ( local.thisReturnValue.data.totalRows == 0 ) {
											directoryDelete( local.thisNewPath );

											/***** BEGIN UPDATE THE RETURN MESSAGE *****/
												local.returnValue.data.message = "The directory ( " & local.thisNewPath & " ) was deleted";
											/***** END UPDATE THE RETURN MESSAGE *****/
										}
										else {
											local.returnValue.statusCode = local.thisReturnValue.statusCode;
											local.returnValue.data.message = "The directory ( " & local.thisNewPath & " ) is not empty";
											break;
										}
									}
								}
								else {
									local.returnValue.statusCode = 5000;
									local.returnValue.data.message = "The file or directory ( " & local.thisNewPath & " ) does not exist.";
									break;
								}
							/***** END FOLDER CHECK FOR MORE FILES OR DIRECTORIES *****/

							/***** BEGIN PATH UPDATE *****/
								local.thisNewPath = listDeleteAt( local.thisNewPath, local.A, "\" );
							/***** END PATH UPDATE *****/
						}
					}
					else {
						if ( fileExists( arguments.path ) ) {
							fileDelete( arguments.path );

							/***** BEGIN UPDATE THE RETURN MESSAGE *****/
								local.returnValue.data.message = "The file ( " & arguments.path & " ) was deleted";
							/***** END UPDATE THE RETURN MESSAGE *****/
						}
						else if ( directoryExists( arguments.path ) ) {
							directoryDelete( arguments.path );

							/***** BEGIN UPDATE THE RETURN MESSAGE *****/
								local.returnValue.data.message = "The directory ( " & arguments.path & " ) was deleted";
							/***** END UPDATE THE RETURN MESSAGE *****/
						}
					}
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.data.message = "An error occured while running the method <tt>" & ListLast( local.returnValue.eventName, "/" ) & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.data.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.data.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/
			}
		/***** END PROCESS *****/

		return local.returnValue;
	}
	remote struct function setFileNaming(
		string string=""
	)
	 displayname="setFileNaming"
	 description=""
	 hint="one"
	 output="true"
	 returnFormat="JSON"
	{
		/***** BEGIN DEFAULT RETURN VALUE *****/
			local.returnValue = {
				"statusCode" : 1000,
				"requestID" : setFileNaming(),
				"permissions" : "VALED",
				"message" : "Success",
				"totalRows" : 1,
				"results" : []
				"eventName" : "/com/system/fileManagement/setFileNaming",
				"arguments" : {}
			};
		/***** END DEFAULT RETURN VALUE *****/

 		/***** BEGIN STRING CLEANER *****/
 			arguments.String = Replace( arguments.String, "�", "'", 'all' );
			arguments.String = Replace( arguments.String, "�", "'", 'all' );
			arguments.String = Replace( arguments.String, '�', '"', 'all' );
			arguments.String = Replace( arguments.String, '�', '"', 'all' );
			arguments.String = Replace( arguments.String, '�', '-', 'all' );
			arguments.String = Replace( arguments.String, '_', ' ', 'all' );
			arguments.String = Replace( arguments.String, '\', '', 'all' );
			arguments.String = Replace( arguments.String, '/', '', 'all' );
			arguments.String = Replace( arguments.String, ':', '', 'all' );
			arguments.String = Replace( arguments.String, '*', '', 'all' );
			arguments.String = Replace( arguments.String, '?', '', 'all' );
			arguments.String = Replace( arguments.String, '"', '', 'all' );
			arguments.String = Replace( arguments.String, "'", '', 'all' );
			arguments.String = Replace( arguments.String, "<", '', 'all' );
			arguments.String = Replace( arguments.String, ">", '', 'all' );
			arguments.String = Replace( arguments.String, "|", '', 'all' );


 			local.returnValue.data.results["fileName"] = arguments.String;
 		/***** END UUID CHECK *****/

 		return local.returnValue;
	}
}