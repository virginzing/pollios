var Login = function () {

	var handleLogin = function() {
		$('.login-form').validate({
	            errorElement: 'span', //default input error message container
	            errorClass: 'help-block', // default input error message class
	            focusInvalid: false, // do not focus the last invalid input
	            rules: {
	                authen: {
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
	                authen: {
	                    required: "Email is required."
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
            escapeMarkup: function (m) {
                return m;
            }
        });


				$('#select2_sample4').change(function () {
        	$('.signup').validate().element($(this));
        });

        $('.signup').validate({
	            errorElement: 'span', //default input error message container
	            errorClass: 'help-block', // default input error message class
	            focusInvalid: false, // do not focus the last invalid input
	            ignore: "",
	            rules: {
	                "fullname": {
	                    required: true
	                },
	                "username": {
	                	required: true,
	                	"remote": {
	                    	url: '/check_valid_username',
	                    	dataType: 'json',
	                    	type: "post",
	                    	data: {
	                    		email: function() {
	                    			return $('.signup :input[name="username"]').val();
	                    		}
	                    	}
	                    }
	                },
	                "member_type": {
	                	required: true
	                },
	               	"email": {
	                    required: true,
	                    email: true,
	                    "remote": {
	                    	url: '/check_valid_email',
	                    	dataType: 'json',
	                    	type: "post",
	                    	data: {
	                    		email: function() {
	                    			return $('.signup :input[name="email"]').val();
	                    		}
	                    	}
	                    }
	                },
	                "password": {
	                    required: true,
	                    minlength: 6
	                },
	                "password_confirmation": {
	                    equalTo: "#register_password"
	                },

	                tnc_pollios: {
	                    required: true
	                }
	            },

	            messages: { // custom messages for radio buttons and checkboxes
	                tnc_pollios: {
	                    required: "Please accept TNC first."
	                },
	                email: {
	                	required: "Please enter your email address.",
	                	email: "Please enter a valid email address.",
	                	remote: jQuery.validator.format("This email is already taken.")
	                },
	                username: {
	                	required: "Please enter your username.",
	                	remote: jQuery.validator.format("This username is already taken.")
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
	                if (element.attr("name") == "tnc_pollios") { // insert checkbox errors after the container                  
	                    error.insertAfter($('#register_tnc_pollios_error'));
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
					

					$('.signup input').keypress(function (e) {
	            if (e.which == 13) {
	                if ($('.signup').validate().form()) {
	                    $('.signup').submit();
	                }
	                return false;
	            }
	        });
	}
    
    return {
        //main function to initiate the module
        init: function () {
        		handleRegister();   
            handleLogin();
            handleForgetPassword();
  	       
        }

    };

}();