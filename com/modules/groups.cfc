component displayname="groups" hint="this is just a valued tempate" output="true"
{
	remote struct function getGroup(
		any groupID="~",
		string GroupName="~", 
		string groupStatus="Active"
	)
	 displayname="one function"
	 description="one function"
	 hint="one"
	 output="true"
	 returnFormat="JSON"
	{
		/********** BEGIN DEFAULT RETURN VALUE **********/
			local.returnValue = {
				"statusCode" : 1000,
				"requestID" : createUUID(),
				"permissions" : "",
				"message" : "Success",
				"totalRows" : 0,
				"results" : [],
				"eventName" : "/com/modules/groups/getGroup",
				"arguments" : {
					"groupID" : { "value" : arguments.groupID, "type" : "numeric", "default": "", "required" : false, "description" : "" },
					"groupName" : { "value" : arguments.groupName, "type" : "string", "default": "", "required" : false, "description" : "" },
					"groupStatus" : { "value" : arguments.groupStatus, "type" : "string", "default": "Active", "required" : false, "description" : "" }
				}
			};
		/********** END DEFAULT RETURN VALUE **********/

		/********** BEGIN SECURITY CHECK **********/
//			local.thisReturnValue = createObject( "component", "com.system.security" ).check();
//
//			if ( !REFindNoCase( "1\d{3}", local.thisReturnValue.statusCode ) ) {
//				local.returnValue.statusCode = local.thisReturnValue.statusCode;
//				local.returnValue.message = local.thisReturnValue.message;
//			}
		/********** END SECURITY CHECK **********/

		/********** BEGIN CHECK FOR MISSING ARGUMENTS **********/
			/***** BEGIN UPDATE OF STATUS CODE*****/
				if ( !REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					local.returnValue.message = "Some required arguments are missing.";
				}
			/***** END UPDATE OF STATUS CODE *****/
		/********** END CHECK FOR MISSING ARGUMENTS **********/

		/********** BEGIN QUERY **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					/***** BEGIN QUERY INIT **********/
						local.queryService = new query();
						local.queryService.setDatasource( "accounting" );
						local.queryService.setName( "thisQuery" );
						//local.queryService.setCachedWithin( CreateTimeSpan(0, 0, 5, 0) );
						//local.queryService.setMaxRows( 20 );
					/***** END QUERY INIT **********/

					/***** BEGIN QUERY PARAMETERS *****/
						local.queryService.addParam( name="groupID", value=arguments.groupID, cfsqltype="cf_sql_integer" );
						local.queryService.addParam( name="groupName", value=arguments.groupName, cfsqltype="cf_sql_varchar" );
						local.queryService.addParam( name="groupStatus", value=arguments.groupStatus, cfsqltype="cf_sql_varchar" );
					/***** END QUERY PARAMETERS *****/

					/***** BEGIN QUERY STRING *****/
						local.queryService.sqlString = "
							SELECT	G.groupID,
									G.parentID,
									G.externalID,
									G.groupName,
									G.directory,
									G.groupStatus
							FROM groups AS G
							WHERE 1=1
						";

						/* BEGIN ARGUMENTS */
							if ( REFindNoCase( "^\d*$", arguments.groupID ) ) {
								local.queryService.sqlString &= "
									AND G.groupID = :groupID
								";
							}

							if ( trim( arguments.groupName ) != "~" ) {
								local.queryService.sqlString &= "
									AND G.groupName = :groupName
								";
							}

							if ( REFindNoCase( "^(Active|All|Inactive)$", arguments.groupStatus ) ) {
								local.queryService.sqlString &= "
									AND G.groupStatus = :groupStatus
								";
							}
						/* END ARGUMENTS */

						// ADD ORDER BY TO QUERY
						local.queryService.sqlString &= "
							ORDER BY groupName
						";
					/***** END QUERY STRING *****/

					/***** BEGIN QUERY EXECUTE *****/
						local.queryResult = local.queryService.execute( sql=local.queryService.sqlString );
					/***** END QUERY EXECUTE *****/

					/***** BEGIN QUERY RESULTS *****/
						local.queryMetaData = local.queryResult.getPrefix();
						local.thisQuery = local.queryResult.getResult();
					/***** END QUERY RESULTS *****/
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast(local.returnValue.eventName, '/') & "</tt>. The error message is " & e.Message & ".";

					local.returnValue.results[ 1 ] = {
						"rootCause" : ( isDefined( "e.RootCause.Message" ) ) ? e.RootCause.Message : "", 
						"detail" : ( isDefined( "e.detail" ) ) ? e.detail : "", 
						"errorCode" : ( isDefined( "e.errorCode" ) ) ? e.errorCode : "", 
						"tagContext" : ( isDefined( "e.tagContext" ) ) ? e.tagContext : ""
					};
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
					writeLog( file=application.applicationName, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** END QUERY **********/

		/********** BEGIN OUPUT **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					/***** BEGIN QUERY LOOP *****/
						local.thisCountA = 1;
						for ( local.A IN local.thisQuery  ) {
							local.returnValue["results"][ local.thisCountA ] = {
								"groupID" : local.A[ "groupID" ],
								"parentID" : local.A[ "parentID" ],
								"externalID" : local.A[ "externalID" ],
								"groupName" : local.A[ "groupName" ],
								"directory" : local.A[ "directory" ],
								"groupStatus" : local.A[ "groupStatus" ],
								"groupTypes" :[]
							};
							local.thisCountA++;
						}
					/***** END QUERY LOOP *****/

					/***** BEGIN RECORD COUNT UPDATE *****/
						local.returnValue.totalRows = local.queryMetaData.recordCount;
					/***** END RECORD COUNT UPDATE *****/
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast(local.returnValue.eventName, '/') & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.Message" ) ) {
						 local.returnValue.results[ 1 ][ "RootCause" ] = { "message" : e.Message };
					}

					/*
					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}
					*/

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
					//writeLog( file=application.applicationname, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** END OUPUT **********/

		/********** BEGIN JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		/********** END JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		return local.returnValue;
	}
	remote struct function addGroup(
		any parentID="0",
		string externalID="~",
		string groupName="~", 
		string directory="~", 
		string groupStatus="Active"
	)
	 displayname=""
	 description=""
	 hint="one"
	 output="true"
	 returnFormat="JSON"
	{
		/********** BEGIN DEFAULT RETURN VALUE **********/
			local.returnValue = {
				"statusCode" : 1000,
				"requestID" : createUUID(),
				"permissions" : "",
				"message" : "Record Added",
				"totalRows" : 0,
				"results" : {},
				"eventName" : "/com/modules/groups/addGroup",
				"arguments" : {
					"parentID" : { "value" : arguments.parentID, "type" : "numeric", "default": 0, "required" : false, "description" : "" },
					"externalID" : { "value" : arguments.externalID, "type" : "string", "default": "", "required" : false, "description" : "" },
					"groupName" : { "value" : arguments.groupName, "type" : "string", "default": "", "required" : false, "description" : "" },
					"directory" : { "value" : arguments.directory, "type" : "string", "default": "", "required" : false, "description" : "" },
					"groupStatus" : { "value" : arguments.groupStatus, "type" : "string", "default": "Active", "required" : false, "description" : "" }
				}
			};
		/********** END DEFAULT RETURN VALUE **********/

		/********** BEGIN SECURITY CHECK **********/
//			local.thisReturnValue = createObject( "component", "com.system.security" ).check();
//
//			if ( !REFindNoCase( "1\d{3}", local.thisReturnValue.statusCode ) ) {
//				local.returnValue.statusCode = local.thisReturnValue.statusCode;
//				local.returnValue.message = local.thisReturnValue.message;
//			}
		/********** END SECURITY CHECK **********/

		/********** BEGIN CHECK FOR MISSING OR BAD ARGUMENTS **********/
			// GROUP NAME 
			if ( REFindNoCase( "^\S$", arguments.groupName ) ) {
				local.returnValue.statusCode = 5000;
				local.returnValue.arguments.groupName["errorMessage"] = "Is blank or Null";
			}

			// GROUP STATUS 
			if ( !REFindNoCase( "^(Active|All|Inactive)$", arguments.groupStatus ) ) {
				local.returnValue.statusCode = 5000;
				local.returnValue.arguments.groupStatus["errorMessage"] = "Is not one of the acceptable types.";
			}

			/***** BEGIN UPDATE OF STATUS CODE*****/
				if ( !REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					local.returnValue.message = "Some required arguments are missing.";
				}
			/***** END UPDATE OF STATUS CODE *****/
		/********** END CHECK FOR MISSING OR BAD ARGUMENTS **********/

		/********** BEGIN QUERY **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					/***** BEGIN QUERY INIT **********/
						local.queryService = new query();
						local.queryService.setDatasource( "accounting" );
						local.queryService.setName( "thisQuery" );
						//local.queryService.setCachedWithin( CreateTimeSpan(0, 0, 5, 0) );
						//local.queryService.setMaxRows( 20 );
					/***** END QUERY INIT **********/

					/***** BEGIN QUERY PARAMETERS *****/
						local.queryService.addParam( name="parentID", value=arguments.parentID, cfsqltype="cf_sql_integer" );
						local.queryService.addParam( name="externalID", value=arguments.externalID, cfsqltype="cf_sql_varchar" );
						local.queryService.addParam( name="groupName", value=arguments.groupName, cfsqltype="cf_sql_varchar" );
						local.queryService.addParam( name="directory", value=arguments.directory, cfsqltype="cf_sql_varchar" );
						local.queryService.addParam( name="groupStatus", value=arguments.groupStatus, cfsqltype="cf_sql_varchar" );
					/***** END QUERY PARAMETERS *****/

					/***** BEGIN QUERY STRING *****/
						local.queryService.sqlString = " INSERT INTO groups ";
						/* BEGIN ARGUMENTS */
							local.queryService.argumentString = "";

							if ( isDefined( "arguments.parentID" ) && trim( arguments.parentID ) != "~" ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.argumentString &= " parentID ";
							}

							if ( isDefined( "arguments.externalID" ) && trim( arguments.externalID ) != "~" ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.argumentString &= " externalID ";
							}

							if ( isDefined( "arguments.groupName" ) && trim( arguments.groupName ) != "~" ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.argumentString &= " groupName ";
							}

							if ( isDefined( "arguments.directory" ) && trim( arguments.directory ) != "~" ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.argumentString &= " directory ";
							}

							if ( REFindNoCase( "^(Active|All|Inactive)$", arguments.groupStatus ) ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.argumentString &= " groupStatus ";
							}
							
							local.queryService.sqlString &= "(" & local.queryService.argumentString & " )";
						/* END ARGUMENTS */

						/* BEGIN ARGUMENTS */
							local.queryService.argumentString = "";

							if ( isDefined( "arguments.parentID" ) && trim( arguments.parentID ) != "~" ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.argumentString &= " :parentID ";
							}

							if ( isDefined( "arguments.externalID" ) && trim( arguments.externalID ) != "~" ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.argumentString &= " :externalID ";
							}

							if ( isDefined( "arguments.groupName" ) && trim( arguments.groupName ) != "~" ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.argumentString &= " :groupName ";
							}

							if ( isDefined( "arguments.directory" ) && trim( arguments.directory ) != "~" ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.argumentString &= " :directory ";
							}

							if ( REFindNoCase( "^(Active|All|Inactive)$", arguments.groupStatus ) ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.argumentString &= " :groupStatus ";
							}
							
							local.queryService.sqlString &= "VALUES(" & local.queryService.argumentString & " )";
						/* END ARGUMENTS */
					/***** END QUERY STRING *****/

					/***** BEGIN QUERY EXECUTE *****/
						local.queryResult = local.queryService.execute( sql = local.queryService.sqlString );
					/***** END QUERY EXECUTE *****/

					/***** BEGIN QUERY RESULTS *****/
						local.queryMetaData = local.queryResult.getPrefix();
						local.thisQuery = local.queryResult.getResult();
					/***** END QUERY RESULTS *****/
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast( local.returnValue.eventName, '/' ) & "</tt>. The error message is " & e.Message & ".";

					local.returnValue.results[ 1 ] = {
						"rootCause" : ( isDefined( "e.RootCause.Message" ) ) ? e.RootCause.Message : "", 
						"detail" : ( isDefined( "e.detail" ) ) ? e.detail : "", 
						"errorCode" : ( isDefined( "e.errorCode" ) ) ? e.errorCode : "", 
						"tagContext" : ( isDefined( "e.tagContext" ) ) ? e.tagContext : ""
					};
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
//					writeLog( file=application.applicationName, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** END QUERY **********/

		/********** BEGIN OUPUT **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					/***** BEGIN QUERY LOOP *****/
						local.thisCountA = 1;
						for ( local.A IN local.thisQuery  ) {
							local.returnValue["results"][ local.thisCountA ] = {
								"groupID" : local.A[ "groupID" ],
								"parentID" : local.A[ "parentID" ],
								"externalID" : local.A[ "externalID" ],
								"groupName" : local.A[ "groupName" ],
								"directory" : local.A[ "directory" ],
								"groupStatus" : local.A[ "groupStatus" ],
								"groupTypes" :[]
							};
							local.thisCountA++;
						}
					/***** END QUERY LOOP *****/

					/***** BEGIN RECORD COUNT UPDATE *****/
						local.returnValue.totalRows = local.queryMetaData.recordCount;
					/***** END RECORD COUNT UPDATE *****/
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast(local.returnValue.eventName, '/') & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.Message" ) ) {
						 local.returnValue.results[ 1 ][ "RootCause" ] = { "message" : e.Message };
					}

					/*
					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}
					*/

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
					//writeLog( file=application.applicationname, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** END OUPUT **********/

		/********** BEGIN JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		/********** END JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		return local.returnValue;
	}
	remote struct function editGroup(
		numeric groupID,
		any parentID="~",
		string externalID="~",
		string groupName="~", 
		string directory="~", 
		string groupStatus="~"
	)
	 displayname=""
	 description=""
	 hint="one"
	 output="true"
	 returnFormat="JSON"
	{
		/********** BEGIN DEFAULT RETURN VALUE **********/
			local.returnValue = {
				"statusCode" : 1000,
				"requestID" : createUUID(),
				"permissions" : "",
				"message" : "Success",
				"totalRows" : 0,
				"results" : {},
				"eventName" : "/com/modules/groups/editGroup",
				"arguments" : {
					"groupID" : { "value" : arguments.groupID, "type" : "numeric", "default": "", "required" : false, "description" : "" },
					"parentID" : { "value" : arguments.parentID, "type" : "numeric", "default": "", "required" : false, "description" : "" },
					"externalID" : { "value" : arguments.externalID, "type" : "string", "default": "", "required" : false, "description" : "" },
					"groupName" : { "value" : arguments.groupName, "type" : "string", "default": "", "required" : false, "description" : "" },
					"directory" : { "value" : arguments.directory, "type" : "string", "default": "", "required" : false, "description" : "" },
					"groupStatus" : { "value" : arguments.groupStatus, "type" : "string", "default": "Active", "required" : false, "description" : "" }
				}
			};
		/********** END DEFAULT RETURN VALUE **********/

		/********** BEGIN SECURITY CHECK **********/
//			local.thisReturnValue = createObject( "component", "com.system.security" ).check();
//
//			if ( !REFindNoCase( "1\d{3}", local.thisReturnValue.statusCode ) ) {
//				local.returnValue.statusCode = local.thisReturnValue.statusCode;
//				local.returnValue.message = local.thisReturnValue.message;
//			}
		/********** END SECURITY CHECK **********/

		/********** BEGIN CHECK FOR MISSING ARGUMENTS **********/
			/***** BEGIN UPDATE OF STATUS CODE*****/
				if ( !REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					local.returnValue.message = "Some required arguments are missing.";
				}
			/***** END UPDATE OF STATUS CODE *****/
		/********** END CHECK FOR MISSING ARGUMENTS **********/

		/********** BEGIN QUERY **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					/***** BEGIN QUERY INIT **********/
						local.queryService = new query();
						local.queryService.setDatasource( "accounting" );
						local.queryService.setName( "thisQuery" );
						//local.queryService.setCachedWithin( CreateTimeSpan(0, 0, 5, 0) );
						//local.queryService.setMaxRows( 20 );
					/***** END QUERY INIT **********/

					/***** BEGIN QUERY PARAMETERS *****/
						local.queryService.addParam( name="groupID", value=arguments.groupID, cfsqltype="cf_sql_integer" );
						local.queryService.addParam( name="parentID", value=arguments.parentID, cfsqltype="cf_sql_integer" );
						local.queryService.addParam( name="externalID", value=arguments.externalID, cfsqltype="cf_sql_varchar" );
						local.queryService.addParam( name="groupName", value=arguments.groupName, cfsqltype="cf_sql_varchar" );
						local.queryService.addParam( name="directory", value=arguments.directory, cfsqltype="cf_sql_varchar" );
						local.queryService.addParam( name="groupStatus", value=arguments.groupStatus, cfsqltype="cf_sql_varchar" );
					/***** END QUERY PARAMETERS *****/

					/***** BEGIN QUERY STRING *****/
						local.queryService.sqlString = "
							UPDATE 	groups
							SET	
						";

						/* BEGIN ARGUMENTS */
							
							local.queryService.argumentString = "";

							if ( isDefined( "arguments.parentID" ) && trim( arguments.parentID ) != "~" ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.argumentString &= "
									parentID = :parentID
								";
							}


							if ( isDefined( "arguments.parentID" ) && trim( arguments.parentID ) != "~" ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.argumentString &= "
									parentID = :parentID
								";
							}

							if ( isDefined( "arguments.externalID" ) && trim( arguments.externalID ) != "~" ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.argumentString &= "
									externalID = :externalID
								";
							}

							if ( isDefined( "arguments.directory" ) && trim( arguments.directory ) != "~" ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.argumentString &= "
									directory = :directory
								";
							}

							if ( REFindNoCase( "^(Active|All|Inactive)$", arguments.groupStatus ) ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.sqlString &= "
									groupStatus = :groupStatus
								";
							}
							
							local.queryService.sqlString &= local.queryService.argumentString;
						/* END ARGUMENTS */

						/* BEGIN FROM / WHERE CLAUSE */
							local.queryService.sqlString &= "
								WHERE groupID = :groupID
							";
						/* BEGIN FROM / WHERE CLAUSE */
					/***** END QUERY STRING *****/

					/***** BEGIN QUERY EXECUTE *****/
						local.queryResult = local.queryService.execute( sql=local.queryService.sqlString );
					/***** END QUERY EXECUTE *****/

					/***** BEGIN QUERY RESULTS *****/
						local.queryMetaData = local.queryResult.getPrefix();
						local.thisQuery = local.queryResult.getResult();
					/***** END QUERY RESULTS *****/
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast( local.returnValue.eventName, '/' ) & "</tt>. The error message is " & e.Message & ".";

					local.returnValue.results[ 1 ] = {
						"rootCause" : ( isDefined( "e.RootCause.Message" ) ) ? e.RootCause.Message : "", 
						"detail" : ( isDefined( "e.detail" ) ) ? e.detail : "", 
						"errorCode" : ( isDefined( "e.errorCode" ) ) ? e.errorCode : "", 
						"tagContext" : ( isDefined( "e.tagContext" ) ) ? e.tagContext : ""
					};
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
//					writeLog( file=application.applicationName, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** END QUERY **********/

		/********** BEGIN OUPUT **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					/***** BEGIN QUERY LOOP *****/
						local.thisCountA = 1;
						for ( local.A IN local.thisQuery  ) {
							local.returnValue["results"][ local.thisCountA ] = {
								"groupID" : local.A[ "groupID" ],
								"parentID" : local.A[ "parentID" ],
								"externalID" : local.A[ "externalID" ],
								"groupName" : local.A[ "groupName" ],
								"directory" : local.A[ "directory" ],
								"groupStatus" : local.A[ "groupStatus" ],
								"groupTypes" :[]
							};
							local.thisCountA++;
						}
					/***** END QUERY LOOP *****/

					/***** BEGIN RECORD COUNT UPDATE *****/
						local.returnValue.totalRows = local.queryMetaData.recordCount;
					/***** END RECORD COUNT UPDATE *****/
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast(local.returnValue.eventName, '/') & "</tt>. The error message is " & e.Message & ".";

					if ( isDefined( "e.Message" ) ) {
						 local.returnValue.results[ 1 ][ "RootCause" ] = { "message" : e.Message };
					}

					/*
					if ( isDefined( "e.RootCause.Message" ) ) {
						 local.returnValue.results[ 1 ][ "RootCause" ] = { "message" : e.RootCause.Message };
					}
					*/

					if ( isDefined( "e.TagContext" ) ) {
						local.returnValue.results[ 1 ][ "tagContext" ] = e.TagContext;
					}
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
					//writeLog( file=application.applicationname, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** END OUPUT **********/

		/********** BEGIN JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		/********** END JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		return local.returnValue;
	}
	remote struct function addGroupTypeSelected(
		any groupID="~",
		any groupTypeID="~",
		string groupTypeSelectedStatus="Active"
	)
	 displayname=""
	 description=""
	 hint="one"
	 output="true"
	 returnFormat="JSON"
	{
		/********** BEGIN DEFAULT RETURN VALUE **********/
			local.returnValue = {
				"statusCode" : 1000,
				"requestID" : createUUID(),
				"permissions" : "",
				"message" : "Record Added",
				"totalRows" : 0,
				"results" : {},
				"eventName" : "/com/modules/groups/addGroupTypeSelected",
				"arguments" : {
					"groupID" : { "value" : arguments.groupID, "type" : "numeric", "default": 0, "required" : false, "description" : "" },
					"groupTypeID" : { "value" : arguments.groupTypeID, "type" : "string", "default": "", "required" : false, "description" : "" },
					"groupTypeSelectedStatus" : { "value" : arguments.groupTypeSelectedStatus, "type" : "string", "default": "Active", "required" : false, "description" : "" }
				}
			};
		/********** END DEFAULT RETURN VALUE **********/

		/********** BEGIN SECURITY CHECK **********/
//			local.thisReturnValue = createObject( "component", "com.system.security" ).check();
//
//			if ( !REFindNoCase( "1\d{3}", local.thisReturnValue.statusCode ) ) {
//				local.returnValue.statusCode = local.thisReturnValue.statusCode;
//				local.returnValue.message = local.thisReturnValue.message;
//			}
		/********** END SECURITY CHECK **********/

		/********** BEGIN CHECK FOR MISSING ARGUMENTS **********/
			// GROUP ID
			if ( arguments.groupID != "~" ) {
				local.returnValue.statusCode = 5000;
				local.returnValue.arguments.groupID["errorMessage"] = "Is blank or Null";
			}

			// GROUP TYPE ID
			if ( arguments.groupTypeID != "~" ) {
				local.returnValue.statusCode = 5000;
				local.returnValue.arguments.groupTypeID["errorMessage"] = "Is blank or Null";
			}
			
			// GROUP TYPE SELECTED STATUS 
			if ( REFindNoCase( "^(Active|All|Inactive)$", arguments.groupTypeSelectedStatus ) ) {
				local.returnValue.statusCode = 5000;
				local.returnValue.arguments.groupTypeSelectedStatus["errorMessage"] = "Is not one of the approved values.";
			}

			/***** BEGIN UPDATE OF STATUS CODE*****/
				if ( !REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					local.returnValue.message = "Some required arguments are missing.";
				}
			/***** END UPDATE OF STATUS CODE *****/
		/********** END CHECK FOR MISSING ARGUMENTS **********/

		/********** BEGIN QUERY **********/
			try {
				if ( REFindNoCase( "1\d{3}", local.returnValue.statusCode ) ) {
					/***** BEGIN QUERY INIT **********/
						local.queryService = new query();
						local.queryService.setDatasource( "accounting" );
						local.queryService.setName( "thisQuery" );
						//local.queryService.setCachedWithin( CreateTimeSpan(0, 0, 5, 0) );
						//local.queryService.setMaxRows( 20 );
					/***** END QUERY INIT **********/

					/***** BEGIN QUERY PARAMETERS *****/
						local.queryService.addParam( name="groupID", value=arguments.groupID, cfsqltype="cf_sql_integer" );
						local.queryService.addParam( name="groupTypeID", value=arguments.groupTypeID, cfsqltype="cf_sql_integer" );
						local.queryService.addParam( name="groupTypeSelectedStatus", value=arguments.groupTypeSelectedStatus, cfsqltype="cf_sql_varchar" );
					/***** END QUERY PARAMETERS *****/

					/***** BEGIN QUERY STRING *****/
						local.queryService.sqlString = "
							INSERT INTO logins (
								groupID,
								groupTypeID, 
								groupTypeSelectedStatus
							)
						";
							
						/* BEGIN ARGUMENTS */
							local.queryService.argumentString = "";

							if ( isDefined( "arguments.groupID" ) && trim( arguments.groupID ) != "~" ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.argumentString &= "
									groupID = :groupID
								";
							}

							if ( isDefined( "arguments.groupTypeID" ) && trim( arguments.groupTypeID ) != "~" ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.argumentString &= "
									groupTypeID = :groupTypeID
								";
							}

							if ( REFindNoCase( "^(Active|All|Inactive)$", arguments.groupTypeSelectedStatus ) ) {
								if ( local.queryService.argumentString != "" ) { local.queryService.argumentString &= ", "; }
								local.queryService.sqlString &= "
									groupTypeSelectedStatus = :groupTypeSelectedStatus
								";
							}

							local.queryService.sqlString &= "VALUES(" & local.queryService.argumentString & " )";
						/* END ARGUMENTS */
					/***** END QUERY STRING *****/

					/***** BEGIN QUERY EXECUTE *****/
						local.queryResult = local.queryService.execute( sql=local.queryService.sqlString );
					/***** END QUERY EXECUTE *****/

					/***** BEGIN QUERY RESULTS *****/
						local.queryMetaData = local.queryResult.getPrefix();
						local.thisQuery = local.queryResult.getResult();
					/***** END QUERY RESULTS *****/
				}
			}
			catch ( any e ) {
				/***** END BEGIN ERROR MESSAGE *****/
					local.returnValue.statusCode = 5000;
					local.returnValue.message = "An error occurred while running the method <tt>" & ListLast( local.returnValue.eventName, '/' ) & "</tt>. The error message is " & e.Message & ".";

					local.returnValue.results[ 1 ] = {
						"rootCause" : ( isDefined( "e.RootCause.Message" ) ) ? e.RootCause.Message : "", 
						"detail" : ( isDefined( "e.detail" ) ) ? e.detail : "", 
						"errorCode" : ( isDefined( "e.errorCode" ) ) ? e.errorCode : "", 
						"tagContext" : ( isDefined( "e.tagContext" ) ) ? e.tagContext : ""
					};
				/***** END BEGIN ERROR MESSAGE *****/

				/***** BEGIN LOG UPDATE *****/
//					writeLog( file=application.applicationName, type="Error", text=local.returnValue.message );
				/***** END LOG UPDATE *****/
			}
		/********** END QUERY **********/

		/********** BEGIN JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		/********** END JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		return local.returnValue;
	}
}