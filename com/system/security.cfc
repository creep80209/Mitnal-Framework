component displayname="security" hint="" output="true"
{
	remote struct function check(

	)
	 displayname="General check on access"
	 description="General check on access"
	 hint="one"
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
				"eventName" : "/com/system/security/check",
				"arguments" : [

				]
			};
		/********** END DEFAULT RETURN VALUE **********/

		/********** BEGIN JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		/********** END JSON CLEAN UP OF ARGUMENTS TO RELAY BACK THE USER **********/

		return local.returnValue;
	}
}