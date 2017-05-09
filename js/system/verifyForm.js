/*******************************\
Created by Fredrick E. Lewis II
\*******************************/

function verifyForm(json) {
	var errorCount = 0;
	var text = '';
	var badText = '';

	// reset field highlights
	jQuery('input, textarea').each(
		function(intIndex) {
			jQuery(this).css('background-color','white');
		}
	);

	jQuery('#' + json.id + ' input[type=text],#' + json.id + ' textarea').each(
		function(intIndex) {
			var tString = fileNameCheck(jQuery(this).val());
			if (tString != null && tString.length >= 1) {
				/***** START LABEL *****/
					var labelValue = (jQuery(this).parent().find('label').length != 0) ? jQuery(this).parent().find('label').html() : jQuery(this).parent().parent().find('label').html();
					labelValue = labelValue.replace(/<(input|img)[^>]*>/g, '');
					labelValue = labelValue.replace(/:|\t|\f|\r|\n/g, '');
				/***** START LABEL *****/

				badText += labelValue + ': ' + tString + '<br />';
				badField(this);
			}
		}
	);

	if (badText.length != 0) {
		dialogFieldError('The following fields contain foreign characters that need to be replaced: <ul>' + badText + '<ul>');
	}
	else {
		jQuery('[check]').each(
			function(intIndex) {
				// reset 
				jQuery(this).css('background-color', '');
				//STRINGS
				if (jQuery(this).attr('check') == 'string') {
					if (!/\S+/i.test(jQuery(this).val())) {
						text += "" + jQuery(this).attr('message') + "<br />";
						errorCount++;
						badField(this);
					}
				}
				// NUMERIC 
				else if (jQuery(this).attr('check') == 'numeric') {
					var d = new RegExp("^[0-9]+\.?[0-9]?");
					if (!d.test(jQuery(this).val())) {
						text += "" + jQuery(this).attr('message') + "<br />";
						errorCount++;
						badField(jQuery(this));
					}
				}
				// DATE
				else if (jQuery(this).attr('check') == 'date') {
					var d = new RegExp("^[0-1][0-9]+\\/[0-3][0-9]+\\/[2][0][0-9]{2}$");
					if (!d.test(jQuery(this).val())) {
						text += "" + jQuery(this).attr('message') + "<br />";
						errorCount++;
						badField(jQuery(this));
					}
				}
				// URL
				else if (jQuery(this).attr('check') == 'url') {
					var d = new RegExp();
					d.compile("^(http|https)://[A-Za-z0-9-_]+\\.[A-Za-z0-9-_%&~\?\/.=]+$");
					if (!d.test(jQuery(this).val())) {
						text += "" + jQuery(this).attr('message') + "<br />";
						errorCount++;
						badField(jQuery(this));
					}
				}
				// EMAIL
				else if (jQuery(this).attr('check') == 'email') {
					var e = new RegExp("^.+\\@(\\[?)[a-zA-Z0-9\\-\\.]+\\.([a-zA-Z]{2,3}|[0-9]{1,3})(\\]?)$");
					if (!e.test(jQuery(this).val())) {
						text += "" + jQuery(this).attr('message') + "<br />";
						errorCount++;
						badField(jQuery(this));
					}
				}
				// CHECKBOX
				else if (jQuery(this).attr('check') == 'checkbox') {
					var blank_val = 0;
					for (var j=0; j<field_name[i].length; j++) {
						if (field_name[i][j].checked) {
							var blank_val = 1;
							break;
						}
					}
					if (!blank_val) {
						text += "\t" + jQuery(this).attr('message') + "<br />";
						errorCount++;
					}
				}
				// NOT ZERO
				else if (jQuery(this).attr('check') == 'not_zero') {
					if (eval(jQuery(this).val() == 0)) {
						text += "\t" + jQuery(this).attr('message') + "<br />";
						errorCount++;
						badField(jQuery(this));
					}
				}
				// PHONE
				else if (jQuery(this).attr('check') == 'phone') {
					//var e = new RegExp("^\d{3}[\\-\\.]{0,1}\d{3}[\\-\\.]{0,1}\d{4}$");
					var e = new RegExp("^[1]{0,1}[\\-\\.]{0,1}[0-9]{3}[\\-\\.]{1}[0-9]{3}[\\-\\.]{1}[0-9]{4}$");
					
					if (!e.test(jQuery(this).val())) {
						text += "\t" + jQuery(this).attr('message') + "<br />";
						errorCount++;
						badField(jQuery(this));
					}
				}
			}
		);

		/*
		//START EMAIL VERIFY
		if (
			errorCount == 0 && 
			( 
				jQuery('input[name=Email_Verify]').length != 0 && (
					jQuery('input[name=Email_Verify]').val() != '' || jQuery('input[name=Email]').val() != ''
				)
			)
		) {
			if (jQuery('input[name=Email]').val() != jQuery('input[name=Email_Verify]').val()) {
				errorCount++;
				text = 'Email addresses do not match. Please try again.';
			}

			if (errorCount != 0) {
				jQuery('input[name=Email]').css('background-color', '#FFF0F0');
				jQuery('input[name=Email_Verify]').css('background-color', '#FFF0F0');
			}
		}
	
		//START PASSWORD VERIFY
		if ( errorCount == 0 ) {
			if (jQuery('input[name=Password_Verify]').length != 0) {
				if (!/\S+/i.test(jQuery('input[name=Password]').val())) {
					errorCount++;
					text += 'The Password field is blank. Please select a password of 5 characters or more in length';
				}
				else if (!/\S+/i.test(jQuery('input[name=Password_Verify]').val())) {
					errorCount++;
					text += 'The Password Verify field is blank. Please select a password of 5 characters or more in length';
				}

				if (jQuery('input[name=Password]').val() != jQuery('input[name=Password_Verify]').val()) {
					errorCount++;
					text = 'Passwords do not match. Please try again.';
				}
			}

			if (errorCount != 0) {
				jQuery('input[name=Password]').css('background-color', '#FFF0F0');
				jQuery('input[name=Password_Verify]').css('background-color', '#FFF0F0');
			}
		}
		*/

		// CHECK APPROVAL
		/*
		if (errorCount == 0) {
			if (!jQuery('input[name=Terms_Approval]:checked').val()) {
				jQuery('.FORM_TERMS LABEL').css('background-color', '#FFF0F0');
				text += "You must approve the terms and conditions to proceed.";
	
				errorCount++;
			}
		}
		*/

		/***** START ERROR DIALOG OR CALLBACK FUNCTION *****/
			if (errorCount > 0) {
				// display error message 
				displayErrors( { "id" : "#formErrorsDialog", "align" : "left", "valign" : "top", "message" : "The following fields need to be adjusted:<ul>" + text + "</ul>" } );
			}
			else { 
				if (badText.length == 0) {
					// process call back function
					eval(json.callBack);
				}
			}
		/***** END ERROR DIALOG OR CALLBACK FUNCTION *****/
	}
}

function emailVerify(errorCount) {
	return errorCount;
}

function passwordVerify(errorCount) {
	return errorCount;
}

function badField(f) {
	jQuery(f).css('background-color', '#F8EDA4');
}

function fileNameCheck(s) {
	var pattern = /[^a-zA-Z 0-9\_\.\~\`\!\@\#\$\%\^\&\*\(\)\-\+\=\{\}\[\]\:\;\|\"\'\<\>\,\.\?\/\\\s]+/g;
	var result = pattern.exec(s);

	return s.match(pattern);
}

function blankFieldCheck(f) {
	var pattern = /\S+/i;
	return !pattern.test(f);
}

function dialogFieldError(m) {
	jQuery('#errors').html(m);
	jQuery('#errors').dialog({
		modal: true,
		title: "Error", 
		width: 500,
		height: 300, 
		buttons: {
			Ok: function() {
				jQuery( this ).dialog( "close" );
			}
		}
	});
}
