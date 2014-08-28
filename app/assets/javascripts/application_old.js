// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require_tree ../../../vendor/assets/javascripts/.
//= require_tree .

$(function() {
  var ajax_request = false;
  $('textarea#tagged_text').textntags({
    triggers: {'#': {
      uniqueTags   : true
    }},
    onDataRequest: function (mode, query, triggerChar, callback) {
      // fix for overlapping requests
      if(ajax_request) ajax_request.abort();

      ajax_request = $.getJSON('/search_autocmp_tags.json', { search: query }, function(responseData) {
          query = query.toLowerCase();
          responseData = _.filter(responseData, function(item) {
            return item.name.toLowerCase().indexOf(query) > -1; 
          });
          callback.call(this, responseData);
          ajax_request = false;
      });

    }
  });

  $("textarea#tagged_text").highlightTextarea({
    words: ["#([[:word]]+)"]
  });

  $('.maxlength_textarea').maxlength({
      limitReachedClass: "label label-danger",
      alwaysShow: true
  });
});