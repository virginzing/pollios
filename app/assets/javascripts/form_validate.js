$(document).on('page:change', function() {
  $.form_new_member = $(".new_member");
  $.form_new_camapagin = $(".new_campaign");

  $.form_new_feedback = $(".new_feedback");
   
  if ($.form_new_member.length > 0) {
    $.form_new_member.parsley();
  };

  if ($.form_new_camapagin.length > 0) {
    $.form_new_camapagin.parsley();
  };

  if ($.form_new_feedback.length > 0) {
    $.form_new_feedback.parsley();
  };

});





