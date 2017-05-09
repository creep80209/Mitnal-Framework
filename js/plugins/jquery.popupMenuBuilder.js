/************************************************************************/
/* created by Gene Lewis                                                */
/*            13alone Prodcutions, L.L.C.                               */
/*            gene@13alone.com                                          */
/************************************************************************/

// polyfill
if ( typeof Object.create !== 'function' ) { Object.create = function (obj)  { function F() { } ; F.prototype = obj; return new F(); } }
(
	function ( $, window, document, undefined ) {
		/********** BEGIN LOCAL METHOD CALLS **********/
		var Menu = {
			init : function (options, thisElement ) {
				var self = this;

				self.thisElement = thisElement;
				self.$thisElement = $( thisElement );

				/***** BEGIN OPTION ITEM "search" *****/
					// string or not string
					self.search = ( typeof options === 'string' ) ? options : options.search;
					self.options = $.extend( {}, $.fn.popupMenu.options, options );
				/***** END OPTION ITEM "search" *****/

				/***** BEGIN OPTION ITEM "onComplete" *****/
					if( typeof self.options.onComplete === 'function' ) { self.options.onComplete.apply( self.thisElement, arguments); }
				/***** END OPTION ITEM "onComplete" *****/
			}
		};
		/********** END LOCAL METHOD CALLS **********/

		/********** BEGIN THIS PLUGIN CALL **********/
			$.fn.popupMenu = function( options ) {
				/***** BEGIN MENU ITEMS BUILDER *****/
					// create the menu content
					$("body").append( $.fn.menuContainer( options ) );

					for (var i=0; i < options.menuItems.length; i++) {
						if (options.menuItems[i].click !== "undefined") { 
							$("#" + options.menuName + " [ref=" + options.menuItems[i].ref + "]").on( { "click" : options.menuItems[i].click } ); }
					}

					// invoke the menu and hide it
					$('#' + options.menuName).menu().hide();

					// hide all itemMenu class items if user move off of one
					$(".itemMenu").on( { "mouseleave": function () { jQuery(this).hide(); } } );
				/***** END MENU ITEMS BUILDER *****/

				// auto return for each container
				return this
					.each(
						function () {
							var thisMenu = Object.create( Menu );
							thisMenu.init( options, this);
						}
					)
					.on(
						/***** BEGIN MAIN ELEMENT EVENT HANDLERS *****/
							{
								"click" : function ( thisEvent ) {
									$('#' + options.menuName).css( { "display" : "inline-block", "z-index" : 10000 } ).position( { my: "left top", at: "bottom", of: thisEvent, offset: "-5, -5" } );

									/***** BEGIN LOOP TO CAPTURE ALL THE ATTRIBUTES AND WRITE THEM TO THE MENU CONTAINER *****/
										$(this).each( function() { $.each( this.attributes, function() { if(this.specified) { if (this.name != 'style' && this.name != 'class') { $('#' + options.menuName).attr(this.name, this.value); } } } ); } );
									/***** END LOOP TO CAPTURE ALL THE ATTRIBUTES AND WRITE THEM TO THE MENU CONTAINER *****/
								}
							}
						/***** BEGIN MAIN ELEMENT EVENT HANDLERS *****/
					)
				;
			};

			$.fn.menuContainer = function( options ) {
				/***** BEGIN DEFAULT VALUES *****/
					var t = '';
				/***** END DEFAULT VALUES *****/

				/***** BEGIN AJAX *****/
					var thisID = (typeof(options.menuName) != "undefined") ? ' id="' + options.menuName.replace(/#/g, "") + '"': '';
					t += '<ul' + thisID + ' class="itemMenu" role="listbox" style="display: inline-block;">';
						for (var i=0; i < options.menuItems.length; i++) {
							// IS THIS MENU OPTION DISPLAYABLE
							if (typeof(options.menuItems[i].enable) == "undefined") { options.menuItems[i].enable = true; }
							var isDisabled = (options.menuItems[i].enable) ? '' : ' ui-state-disabled';

							// IS THERE AN ICON TO USE
							if (typeof(options.menuItems[i].icon) != "undefined" && options.menuItems[i].icon.length > 5 ) { t += '<img src="' + options.menuItems[i].icon + '" alt="" width="14" height="14" border="0">'; }
							var uiIcon = (typeof(options.menuItems[i].uiIcon) != "undefined") ? "ui-icon ui-icon-" + options.menuItems[i].uiIcon : "";

							t += '<li ref="' + options.menuItems[i].ref + '" class="' + isDisabled + '"><a href="#" style="position: relative; padding-left: 20px;"><span class="' + uiIcon + '" style="position: absolute; top: 2px; left: 2px"></span>' + options.menuItems[i].text + '</a>';
								if (typeof(options.menuItems[i].sub) != "undefined") { t += $.fn.menuContainer(options.menuItems[i].sub); }
							t += '</li>';
						}
					t += '</ul>';
				/***** END AJAX *****/

				return t;
			};
		/********** END THIS PLUGIN CALL **********/

		/********** BEGIN THIS PLUGINS OPTIONS **********/
			$.fn.popupMenu.options = { container : "menuXYZ", enable : null, icon : null, menuItems : [], sub: [], click: null, onComplete : null };
		/********** END THIS PLUGINS OPTIONS **********/
	}
)(jQuery, window, document);