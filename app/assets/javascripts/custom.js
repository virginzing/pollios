$(document).on('page:change', function() {

  if ($("td a.poll-title").length > 0) {
    $("td a.poll-title").readmore({
      speed: 75,
      collapsedHeight: 50,
      moreLink: '<a href="#" class="readmore-poll-title">Read more</a>',
      lessLink: '<a href="#" class="close-poll-title">Close</a>'
    });
  };

  if ($(".poll-title").length > 0) {
    $(".poll-title").readmore({
      speed: 75,
      collapsedHeight: 50,
      moreLink: '<a href="#" class="readmore-poll-title poll-title-detail">Read more</a>',
      lessLink: '<a href="#" class="close-poll-title poll-title-detail">Close</a>'
    });
  };

  if ($(".datepicker-set-expire").length > 0) {
    $(".datepicker-set-expire").datepicker({
      minDate : 0,
      altFormat : 'dd/mm/yy', 
      dateFormat : 'dd/mm/yy',
      prevText : '<i class="fa fa-chevron-left"></i>',
      nextText : '<i class="fa fa-chevron-right"></i>'
    });
  }
  
});


