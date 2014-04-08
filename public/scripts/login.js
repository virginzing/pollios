var Login = function () {

	var handleLogin = function() {
		jQuery('.register-form-couple').hide();
		jQuery('.register-form-vendor').hide();
		$('.login-form').validate({
	            errorElement: 'span', //default input error message container
	            errorClass: 'help-block', // default input error message class
	            focusInvalid: false, // do not focus the last invalid input
	            rules: {
	                email: {
	                    required: true
	                },
	                password: {
	                    required: true
	                },
	                remember: {
	                    required: false
	                }
	            },

	            messages: {
	                email: {
	                    required: "Username is required."
	                },
	                password: {
	                    required: "Password is required."
	                }
	            },

	            invalidHandler: function (event, validator) { //display error alert on form submit   
	                $('.alert-error', $('.login-form')).show();
	            },

	            highlight: function (element) { // hightlight error inputs
	                $(element)
	                    .closest('.form-group').addClass('has-error'); // set error class to the control group
	            },

	            success: function (label) {
	                label.closest('.form-group').removeClass('has-error');
	                label.remove();
	            },

	            errorPlacement: function (error, element) {
	                error.insertAfter(element.closest('.input-icon'));
	            },

	            submitHandler: function (form) {
	                form.submit();
	            }
	        });

	        $('.login-form input').keypress(function (e) {
	            if (e.which == 13) {
	                if ($('.login-form').validate().form()) {
	                    $('.login-form').submit();
	                }
	                return false;
	            }
	        });

	}

	var handleForgetPassword = function () {
		$('.forget-form').validate({
	            errorElement: 'span', //default input error message container
	            errorClass: 'help-block', // default input error message class
	            focusInvalid: false, // do not focus the last invalid input
	            ignore: "",
	            rules: {
	                email: {
	                    required: true,
	                    email: true
	                }
	            },

	            messages: {
	                email: {
	                    required: "Email is required."
	                }
	            },

	            invalidHandler: function (event, validator) { //display error alert on form submit   

	            },

	            highlight: function (element) { // hightlight error inputs
	                $(element)
	                    .closest('.form-group').addClass('has-error'); // set error class to the control group
	            },

	            success: function (label) {
	                label.closest('.form-group').removeClass('has-error');
	                label.remove();
	            },

	            errorPlacement: function (error, element) {
	                error.insertAfter(element.closest('.input-icon'));
	            },

	            submitHandler: function (form) {
	                form.submit();
	            }
	        });

	        $('.forget-form input').keypress(function (e) {
	            if (e.which == 13) {
	                if ($('.forget-form').validate().form()) {
	                    $('.forget-form').submit();
	                }
	                return false;
	            }
	        });

	        jQuery('#forget-password').click(function () {
	            jQuery('.login-form').hide();
	            jQuery('.forget-form').show();
	        });

	        jQuery('#back-btn').click(function () {
	            jQuery('.login-form').show();
	            jQuery('.forget-form').hide();
	        });

	}

	var handleRegister = function () {

		function format(state) {
            if (!state.id) return state.text; // optgroup
            return "<img class='flag' src='assets/img/flags/" + state.id.toLowerCase() + ".png'/>&nbsp;&nbsp;" + state.text;
        }


		$("#select2_sample4").select2({
		  	placeholder: '<i class="icon-map-marker"></i>&nbsp;Select a Country',
            allowClear: true,
            formatResult: format,
            formatSelection: format,
            escapeMarkup: function (m) {
                return m;
            }
        });


			$('#select2_sample4').change(function () {
                $('.register-form-couple').validate().element($(this));
                $('.register-form-vendor').validate().element($(this)); //revalidate the chosen dropdown value and show error or success message for the input
            });



         $('.register-form-couple').validate({
	            errorElement: 'span', //default input error message container
	            errorClass: 'help-block', // default input error message class
	            focusInvalid: false, // do not focus the last invalid input
	            ignore: "",
	            rules: {
	                "couple_profile[name]": {
	                    required: true
	                },
	               	"couple_profile[wedding_date]": {
	                    required: true
	                },
	                "couple_profile[address]": {
	                    required: true
	                },
	                "couple_profile[avatar]": {
	                    required: true
	                },
	               	"couple_profile[user_attributes][email]": {
	                    required: true,
	                    email: true
	                },
	                "couple_profile[user_attributes][password]": {
	                    required: true,
	                    minlength: 6
	                },
	                "couple_profile[user_attributes][password_confirmation]": {
	                    equalTo: "#register_password_couple"
	                },

	                tnc_couple: {
	                    required: true
	                }
	            },

	            messages: { // custom messages for radio buttons and checkboxes
	                tnc_couple: {
	                    required: "Please accept TNC first."
	                }
	            },

	            invalidHandler: function (event, validator) { //display error alert on form submit   

	            },

	            highlight: function (element) { // hightlight error inputs
	                $(element)
	                    .closest('.form-group').addClass('has-error'); // set error class to the control group
	            },

	            success: function (label) {
	                label.closest('.form-group').removeClass('has-error');
	                label.remove();
	            },

	            errorPlacement: function (error, element) {
	                if (element.attr("name") == "tnc_couple") { // insert checkbox errors after the container                  
	                    error.insertAfter($('#register_tnc_couple_error'));
	                } else if (element.closest('.input-icon').size() === 1) {
	                    error.insertAfter(element.closest('.input-icon'));
	                } else {
	                	error.insertAfter(element);
	                }
	            },

	            submitHandler: function (form) {
	                form.submit();
	            }
	        });
					
				 $('.register-form-vendor').validate({
	            errorElement: 'span', //default input error message container
	            errorClass: 'help-block', // default input error message class
	            focusInvalid: false, // do not focus the last invalid input
	            ignore: "",
	            rules: {
	                "vendor_profile[name]": {
	                    required: true
	                },
	                "vendor_profile[telephone]": {
	                    required: true
	                },
	                "vendor_profile[address]": {
	                    required: true
	                },
	                "vendor_profile[logo]": {
	                    required: true
	                },
	               	"vendor_profile[user_attributes][email]": {
	                    required: true,
	                    email: true
	                },
	                "vendor_profile[user_attributes][password]": {
	                    required: true,
	                    minlength: 6
	                },
	                "vendor_profile[user_attributes][password_confirmation]": {
	                    equalTo: "#register_password_vendor"
	                },
	                tnc_vendor: {
	                    required: true
	                }
	            },

	            messages: { // custom messages for radio buttons and checkboxes
	                tnc_vendor: {
	                    required: "Please accept TNC first."
	                }
	            },

	            invalidHandler: function (event, validator) { //display error alert on form submit   

	            },

	            highlight: function (element) { // hightlight error inputs
	                $(element)
	                    .closest('.form-group').addClass('has-error'); // set error class to the control group
	            },

	            success: function (label) {
	                label.closest('.form-group').removeClass('has-error');
	                label.remove();
	            },

	            errorPlacement: function (error, element) {
	                if (element.attr("name") == "tnc_vendor") { // insert checkbox errors after the container                  
	                    error.insertAfter($('#register_tnc_vendor_error'));
	                } else if (element.closest('.input-icon').size() === 1) {
	                    error.insertAfter(element.closest('.input-icon'));
	                } else {
	                	error.insertAfter(element);
	                }
	            },

	            submitHandler: function (form) {
	                form.submit();
	            }
	        });

			$('.register-form-couple input').keypress(function (e) {
	            if (e.which == 13) {
	                if ($('.register-form-couple').validate().form()) {
	                    $('.register-form-couple').submit();
	                }
	                return false;
	            }
	        });

	        jQuery('#register-btn-couple').click(function () {
	            jQuery('.login-form').hide();
	            jQuery('.register-form-couple').show();
	        });

	        jQuery('#register-back-btn-couple').click(function () {
	            jQuery('.login-form').show();
	            jQuery('.register-form-couple').hide();
	        });

	    $('.register-form-vendor input').keypress(function (e) {
	            if (e.which == 13) {
	                if ($('.register-form-vendor').validate().form()) {
	                    $('.register-form-vendor').submit();
	                }
	                return false;
	            }
	        });

	        jQuery('#register-btn-vendor').click(function () {
	            jQuery('.login-form').hide();
	            jQuery('.register-form-vendor').show();
	        });

	        jQuery('#register-back-btn-vendor').click(function () {
	            jQuery('.login-form').show();
	            jQuery('.register-form-vendor').hide();
	        });
	}
    
    return {
        //main function to initiate the module
        init: function () {
        	
            handleLogin();
            handleForgetPassword();
            handleRegister();        
	       
        }

    };

}();