$(document).on('page:change', function() {

  if ($("td a.poll-title").length > 0) {
    $("td a.poll-title").readmore({
      speed: 75,
      collapsedHeight: 50,
      moreLink: '<a href="#" class="readmore-poll-title">Read more</a>',
      lessLink: '<a href="#" class="close-poll-title">Close</a>'
    });
  };

});


