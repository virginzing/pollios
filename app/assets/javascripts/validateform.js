$(document).ready(function(){
    	var validator = $("#build_poll").validate({
            success: function(label) {
            label.addClass("valid").text("Ok!")},
            // focusCleanup: true,
    		rules: {
    			"poll[title]": {required: true, minlength: 2},
                "poll[expire_date]": { required: true },
                "poll[choice_one]": { required: true },
                "poll[choice_two]": { required: true }
    		},
    		messages: {
    			"poll[title]": { required: "This field is required.", minlength: "Enter at least {0} characters."}
    		}
    	});
});