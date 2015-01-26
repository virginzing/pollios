$(document).on('page:change', function() {
  $.form_new_member = $(".new_member");

  if ($.form_new_member.length > 0) {
    $.form_new_member.parsley();
  };
});





