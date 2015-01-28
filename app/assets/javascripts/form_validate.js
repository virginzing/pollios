$(document).on('page:change', function() {
  $.form_new_member = $(".new_member");
  $.form_new_camapagin = $(".new_campaign");

  if ($.form_new_member.length > 0) {
    $.form_new_member.parsley();
  };

  if ($.form_new_camapagin) {
    $.form_new_camapagin.parsley();
  };


});





