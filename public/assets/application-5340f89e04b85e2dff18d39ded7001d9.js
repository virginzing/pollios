(function($, undefined) {

/**
 * Unobtrusive scripting adapter for jQuery
 * https://github.com/rails/jquery-ujs
 *
 * Requires jQuery 1.7.0 or later.
 *
 * Released under the MIT license
 *
 */

  // Cut down on the number of issues from people inadvertently including jquery_ujs twice
  // by detecting and raising an error when it happens.
  if ( $.rails !== undefined ) {
    $.error('jquery-ujs has already been loaded!');
  }

  // Shorthand to make it a little easier to call public rails functions from within rails.js
  var rails;
  var $document = $(document);

  $.rails = rails = {
    // Link elements bound by jquery-ujs
    linkClickSelector: 'a[data-confirm], a[data-method], a[data-remote], a[data-disable-with]',

    // Button elements bound by jquery-ujs
    buttonClickSelector: 'button[data-remote]',

    // Select elements bound by jquery-ujs
    inputChangeSelector: 'select[data-remote], input[data-remote], textarea[data-remote]',

    // Form elements bound by jquery-ujs
    formSubmitSelector: 'form',

    // Form input elements bound by jquery-ujs
    formInputClickSelector: 'form input[type=submit], form input[type=image], form button[type=submit], form button:not([type])',

    // Form input elements disabled during form submission
    disableSelector: 'input[data-disable-with], button[data-disable-with], textarea[data-disable-with]',

    // Form input elements re-enabled after form submission
    enableSelector: 'input[data-disable-with]:disabled, button[data-disable-with]:disabled, textarea[data-disable-with]:disabled',

    // Form required input elements
    requiredInputSelector: 'input[name][required]:not([disabled]),textarea[name][required]:not([disabled])',

    // Form file input elements
    fileInputSelector: 'input[type=file]',

    // Link onClick disable selector with possible reenable after remote submission
    linkDisableSelector: 'a[data-disable-with]',

    // Make sure that every Ajax request sends the CSRF token
    CSRFProtection: function(xhr) {
      var token = $('meta[name="csrf-token"]').attr('content');
      if (token) xhr.setRequestHeader('X-CSRF-Token', token);
    },

    // making sure that all forms have actual up-to-date token(cached forms contain old one)
    refreshCSRFTokens: function(){
      var csrfToken = $('meta[name=csrf-token]').attr('content');
      var csrfParam = $('meta[name=csrf-param]').attr('content');
      $('form input[name="' + csrfParam + '"]').val(csrfToken);
    },

    // Triggers an event on an element and returns false if the event result is false
    fire: function(obj, name, data) {
      var event = $.Event(name);
      obj.trigger(event, data);
      return event.result !== false;
    },

    // Default confirm dialog, may be overridden with custom confirm dialog in $.rails.confirm
    confirm: function(message) {
      return confirm(message);
    },

    // Default ajax function, may be overridden with custom function in $.rails.ajax
    ajax: function(options) {
      return $.ajax(options);
    },

    // Default way to get an element's href. May be overridden at $.rails.href.
    href: function(element) {
      return element.attr('href');
    },

    // Submits "remote" forms and links with ajax
    handleRemote: function(element) {
      var method, url, data, elCrossDomain, crossDomain, withCredentials, dataType, options;

      if (rails.fire(element, 'ajax:before')) {
        elCrossDomain = element.data('cross-domain');
        crossDomain = elCrossDomain === undefined ? null : elCrossDomain;
        withCredentials = element.data('with-credentials') || null;
        dataType = element.data('type') || ($.ajaxSettings && $.ajaxSettings.dataType);

        if (element.is('form')) {
          method = element.attr('method');
          url = element.attr('action');
          data = element.serializeArray();
          // memoized value from clicked submit button
          var button = element.data('ujs:submit-button');
          if (button) {
            data.push(button);
            element.data('ujs:submit-button', null);
          }
        } else if (element.is(rails.inputChangeSelector)) {
          method = element.data('method');
          url = element.data('url');
          data = element.serialize();
          if (element.data('params')) data = data + "&" + element.data('params');
        } else if (element.is(rails.buttonClickSelector)) {
          method = element.data('method') || 'get';
          url = element.data('url');
          data = element.serialize();
          if (element.data('params')) data = data + "&" + element.data('params');
        } else {
          method = element.data('method');
          url = rails.href(element);
          data = element.data('params') || null;
        }

        options = {
          type: method || 'GET', data: data, dataType: dataType,
          // stopping the "ajax:beforeSend" event will cancel the ajax request
          beforeSend: function(xhr, settings) {
            if (settings.dataType === undefined) {
              xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
            }
            return rails.fire(element, 'ajax:beforeSend', [xhr, settings]);
          },
          success: function(data, status, xhr) {
            element.trigger('ajax:success', [data, status, xhr]);
          },
          complete: function(xhr, status) {
            element.trigger('ajax:complete', [xhr, status]);
          },
          error: function(xhr, status, error) {
            element.trigger('ajax:error', [xhr, status, error]);
          },
          crossDomain: crossDomain
        };

        // There is no withCredentials for IE6-8 when
        // "Enable native XMLHTTP support" is disabled
        if (withCredentials) {
          options.xhrFields = {
            withCredentials: withCredentials
          };
        }

        // Only pass url to `ajax` options if not blank
        if (url) { options.url = url; }

        var jqxhr = rails.ajax(options);
        element.trigger('ajax:send', jqxhr);
        return jqxhr;
      } else {
        return false;
      }
    },

    // Handles "data-method" on links such as:
    // <a href="/users/5" data-method="delete" rel="nofollow" data-confirm="Are you sure?">Delete</a>
    handleMethod: function(link) {
      var href = rails.href(link),
        method = link.data('method'),
        target = link.attr('target'),
        csrfToken = $('meta[name=csrf-token]').attr('content'),
        csrfParam = $('meta[name=csrf-param]').attr('content'),
        form = $('<form method="post" action="' + href + '"></form>'),
        metadataInput = '<input name="_method" value="' + method + '" type="hidden" />';

      if (csrfParam !== undefined && csrfToken !== undefined) {
        metadataInput += '<input name="' + csrfParam + '" value="' + csrfToken + '" type="hidden" />';
      }

      if (target) { form.attr('target', target); }

      form.hide().append(metadataInput).appendTo('body');
      form.submit();
    },

    /* Disables form elements:
      - Caches element value in 'ujs:enable-with' data store
      - Replaces element text with value of 'data-disable-with' attribute
      - Sets disabled property to true
    */
    disableFormElements: function(form) {
      form.find(rails.disableSelector).each(function() {
        var element = $(this), method = element.is('button') ? 'html' : 'val';
        element.data('ujs:enable-with', element[method]());
        element[method](element.data('disable-with'));
        element.prop('disabled', true);
      });
    },

    /* Re-enables disabled form elements:
      - Replaces element text with cached value from 'ujs:enable-with' data store (created in `disableFormElements`)
      - Sets disabled property to false
    */
    enableFormElements: function(form) {
      form.find(rails.enableSelector).each(function() {
        var element = $(this), method = element.is('button') ? 'html' : 'val';
        if (element.data('ujs:enable-with')) element[method](element.data('ujs:enable-with'));
        element.prop('disabled', false);
      });
    },

   /* For 'data-confirm' attribute:
      - Fires `confirm` event
      - Shows the confirmation dialog
      - Fires the `confirm:complete` event

      Returns `true` if no function stops the chain and user chose yes; `false` otherwise.
      Attaching a handler to the element's `confirm` event that returns a `falsy` value cancels the confirmation dialog.
      Attaching a handler to the element's `confirm:complete` event that returns a `falsy` value makes this function
      return false. The `confirm:complete` event is fired whether or not the user answered true or false to the dialog.
   */
    allowAction: function(element) {
      var message = element.data('confirm'),
          answer = false, callback;
      if (!message) { return true; }

      if (rails.fire(element, 'confirm')) {
        answer = rails.confirm(message);
        callback = rails.fire(element, 'confirm:complete', [answer]);
      }
      return answer && callback;
    },

    // Helper function which checks for blank inputs in a form that match the specified CSS selector
    blankInputs: function(form, specifiedSelector, nonBlank) {
      var inputs = $(), input, valueToCheck,
          selector = specifiedSelector || 'input,textarea',
          allInputs = form.find(selector);

      allInputs.each(function() {
        input = $(this);
        valueToCheck = input.is('input[type=checkbox],input[type=radio]') ? input.is(':checked') : input.val();
        // If nonBlank and valueToCheck are both truthy, or nonBlank and valueToCheck are both falsey
        if (!valueToCheck === !nonBlank) {

          // Don't count unchecked required radio if other radio with same name is checked
          if (input.is('input[type=radio]') && allInputs.filter('input[type=radio]:checked[name="' + input.attr('name') + '"]').length) {
            return true; // Skip to next input
          }

          inputs = inputs.add(input);
        }
      });
      return inputs.length ? inputs : false;
    },

    // Helper function which checks for non-blank inputs in a form that match the specified CSS selector
    nonBlankInputs: function(form, specifiedSelector) {
      return rails.blankInputs(form, specifiedSelector, true); // true specifies nonBlank
    },

    // Helper function, needed to provide consistent behavior in IE
    stopEverything: function(e) {
      $(e.target).trigger('ujs:everythingStopped');
      e.stopImmediatePropagation();
      return false;
    },

    //  replace element's html with the 'data-disable-with' after storing original html
    //  and prevent clicking on it
    disableElement: function(element) {
      element.data('ujs:enable-with', element.html()); // store enabled state
      element.html(element.data('disable-with')); // set to disabled state
      element.bind('click.railsDisable', function(e) { // prevent further clicking
        return rails.stopEverything(e);
      });
    },

    // restore element to its original state which was disabled by 'disableElement' above
    enableElement: function(element) {
      if (element.data('ujs:enable-with') !== undefined) {
        element.html(element.data('ujs:enable-with')); // set to old enabled state
        element.removeData('ujs:enable-with'); // clean up cache
      }
      element.unbind('click.railsDisable'); // enable element
    }

  };

  if (rails.fire($document, 'rails:attachBindings')) {

    $.ajaxPrefilter(function(options, originalOptions, xhr){ if ( !options.crossDomain ) { rails.CSRFProtection(xhr); }});

    $document.delegate(rails.linkDisableSelector, 'ajax:complete', function() {
        rails.enableElement($(this));
    });

    $document.delegate(rails.linkClickSelector, 'click.rails', function(e) {
      var link = $(this), method = link.data('method'), data = link.data('params'), metaClick = e.metaKey || e.ctrlKey;
      if (!rails.allowAction(link)) return rails.stopEverything(e);

      if (!metaClick && link.is(rails.linkDisableSelector)) rails.disableElement(link);

      if (link.data('remote') !== undefined) {
        if (metaClick && (!method || method === 'GET') && !data) { return true; }

        var handleRemote = rails.handleRemote(link);
        // response from rails.handleRemote() will either be false or a deferred object promise.
        if (handleRemote === false) {
          rails.enableElement(link);
        } else {
          handleRemote.error( function() { rails.enableElement(link); } );
        }
        return false;

      } else if (link.data('method')) {
        rails.handleMethod(link);
        return false;
      }
    });

    $document.delegate(rails.buttonClickSelector, 'click.rails', function(e) {
      var button = $(this);
      if (!rails.allowAction(button)) return rails.stopEverything(e);

      rails.handleRemote(button);
      return false;
    });

    $document.delegate(rails.inputChangeSelector, 'change.rails', function(e) {
      var link = $(this);
      if (!rails.allowAction(link)) return rails.stopEverything(e);

      rails.handleRemote(link);
      return false;
    });

    $document.delegate(rails.formSubmitSelector, 'submit.rails', function(e) {
      var form = $(this),
        remote = form.data('remote') !== undefined,
        blankRequiredInputs = rails.blankInputs(form, rails.requiredInputSelector),
        nonBlankFileInputs = rails.nonBlankInputs(form, rails.fileInputSelector);

      if (!rails.allowAction(form)) return rails.stopEverything(e);

      // skip other logic when required values are missing or file upload is present
      if (blankRequiredInputs && form.attr("novalidate") == undefined && rails.fire(form, 'ajax:aborted:required', [blankRequiredInputs])) {
        return rails.stopEverything(e);
      }

      if (remote) {
        if (nonBlankFileInputs) {
          // slight timeout so that the submit button gets properly serialized
          // (make it easy for event handler to serialize form without disabled values)
          setTimeout(function(){ rails.disableFormElements(form); }, 13);
          var aborted = rails.fire(form, 'ajax:aborted:file', [nonBlankFileInputs]);

          // re-enable form elements if event bindings return false (canceling normal form submission)
          if (!aborted) { setTimeout(function(){ rails.enableFormElements(form); }, 13); }

          return aborted;
        }

        rails.handleRemote(form);
        return false;

      } else {
        // slight timeout so that the submit button gets properly serialized
        setTimeout(function(){ rails.disableFormElements(form); }, 13);
      }
    });

    $document.delegate(rails.formInputClickSelector, 'click.rails', function(event) {
      var button = $(this);

      if (!rails.allowAction(button)) return rails.stopEverything(event);

      // register the pressed submit button
      var name = button.attr('name'),
        data = name ? {name:name, value:button.val()} : null;

      button.closest('form').data('ujs:submit-button', data);
    });

    $document.delegate(rails.formSubmitSelector, 'ajax:beforeSend.rails', function(event) {
      if (this == event.target) rails.disableFormElements($(this));
    });

    $document.delegate(rails.formSubmitSelector, 'ajax:complete.rails', function(event) {
      if (this == event.target) rails.enableFormElements($(this));
    });

    $(function(){
      rails.refreshCSRFTokens();
    });
  }

})( jQuery );
(function($) {
  window.NestedFormEvents = function() {
    this.addFields = $.proxy(this.addFields, this);
    this.removeFields = $.proxy(this.removeFields, this);
  };

  NestedFormEvents.prototype = {
    addFields: function(e) {
      // Setup
      var link      = e.currentTarget;
      var assoc     = $(link).data('association');                // Name of child
      var blueprint = $('#' + $(link).data('blueprint-id'));
      var content   = blueprint.data('blueprint');                // Fields template

      // Make the context correct by replacing <parents> with the generated ID
      // of each of the parent objects
      var context = ($(link).closest('.fields').closestChild('input, textarea, select').eq(0).attr('name') || '').replace(new RegExp('\[[a-z_]+\]$'), '');

      // context will be something like this for a brand new form:
      // project[tasks_attributes][1255929127459][assignments_attributes][1255929128105]
      // or for an edit form:
      // project[tasks_attributes][0][assignments_attributes][1]
      if (context) {
        var parentNames = context.match(/[a-z_]+_attributes(?=\]\[(new_)?\d+\])/g) || [];
        var parentIds   = context.match(/[0-9]+/g) || [];

        for(var i = 0; i < parentNames.length; i++) {
          if(parentIds[i]) {
            content = content.replace(
              new RegExp('(_' + parentNames[i] + ')_.+?_', 'g'),
              '$1_' + parentIds[i] + '_');

            content = content.replace(
              new RegExp('(\\[' + parentNames[i] + '\\])\\[.+?\\]', 'g'),
              '$1[' + parentIds[i] + ']');
          }
        }
      }

      // Make a unique ID for the new child
      var regexp  = new RegExp('new_' + assoc, 'g');
      var new_id  = this.newId();
      content     = $.trim(content.replace(regexp, new_id));

      var field = this.insertFields(content, assoc, link);
      // bubble up event upto document (through form)
      field
        .trigger({ type: 'nested:fieldAdded', field: field })
        .trigger({ type: 'nested:fieldAdded:' + assoc, field: field });
      return false;
    },
    newId: function() {
      return new Date().getTime();
    },
    insertFields: function(content, assoc, link) {
      var target = $(link).data('target');
      if (target) {
        return $(content).appendTo($(target));
      } else {
        return $(content).insertBefore(link);
      }
    },
    removeFields: function(e) {
      var $link = $(e.currentTarget),
          assoc = $link.data('association'); // Name of child to be removed
      
      var hiddenField = $link.prev('input[type=hidden]');
      hiddenField.val('1');
      
      var field = $link.closest('.fields');
      field.hide();
      
      field
        .trigger({ type: 'nested:fieldRemoved', field: field })
        .trigger({ type: 'nested:fieldRemoved:' + assoc, field: field });
      return false;
    }
  };

  window.nestedFormEvents = new NestedFormEvents();
  $(document)
    .delegate('form a.add_nested_fields',    'click', nestedFormEvents.addFields)
    .delegate('form a.remove_nested_fields', 'click', nestedFormEvents.removeFields);
})(jQuery);

// http://plugins.jquery.com/project/closestChild
/*
 * Copyright 2011, Tobias Lindig
 *
 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 *
 */
(function($) {
        $.fn.closestChild = function(selector) {
                // breadth first search for the first matched node
                if (selector && selector != '') {
                        var queue = [];
                        queue.push(this);
                        while(queue.length > 0) {
                                var node = queue.shift();
                                var children = node.children();
                                for(var i = 0; i < children.length; ++i) {
                                        var child = $(children[i]);
                                        if (child.is(selector)) {
                                                return child; //well, we found one
                                        }
                                        queue.push(child);
                                }
                        }
                }
                return $();//nothing found
        };
})(jQuery);
/**
 * bootbox.js [v4.2.0]
 *
 * http://bootboxjs.com/license.txt
 */

// @see https://github.com/makeusabrew/bootbox/issues/180
// @see https://github.com/makeusabrew/bootbox/issues/186
(function (root, factory) {

  "use strict";
  if (typeof define === "function" && define.amd) {
    // AMD. Register as an anonymous module.
    define(["jquery"], factory);
  } else if (typeof exports === "object") {
    // Node. Does not work with strict CommonJS, but
    // only CommonJS-like environments that support module.exports,
    // like Node.
    module.exports = factory(require("jquery"));
  } else {
    // Browser globals (root is window)
    root.bootbox = factory(root.jQuery);
  }

}(this, function init($, undefined) {

  "use strict";

  // the base DOM structure needed to create a modal
  var templates = {
    dialog:
      "<div class='bootbox modal' tabindex='-1' role='dialog'>" +
        "<div class='modal-dialog'>" +
          "<div class='modal-content'>" +
            "<div class='modal-body'><div class='bootbox-body'></div></div>" +
          "</div>" +
        "</div>" +
      "</div>",
    header:
      "<div class='modal-header'>" +
        "<h4 class='modal-title'></h4>" +
      "</div>",
    footer:
      "<div class='modal-footer'></div>",
    closeButton:
      "<button type='button' class='bootbox-close-button close' data-dismiss='modal' aria-hidden='true'>&times;</button>",
    form:
      "<form class='bootbox-form'></form>",
    inputs: {
      text:
        "<input class='bootbox-input bootbox-input-text form-control' autocomplete=off type=text />",
      textarea:
        "<textarea class='bootbox-input bootbox-input-textarea form-control'></textarea>",
      email:
        "<input class='bootbox-input bootbox-input-email form-control' autocomplete='off' type='email' />",
      select:
        "<select class='bootbox-input bootbox-input-select form-control'></select>",
      checkbox:
        "<div class='checkbox'><label><input class='bootbox-input bootbox-input-checkbox' type='checkbox' /></label></div>",
      date:
        "<input class='bootbox-input bootbox-input-date form-control' autocomplete=off type='date' />",
      time:
        "<input class='bootbox-input bootbox-input-time form-control' autocomplete=off type='time' />",
      number:
        "<input class='bootbox-input bootbox-input-number form-control' autocomplete=off type='number' />",
      password:
        "<input class='bootbox-input bootbox-input-password form-control' autocomplete='off' type='password' />"
    }
  };

  var defaults = {
    // default language
    locale: "en",
    // show backdrop or not
    backdrop: true,
    // animate the modal in/out
    animate: true,
    // additional class string applied to the top level dialog
    className: null,
    // whether or not to include a close button
    closeButton: true,
    // show the dialog immediately by default
    show: true,
    // dialog container
    container: "body"
  };

  // our public object; augmented after our private API
  var exports = {};

  /**
   * @private
   */
  function _t(key) {
    var locale = locales[defaults.locale];
    return locale ? locale[key] : locales.en[key];
  }

  function processCallback(e, dialog, callback) {
    e.stopPropagation();
    e.preventDefault();

    // by default we assume a callback will get rid of the dialog,
    // although it is given the opportunity to override this

    // so, if the callback can be invoked and it *explicitly returns false*
    // then we'll set a flag to keep the dialog active...
    var preserveDialog = $.isFunction(callback) && callback(e) === false;

    // ... otherwise we'll bin it
    if (!preserveDialog) {
      dialog.modal("hide");
    }
  }

  function getKeyLength(obj) {
    // @TODO defer to Object.keys(x).length if available?
    var k, t = 0;
    for (k in obj) {
      t ++;
    }
    return t;
  }

  function each(collection, iterator) {
    var index = 0;
    $.each(collection, function(key, value) {
      iterator(key, value, index++);
    });
  }

  function sanitize(options) {
    var buttons;
    var total;

    if (typeof options !== "object") {
      throw new Error("Please supply an object of options");
    }

    if (!options.message) {
      throw new Error("Please specify a message");
    }

    // make sure any supplied options take precedence over defaults
    options = $.extend({}, defaults, options);

    if (!options.buttons) {
      options.buttons = {};
    }

    // we only support Bootstrap's "static" and false backdrop args
    // supporting true would mean you could dismiss the dialog without
    // explicitly interacting with it
    options.backdrop = options.backdrop ? "static" : false;

    buttons = options.buttons;

    total = getKeyLength(buttons);

    each(buttons, function(key, button, index) {

      if ($.isFunction(button)) {
        // short form, assume value is our callback. Since button
        // isn't an object it isn't a reference either so re-assign it
        button = buttons[key] = {
          callback: button
        };
      }

      // before any further checks make sure by now button is the correct type
      if ($.type(button) !== "object") {
        throw new Error("button with key " + key + " must be an object");
      }

      if (!button.label) {
        // the lack of an explicit label means we'll assume the key is good enough
        button.label = key;
      }

      if (!button.className) {
        if (total <= 2 && index === total-1) {
          // always add a primary to the main option in a two-button dialog
          button.className = "btn-primary";
        } else {
          button.className = "btn-default";
        }
      }
    });

    return options;
  }

  /**
   * map a flexible set of arguments into a single returned object
   * if args.length is already one just return it, otherwise
   * use the properties argument to map the unnamed args to
   * object properties
   * so in the latter case:
   * mapArguments(["foo", $.noop], ["message", "callback"])
   * -> { message: "foo", callback: $.noop }
   */
  function mapArguments(args, properties) {
    var argn = args.length;
    var options = {};

    if (argn < 1 || argn > 2) {
      throw new Error("Invalid argument length");
    }

    if (argn === 2 || typeof args[0] === "string") {
      options[properties[0]] = args[0];
      options[properties[1]] = args[1];
    } else {
      options = args[0];
    }

    return options;
  }

  /**
   * merge a set of default dialog options with user supplied arguments
   */
  function mergeArguments(defaults, args, properties) {
    return $.extend(
      // deep merge
      true,
      // ensure the target is an empty, unreferenced object
      {},
      // the base options object for this type of dialog (often just buttons)
      defaults,
      // args could be an object or array; if it's an array properties will
      // map it to a proper options object
      mapArguments(
        args,
        properties
      )
    );
  }

  /**
   * this entry-level method makes heavy use of composition to take a simple
   * range of inputs and return valid options suitable for passing to bootbox.dialog
   */
  function mergeDialogOptions(className, labels, properties, args) {
    //  build up a base set of dialog properties
    var baseOptions = {
      className: "bootbox-" + className,
      buttons: createLabels.apply(null, labels)
    };

    // ensure the buttons properties generated, *after* merging
    // with user args are still valid against the supplied labels
    return validateButtons(
      // merge the generated base properties with user supplied arguments
      mergeArguments(
        baseOptions,
        args,
        // if args.length > 1, properties specify how each arg maps to an object key
        properties
      ),
      labels
    );
  }

  /**
   * from a given list of arguments return a suitable object of button labels
   * all this does is normalise the given labels and translate them where possible
   * e.g. "ok", "confirm" -> { ok: "OK, cancel: "Annuleren" }
   */
  function createLabels() {
    var buttons = {};

    for (var i = 0, j = arguments.length; i < j; i++) {
      var argument = arguments[i];
      var key = argument.toLowerCase();
      var value = argument.toUpperCase();

      buttons[key] = {
        label: _t(value)
      };
    }

    return buttons;
  }

  function validateButtons(options, buttons) {
    var allowedButtons = {};
    each(buttons, function(key, value) {
      allowedButtons[value] = true;
    });

    each(options.buttons, function(key) {
      if (allowedButtons[key] === undefined) {
        throw new Error("button key " + key + " is not allowed (options are " + buttons.join("\n") + ")");
      }
    });

    return options;
  }

  exports.alert = function() {
    var options;

    options = mergeDialogOptions("alert", ["ok"], ["message", "callback"], arguments);

    if (options.callback && !$.isFunction(options.callback)) {
      throw new Error("alert requires callback property to be a function when provided");
    }

    /**
     * overrides
     */
    options.buttons.ok.callback = options.onEscape = function() {
      if ($.isFunction(options.callback)) {
        return options.callback();
      }
      return true;
    };

    return exports.dialog(options);
  };

  exports.confirm = function() {
    var options;

    options = mergeDialogOptions("confirm", ["cancel", "confirm"], ["message", "callback"], arguments);

    /**
     * overrides; undo anything the user tried to set they shouldn't have
     */
    options.buttons.cancel.callback = options.onEscape = function() {
      return options.callback(false);
    };

    options.buttons.confirm.callback = function() {
      return options.callback(true);
    };

    // confirm specific validation
    if (!$.isFunction(options.callback)) {
      throw new Error("confirm requires a callback");
    }

    return exports.dialog(options);
  };

  exports.prompt = function() {
    var options;
    var defaults;
    var dialog;
    var form;
    var input;
    var shouldShow;
    var inputOptions;

    // we have to create our form first otherwise
    // its value is undefined when gearing up our options
    // @TODO this could be solved by allowing message to
    // be a function instead...
    form = $(templates.form);

    // prompt defaults are more complex than others in that
    // users can override more defaults
    // @TODO I don't like that prompt has to do a lot of heavy
    // lifting which mergeDialogOptions can *almost* support already
    // just because of 'value' and 'inputType' - can we refactor?
    defaults = {
      className: "bootbox-prompt",
      buttons: createLabels("cancel", "confirm"),
      value: "",
      inputType: "text"
    };

    options = validateButtons(
      mergeArguments(defaults, arguments, ["title", "callback"]),
      ["cancel", "confirm"]
    );

    // capture the user's show value; we always set this to false before
    // spawning the dialog to give us a chance to attach some handlers to
    // it, but we need to make sure we respect a preference not to show it
    shouldShow = (options.show === undefined) ? true : options.show;

    // check if the browser supports the option.inputType
    var html5inputs = ["date","time","number"];
    var i = document.createElement("input");
    i.setAttribute("type", options.inputType);
    if(html5inputs[options.inputType]){
      options.inputType = i.type;
    }

    /**
     * overrides; undo anything the user tried to set they shouldn't have
     */
    options.message = form;

    options.buttons.cancel.callback = options.onEscape = function() {
      return options.callback(null);
    };

    options.buttons.confirm.callback = function() {
      var value;

      switch (options.inputType) {
        case "text":
        case "textarea":
        case "email":
        case "select":
        case "date":
        case "time":
        case "number":
        case "password":
          value = input.val();
          break;

        case "checkbox":
          var checkedItems = input.find("input:checked");

          // we assume that checkboxes are always multiple,
          // hence we default to an empty array
          value = [];

          each(checkedItems, function(_, item) {
            value.push($(item).val());
          });
          break;
      }

      return options.callback(value);
    };

    options.show = false;

    // prompt specific validation
    if (!options.title) {
      throw new Error("prompt requires a title");
    }

    if (!$.isFunction(options.callback)) {
      throw new Error("prompt requires a callback");
    }

    if (!templates.inputs[options.inputType]) {
      throw new Error("invalid prompt type");
    }

    // create the input based on the supplied type
    input = $(templates.inputs[options.inputType]);

    switch (options.inputType) {
      case "text":
      case "textarea":
      case "email":
      case "date":
      case "time":
      case "number":
      case "password":
        input.val(options.value);
        break;

      case "select":
        var groups = {};
        inputOptions = options.inputOptions || [];

        if (!inputOptions.length) {
          throw new Error("prompt with select requires options");
        }

        each(inputOptions, function(_, option) {

          // assume the element to attach to is the input...
          var elem = input;

          if (option.value === undefined || option.text === undefined) {
            throw new Error("given options in wrong format");
          }


          // ... but override that element if this option sits in a group

          if (option.group) {
            // initialise group if necessary
            if (!groups[option.group]) {
              groups[option.group] = $("<optgroup/>").attr("label", option.group);
            }

            elem = groups[option.group];
          }

          elem.append("<option value='" + option.value + "'>" + option.text + "</option>");
        });

        each(groups, function(_, group) {
          input.append(group);
        });

        // safe to set a select's value as per a normal input
        input.val(options.value);
        break;

      case "checkbox":
        var values   = $.isArray(options.value) ? options.value : [options.value];
        inputOptions = options.inputOptions || [];

        if (!inputOptions.length) {
          throw new Error("prompt with checkbox requires options");
        }

        if (!inputOptions[0].value || !inputOptions[0].text) {
          throw new Error("given options in wrong format");
        }

        // checkboxes have to nest within a containing element, so
        // they break the rules a bit and we end up re-assigning
        // our 'input' element to this container instead
        input = $("<div/>");

        each(inputOptions, function(_, option) {
          var checkbox = $(templates.inputs[options.inputType]);

          checkbox.find("input").attr("value", option.value);
          checkbox.find("label").append(option.text);

          // we've ensured values is an array so we can always iterate over it
          each(values, function(_, value) {
            if (value === option.value) {
              checkbox.find("input").prop("checked", true);
            }
          });

          input.append(checkbox);
        });
        break;
    }

    if (options.placeholder) {
      input.attr("placeholder", options.placeholder);
    }

    if(options.pattern){
      input.attr("pattern", options.pattern);
    }

    // now place it in our form
    form.append(input);

    form.on("submit", function(e) {
      e.preventDefault();
      // @TODO can we actually click *the* button object instead?
      // e.g. buttons.confirm.click() or similar
      dialog.find(".btn-primary").click();
    });

    dialog = exports.dialog(options);

    // clear the existing handler focusing the submit button...
    dialog.off("shown.bs.modal");

    // ...and replace it with one focusing our input, if possible
    dialog.on("shown.bs.modal", function() {
      input.focus();
    });

    if (shouldShow === true) {
      dialog.modal("show");
    }

    return dialog;
  };

  exports.dialog = function(options) {
    options = sanitize(options);

    var dialog = $(templates.dialog);
    var body = dialog.find(".modal-body");
    var buttons = options.buttons;
    var buttonStr = "";
    var callbacks = {
      onEscape: options.onEscape
    };

    each(buttons, function(key, button) {

      // @TODO I don't like this string appending to itself; bit dirty. Needs reworking
      // can we just build up button elements instead? slower but neater. Then button
      // can just become a template too
      buttonStr += "<button data-bb-handler='" + key + "' type='button' class='btn " + button.className + "'>" + button.label + "</button>";
      callbacks[key] = button.callback;
    });

    body.find(".bootbox-body").html(options.message);

    if (options.animate === true) {
      dialog.addClass("fade");
    }

    if (options.className) {
      dialog.addClass(options.className);
    }

    if (options.title) {
      body.before(templates.header);
    }

    if (options.closeButton) {
      var closeButton = $(templates.closeButton);

      if (options.title) {
        dialog.find(".modal-header").prepend(closeButton);
      } else {
        closeButton.css("margin-top", "-10px").prependTo(body);
      }
    }

    if (options.title) {
      dialog.find(".modal-title").html(options.title);
    }

    if (buttonStr.length) {
      body.after(templates.footer);
      dialog.find(".modal-footer").html(buttonStr);
    }


    /**
     * Bootstrap event listeners; used handle extra
     * setup & teardown required after the underlying
     * modal has performed certain actions
     */

    dialog.on("hidden.bs.modal", function(e) {
      // ensure we don't accidentally intercept hidden events triggered
      // by children of the current dialog. We shouldn't anymore now BS
      // namespaces its events; but still worth doing
      if (e.target === this) {
        dialog.remove();
      }
    });

    /*
    dialog.on("show.bs.modal", function() {
      // sadly this doesn't work; show is called *just* before
      // the backdrop is added so we'd need a setTimeout hack or
      // otherwise... leaving in as would be nice
      if (options.backdrop) {
        dialog.next(".modal-backdrop").addClass("bootbox-backdrop");
      }
    });
    */

    dialog.on("shown.bs.modal", function() {
      dialog.find(".btn-primary:first").focus();
    });

    /**
     * Bootbox event listeners; experimental and may not last
     * just an attempt to decouple some behaviours from their
     * respective triggers
     */

    dialog.on("escape.close.bb", function(e) {
      if (callbacks.onEscape) {
        processCallback(e, dialog, callbacks.onEscape);
      }
    });

    /**
     * Standard jQuery event listeners; used to handle user
     * interaction with our dialog
     */

    dialog.on("click", ".modal-footer button", function(e) {
      var callbackKey = $(this).data("bb-handler");

      processCallback(e, dialog, callbacks[callbackKey]);

    });

    dialog.on("click", ".bootbox-close-button", function(e) {
      // onEscape might be falsy but that's fine; the fact is
      // if the user has managed to click the close button we
      // have to close the dialog, callback or not
      processCallback(e, dialog, callbacks.onEscape);
    });

    dialog.on("keyup", function(e) {
      if (e.which === 27) {
        dialog.trigger("escape.close.bb");
      }
    });

    // the remainder of this method simply deals with adding our
    // dialogent to the DOM, augmenting it with Bootstrap's modal
    // functionality and then giving the resulting object back
    // to our caller

    $(options.container).append(dialog);

    dialog.modal({
      backdrop: options.backdrop,
      keyboard: false,
      show: false
    });

    if (options.show) {
      dialog.modal("show");
    }

    // @TODO should we return the raw element here or should
    // we wrap it in an object on which we can expose some neater
    // methods, e.g. var d = bootbox.alert(); d.hide(); instead
    // of d.modal("hide");

   /*
    function BBDialog(elem) {
      this.elem = elem;
    }

    BBDialog.prototype = {
      hide: function() {
        return this.elem.modal("hide");
      },
      show: function() {
        return this.elem.modal("show");
      }
    };
    */

    return dialog;

  };

  exports.setDefaults = function() {
    var values = {};

    if (arguments.length === 2) {
      // allow passing of single key/value...
      values[arguments[0]] = arguments[1];
    } else {
      // ... and as an object too
      values = arguments[0];
    }

    $.extend(defaults, values);
  };

  exports.hideAll = function() {
    $(".bootbox").modal("hide");
  };


  /**
   * standard locales. Please add more according to ISO 639-1 standard. Multiple language variants are
   * unlikely to be required. If this gets too large it can be split out into separate JS files.
   */
  var locales = {
    br : {
      OK      : "OK",
      CANCEL  : "Cancelar",
      CONFIRM : "Sim"
    },
    da : {
      OK      : "OK",
      CANCEL  : "Annuller",
      CONFIRM : "Accepter"
    },
    de : {
      OK      : "OK",
      CANCEL  : "Abbrechen",
      CONFIRM : "Akzeptieren"
    },
    en : {
      OK      : "OK",
      CANCEL  : "Cancel",
      CONFIRM : "OK"
    },
    es : {
      OK      : "OK",
      CANCEL  : "Cancelar",
      CONFIRM : "Aceptar"
    },
    fi : {
      OK      : "OK",
      CANCEL  : "Peruuta",
      CONFIRM : "OK"
    },
    fr : {
      OK      : "OK",
      CANCEL  : "Annuler",
      CONFIRM : "D'accord"
    },
    he : {
      OK      : "אישור",
      CANCEL  : "ביטול",
      CONFIRM : "אישור"
    },
    it : {
      OK      : "OK",
      CANCEL  : "Annulla",
      CONFIRM : "Conferma"
    },
    lt : {
      OK      : "Gerai",
      CANCEL  : "Atšaukti",
      CONFIRM : "Patvirtinti"
    },
    lv : {
      OK      : "Labi",
      CANCEL  : "Atcelt",
      CONFIRM : "Apstiprināt"
    },
    nl : {
      OK      : "OK",
      CANCEL  : "Annuleren",
      CONFIRM : "Accepteren"
    },
    no : {
      OK      : "OK",
      CANCEL  : "Avbryt",
      CONFIRM : "OK"
    },
    pl : {
      OK      : "OK",
      CANCEL  : "Anuluj",
      CONFIRM : "Potwierdź"
    },
    ru : {
      OK      : "OK",
      CANCEL  : "Отмена",
      CONFIRM : "Применить"
    },
    sv : {
      OK      : "OK",
      CANCEL  : "Avbryt",
      CONFIRM : "OK"
    },
    tr : {
      OK      : "Tamam",
      CANCEL  : "İptal",
      CONFIRM : "Onayla"
    },
    zh_CN : {
      OK      : "OK",
      CANCEL  : "取消",
      CONFIRM : "确认"
    },
    zh_TW : {
      OK      : "OK",
      CANCEL  : "取消",
      CONFIRM : "確認"
    }
  };

  exports.init = function(_$) {
    return init(_$ || $);
  };

  return exports;
}));
$(document).ready(function() {
  $.rails.allowAction = function(element) {
  var message = element.data('confirm'),
    answer = false, callback;
  if (!message) { return true; }
 
  if ($.rails.fire(element, 'confirm')) {
    myCustomConfirmBox(message, function() {
      callback = $.rails.fire(element,
        'confirm:complete', [answer]);
        if(callback) {
          var oldAllowAction = $.rails.allowAction;
          $.rails.allowAction = function() { return true; };
          element.trigger('click');
          $.rails.allowAction = oldAllowAction;
        }
      });
    }
    return false;
  }
 
  function myCustomConfirmBox(message, callback) {
    bootbox.confirm(message, function(confirmed) {
        if(confirmed){
            callback();
        }
    });
  }
});  
//! moment.js
//! version : 2.2.1
//! authors : Tim Wood, Iskren Chernev, Moment.js contributors
//! license : MIT
//! momentjs.com
(function(a){function b(a,b){return function(c){return i(a.call(this,c),b)}}function c(a,b){return function(c){return this.lang().ordinal(a.call(this,c),b)}}function d(){}function e(a){g(this,a)}function f(a){var b=a.years||a.year||a.y||0,c=a.months||a.month||a.M||0,d=a.weeks||a.week||a.w||0,e=a.days||a.day||a.d||0,f=a.hours||a.hour||a.h||0,g=a.minutes||a.minute||a.m||0,h=a.seconds||a.second||a.s||0,i=a.milliseconds||a.millisecond||a.ms||0;this._input=a,this._milliseconds=+i+1e3*h+6e4*g+36e5*f,this._days=+e+7*d,this._months=+c+12*b,this._data={},this._bubble()}function g(a,b){for(var c in b)b.hasOwnProperty(c)&&(a[c]=b[c]);return a}function h(a){return 0>a?Math.ceil(a):Math.floor(a)}function i(a,b){for(var c=a+"";c.length<b;)c="0"+c;return c}function j(a,b,c,d){var e,f,g=b._milliseconds,h=b._days,i=b._months;g&&a._d.setTime(+a._d+g*c),(h||i)&&(e=a.minute(),f=a.hour()),h&&a.date(a.date()+h*c),i&&a.month(a.month()+i*c),g&&!d&&L.updateOffset(a),(h||i)&&(a.minute(e),a.hour(f))}function k(a){return"[object Array]"===Object.prototype.toString.call(a)}function l(a,b){var c,d=Math.min(a.length,b.length),e=Math.abs(a.length-b.length),f=0;for(c=0;d>c;c++)~~a[c]!==~~b[c]&&f++;return f+e}function m(a){return a?ib[a]||a.toLowerCase().replace(/(.)s$/,"$1"):a}function n(a,b){return b.abbr=a,P[a]||(P[a]=new d),P[a].set(b),P[a]}function o(a){delete P[a]}function p(a){if(!a)return L.fn._lang;if(!P[a]&&Q)try{require("./lang/"+a)}catch(b){return L.fn._lang}return P[a]||L.fn._lang}function q(a){return a.match(/\[.*\]/)?a.replace(/^\[|\]$/g,""):a.replace(/\\/g,"")}function r(a){var b,c,d=a.match(T);for(b=0,c=d.length;c>b;b++)d[b]=mb[d[b]]?mb[d[b]]:q(d[b]);return function(e){var f="";for(b=0;c>b;b++)f+=d[b]instanceof Function?d[b].call(e,a):d[b];return f}}function s(a,b){return b=t(b,a.lang()),jb[b]||(jb[b]=r(b)),jb[b](a)}function t(a,b){function c(a){return b.longDateFormat(a)||a}for(var d=5;d--&&(U.lastIndex=0,U.test(a));)a=a.replace(U,c);return a}function u(a,b){switch(a){case"DDDD":return X;case"YYYY":return Y;case"YYYYY":return Z;case"S":case"SS":case"SSS":case"DDD":return W;case"MMM":case"MMMM":case"dd":case"ddd":case"dddd":return $;case"a":case"A":return p(b._l)._meridiemParse;case"X":return bb;case"Z":case"ZZ":return _;case"T":return ab;case"MM":case"DD":case"YY":case"HH":case"hh":case"mm":case"ss":case"M":case"D":case"d":case"H":case"h":case"m":case"s":return V;default:return new RegExp(a.replace("\\",""))}}function v(a){var b=(_.exec(a)||[])[0],c=(b+"").match(fb)||["-",0,0],d=+(60*c[1])+~~c[2];return"+"===c[0]?-d:d}function w(a,b,c){var d,e=c._a;switch(a){case"M":case"MM":null!=b&&(e[1]=~~b-1);break;case"MMM":case"MMMM":d=p(c._l).monthsParse(b),null!=d?e[1]=d:c._isValid=!1;break;case"D":case"DD":null!=b&&(e[2]=~~b);break;case"DDD":case"DDDD":null!=b&&(e[1]=0,e[2]=~~b);break;case"YY":e[0]=~~b+(~~b>68?1900:2e3);break;case"YYYY":case"YYYYY":e[0]=~~b;break;case"a":case"A":c._isPm=p(c._l).isPM(b);break;case"H":case"HH":case"h":case"hh":e[3]=~~b;break;case"m":case"mm":e[4]=~~b;break;case"s":case"ss":e[5]=~~b;break;case"S":case"SS":case"SSS":e[6]=~~(1e3*("0."+b));break;case"X":c._d=new Date(1e3*parseFloat(b));break;case"Z":case"ZZ":c._useUTC=!0,c._tzm=v(b)}null==b&&(c._isValid=!1)}function x(a){var b,c,d,e=[];if(!a._d){for(d=z(a),b=0;3>b&&null==a._a[b];++b)a._a[b]=e[b]=d[b];for(;7>b;b++)a._a[b]=e[b]=null==a._a[b]?2===b?1:0:a._a[b];e[3]+=~~((a._tzm||0)/60),e[4]+=~~((a._tzm||0)%60),c=new Date(0),a._useUTC?(c.setUTCFullYear(e[0],e[1],e[2]),c.setUTCHours(e[3],e[4],e[5],e[6])):(c.setFullYear(e[0],e[1],e[2]),c.setHours(e[3],e[4],e[5],e[6])),a._d=c}}function y(a){var b=a._i;a._d||(a._a=[b.years||b.year||b.y,b.months||b.month||b.M,b.days||b.day||b.d,b.hours||b.hour||b.h,b.minutes||b.minute||b.m,b.seconds||b.second||b.s,b.milliseconds||b.millisecond||b.ms],x(a))}function z(a){var b=new Date;return a._useUTC?[b.getUTCFullYear(),b.getUTCMonth(),b.getUTCDate()]:[b.getFullYear(),b.getMonth(),b.getDate()]}function A(a){var b,c,d,e=p(a._l),f=""+a._i;for(d=t(a._f,e).match(T),a._a=[],b=0;b<d.length;b++)c=(u(d[b],a).exec(f)||[])[0],c&&(f=f.slice(f.indexOf(c)+c.length)),mb[d[b]]&&w(d[b],c,a);f&&(a._il=f),a._isPm&&a._a[3]<12&&(a._a[3]+=12),a._isPm===!1&&12===a._a[3]&&(a._a[3]=0),x(a)}function B(a){var b,c,d,f,h,i=99;for(f=0;f<a._f.length;f++)b=g({},a),b._f=a._f[f],A(b),c=new e(b),h=l(b._a,c.toArray()),c._il&&(h+=c._il.length),i>h&&(i=h,d=c);g(a,d)}function C(a){var b,c=a._i,d=cb.exec(c);if(d){for(a._f="YYYY-MM-DD"+(d[2]||" "),b=0;4>b;b++)if(eb[b][1].exec(c)){a._f+=eb[b][0];break}_.exec(c)&&(a._f+=" Z"),A(a)}else a._d=new Date(c)}function D(b){var c=b._i,d=R.exec(c);c===a?b._d=new Date:d?b._d=new Date(+d[1]):"string"==typeof c?C(b):k(c)?(b._a=c.slice(0),x(b)):c instanceof Date?b._d=new Date(+c):"object"==typeof c?y(b):b._d=new Date(c)}function E(a,b,c,d,e){return e.relativeTime(b||1,!!c,a,d)}function F(a,b,c){var d=O(Math.abs(a)/1e3),e=O(d/60),f=O(e/60),g=O(f/24),h=O(g/365),i=45>d&&["s",d]||1===e&&["m"]||45>e&&["mm",e]||1===f&&["h"]||22>f&&["hh",f]||1===g&&["d"]||25>=g&&["dd",g]||45>=g&&["M"]||345>g&&["MM",O(g/30)]||1===h&&["y"]||["yy",h];return i[2]=b,i[3]=a>0,i[4]=c,E.apply({},i)}function G(a,b,c){var d,e=c-b,f=c-a.day();return f>e&&(f-=7),e-7>f&&(f+=7),d=L(a).add("d",f),{week:Math.ceil(d.dayOfYear()/7),year:d.year()}}function H(a){var b=a._i,c=a._f;return null===b||""===b?null:("string"==typeof b&&(a._i=b=p().preparse(b)),L.isMoment(b)?(a=g({},b),a._d=new Date(+b._d)):c?k(c)?B(a):A(a):D(a),new e(a))}function I(a,b){L.fn[a]=L.fn[a+"s"]=function(a){var c=this._isUTC?"UTC":"";return null!=a?(this._d["set"+c+b](a),L.updateOffset(this),this):this._d["get"+c+b]()}}function J(a){L.duration.fn[a]=function(){return this._data[a]}}function K(a,b){L.duration.fn["as"+a]=function(){return+this/b}}for(var L,M,N="2.2.1",O=Math.round,P={},Q="undefined"!=typeof module&&module.exports,R=/^\/?Date\((\-?\d+)/i,S=/(\-)?(?:(\d*)\.)?(\d+)\:(\d+)\:(\d+)\.?(\d{3})?/,T=/(\[[^\[]*\])|(\\)?(Mo|MM?M?M?|Do|DDDo|DD?D?D?|ddd?d?|do?|w[o|w]?|W[o|W]?|YYYYY|YYYY|YY|gg(ggg?)?|GG(GGG?)?|e|E|a|A|hh?|HH?|mm?|ss?|SS?S?|X|zz?|ZZ?|.)/g,U=/(\[[^\[]*\])|(\\)?(LT|LL?L?L?|l{1,4})/g,V=/\d\d?/,W=/\d{1,3}/,X=/\d{3}/,Y=/\d{1,4}/,Z=/[+\-]?\d{1,6}/,$=/[0-9]*['a-z\u00A0-\u05FF\u0700-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+|[\u0600-\u06FF\/]+(\s*?[\u0600-\u06FF]+){1,2}/i,_=/Z|[\+\-]\d\d:?\d\d/i,ab=/T/i,bb=/[\+\-]?\d+(\.\d{1,3})?/,cb=/^\s*\d{4}-\d\d-\d\d((T| )(\d\d(:\d\d(:\d\d(\.\d\d?\d?)?)?)?)?([\+\-]\d\d:?\d\d)?)?/,db="YYYY-MM-DDTHH:mm:ssZ",eb=[["HH:mm:ss.S",/(T| )\d\d:\d\d:\d\d\.\d{1,3}/],["HH:mm:ss",/(T| )\d\d:\d\d:\d\d/],["HH:mm",/(T| )\d\d:\d\d/],["HH",/(T| )\d\d/]],fb=/([\+\-]|\d\d)/gi,gb="Date|Hours|Minutes|Seconds|Milliseconds".split("|"),hb={Milliseconds:1,Seconds:1e3,Minutes:6e4,Hours:36e5,Days:864e5,Months:2592e6,Years:31536e6},ib={ms:"millisecond",s:"second",m:"minute",h:"hour",d:"day",w:"week",W:"isoweek",M:"month",y:"year"},jb={},kb="DDD w W M D d".split(" "),lb="M D H h m s w W".split(" "),mb={M:function(){return this.month()+1},MMM:function(a){return this.lang().monthsShort(this,a)},MMMM:function(a){return this.lang().months(this,a)},D:function(){return this.date()},DDD:function(){return this.dayOfYear()},d:function(){return this.day()},dd:function(a){return this.lang().weekdaysMin(this,a)},ddd:function(a){return this.lang().weekdaysShort(this,a)},dddd:function(a){return this.lang().weekdays(this,a)},w:function(){return this.week()},W:function(){return this.isoWeek()},YY:function(){return i(this.year()%100,2)},YYYY:function(){return i(this.year(),4)},YYYYY:function(){return i(this.year(),5)},gg:function(){return i(this.weekYear()%100,2)},gggg:function(){return this.weekYear()},ggggg:function(){return i(this.weekYear(),5)},GG:function(){return i(this.isoWeekYear()%100,2)},GGGG:function(){return this.isoWeekYear()},GGGGG:function(){return i(this.isoWeekYear(),5)},e:function(){return this.weekday()},E:function(){return this.isoWeekday()},a:function(){return this.lang().meridiem(this.hours(),this.minutes(),!0)},A:function(){return this.lang().meridiem(this.hours(),this.minutes(),!1)},H:function(){return this.hours()},h:function(){return this.hours()%12||12},m:function(){return this.minutes()},s:function(){return this.seconds()},S:function(){return~~(this.milliseconds()/100)},SS:function(){return i(~~(this.milliseconds()/10),2)},SSS:function(){return i(this.milliseconds(),3)},Z:function(){var a=-this.zone(),b="+";return 0>a&&(a=-a,b="-"),b+i(~~(a/60),2)+":"+i(~~a%60,2)},ZZ:function(){var a=-this.zone(),b="+";return 0>a&&(a=-a,b="-"),b+i(~~(10*a/6),4)},z:function(){return this.zoneAbbr()},zz:function(){return this.zoneName()},X:function(){return this.unix()}};kb.length;)M=kb.pop(),mb[M+"o"]=c(mb[M],M);for(;lb.length;)M=lb.pop(),mb[M+M]=b(mb[M],2);for(mb.DDDD=b(mb.DDD,3),g(d.prototype,{set:function(a){var b,c;for(c in a)b=a[c],"function"==typeof b?this[c]=b:this["_"+c]=b},_months:"January_February_March_April_May_June_July_August_September_October_November_December".split("_"),months:function(a){return this._months[a.month()]},_monthsShort:"Jan_Feb_Mar_Apr_May_Jun_Jul_Aug_Sep_Oct_Nov_Dec".split("_"),monthsShort:function(a){return this._monthsShort[a.month()]},monthsParse:function(a){var b,c,d;for(this._monthsParse||(this._monthsParse=[]),b=0;12>b;b++)if(this._monthsParse[b]||(c=L.utc([2e3,b]),d="^"+this.months(c,"")+"|^"+this.monthsShort(c,""),this._monthsParse[b]=new RegExp(d.replace(".",""),"i")),this._monthsParse[b].test(a))return b},_weekdays:"Sunday_Monday_Tuesday_Wednesday_Thursday_Friday_Saturday".split("_"),weekdays:function(a){return this._weekdays[a.day()]},_weekdaysShort:"Sun_Mon_Tue_Wed_Thu_Fri_Sat".split("_"),weekdaysShort:function(a){return this._weekdaysShort[a.day()]},_weekdaysMin:"Su_Mo_Tu_We_Th_Fr_Sa".split("_"),weekdaysMin:function(a){return this._weekdaysMin[a.day()]},weekdaysParse:function(a){var b,c,d;for(this._weekdaysParse||(this._weekdaysParse=[]),b=0;7>b;b++)if(this._weekdaysParse[b]||(c=L([2e3,1]).day(b),d="^"+this.weekdays(c,"")+"|^"+this.weekdaysShort(c,"")+"|^"+this.weekdaysMin(c,""),this._weekdaysParse[b]=new RegExp(d.replace(".",""),"i")),this._weekdaysParse[b].test(a))return b},_longDateFormat:{LT:"h:mm A",L:"MM/DD/YYYY",LL:"MMMM D YYYY",LLL:"MMMM D YYYY LT",LLLL:"dddd, MMMM D YYYY LT"},longDateFormat:function(a){var b=this._longDateFormat[a];return!b&&this._longDateFormat[a.toUpperCase()]&&(b=this._longDateFormat[a.toUpperCase()].replace(/MMMM|MM|DD|dddd/g,function(a){return a.slice(1)}),this._longDateFormat[a]=b),b},isPM:function(a){return"p"===(a+"").toLowerCase().charAt(0)},_meridiemParse:/[ap]\.?m?\.?/i,meridiem:function(a,b,c){return a>11?c?"pm":"PM":c?"am":"AM"},_calendar:{sameDay:"[Today at] LT",nextDay:"[Tomorrow at] LT",nextWeek:"dddd [at] LT",lastDay:"[Yesterday at] LT",lastWeek:"[Last] dddd [at] LT",sameElse:"L"},calendar:function(a,b){var c=this._calendar[a];return"function"==typeof c?c.apply(b):c},_relativeTime:{future:"in %s",past:"%s ago",s:"a few seconds",m:"a minute",mm:"%d minutes",h:"an hour",hh:"%d hours",d:"a day",dd:"%d days",M:"a month",MM:"%d months",y:"a year",yy:"%d years"},relativeTime:function(a,b,c,d){var e=this._relativeTime[c];return"function"==typeof e?e(a,b,c,d):e.replace(/%d/i,a)},pastFuture:function(a,b){var c=this._relativeTime[a>0?"future":"past"];return"function"==typeof c?c(b):c.replace(/%s/i,b)},ordinal:function(a){return this._ordinal.replace("%d",a)},_ordinal:"%d",preparse:function(a){return a},postformat:function(a){return a},week:function(a){return G(a,this._week.dow,this._week.doy).week},_week:{dow:0,doy:6}}),L=function(a,b,c){return H({_i:a,_f:b,_l:c,_isUTC:!1})},L.utc=function(a,b,c){return H({_useUTC:!0,_isUTC:!0,_l:c,_i:a,_f:b}).utc()},L.unix=function(a){return L(1e3*a)},L.duration=function(a,b){var c,d,e=L.isDuration(a),g="number"==typeof a,h=e?a._input:g?{}:a,i=S.exec(a);return g?b?h[b]=a:h.milliseconds=a:i&&(c="-"===i[1]?-1:1,h={y:0,d:~~i[2]*c,h:~~i[3]*c,m:~~i[4]*c,s:~~i[5]*c,ms:~~i[6]*c}),d=new f(h),e&&a.hasOwnProperty("_lang")&&(d._lang=a._lang),d},L.version=N,L.defaultFormat=db,L.updateOffset=function(){},L.lang=function(a,b){return a?(a=a.toLowerCase(),a=a.replace("_","-"),b?n(a,b):null===b?(o(a),a="en"):P[a]||p(a),L.duration.fn._lang=L.fn._lang=p(a),void 0):L.fn._lang._abbr},L.langData=function(a){return a&&a._lang&&a._lang._abbr&&(a=a._lang._abbr),p(a)},L.isMoment=function(a){return a instanceof e},L.isDuration=function(a){return a instanceof f},g(L.fn=e.prototype,{clone:function(){return L(this)},valueOf:function(){return+this._d+6e4*(this._offset||0)},unix:function(){return Math.floor(+this/1e3)},toString:function(){return this.format("ddd MMM DD YYYY HH:mm:ss [GMT]ZZ")},toDate:function(){return this._offset?new Date(+this):this._d},toISOString:function(){return s(L(this).utc(),"YYYY-MM-DD[T]HH:mm:ss.SSS[Z]")},toArray:function(){var a=this;return[a.year(),a.month(),a.date(),a.hours(),a.minutes(),a.seconds(),a.milliseconds()]},isValid:function(){return null==this._isValid&&(this._isValid=this._a?!l(this._a,(this._isUTC?L.utc(this._a):L(this._a)).toArray()):!isNaN(this._d.getTime())),!!this._isValid},invalidAt:function(){var a,b=this._a,c=(this._isUTC?L.utc(this._a):L(this._a)).toArray();for(a=6;a>=0&&b[a]===c[a];--a);return a},utc:function(){return this.zone(0)},local:function(){return this.zone(0),this._isUTC=!1,this},format:function(a){var b=s(this,a||L.defaultFormat);return this.lang().postformat(b)},add:function(a,b){var c;return c="string"==typeof a?L.duration(+b,a):L.duration(a,b),j(this,c,1),this},subtract:function(a,b){var c;return c="string"==typeof a?L.duration(+b,a):L.duration(a,b),j(this,c,-1),this},diff:function(a,b,c){var d,e,f=this._isUTC?L(a).zone(this._offset||0):L(a).local(),g=6e4*(this.zone()-f.zone());return b=m(b),"year"===b||"month"===b?(d=432e5*(this.daysInMonth()+f.daysInMonth()),e=12*(this.year()-f.year())+(this.month()-f.month()),e+=(this-L(this).startOf("month")-(f-L(f).startOf("month")))/d,e-=6e4*(this.zone()-L(this).startOf("month").zone()-(f.zone()-L(f).startOf("month").zone()))/d,"year"===b&&(e/=12)):(d=this-f,e="second"===b?d/1e3:"minute"===b?d/6e4:"hour"===b?d/36e5:"day"===b?(d-g)/864e5:"week"===b?(d-g)/6048e5:d),c?e:h(e)},from:function(a,b){return L.duration(this.diff(a)).lang(this.lang()._abbr).humanize(!b)},fromNow:function(a){return this.from(L(),a)},calendar:function(){var a=this.diff(L().zone(this.zone()).startOf("day"),"days",!0),b=-6>a?"sameElse":-1>a?"lastWeek":0>a?"lastDay":1>a?"sameDay":2>a?"nextDay":7>a?"nextWeek":"sameElse";return this.format(this.lang().calendar(b,this))},isLeapYear:function(){var a=this.year();return 0===a%4&&0!==a%100||0===a%400},isDST:function(){return this.zone()<this.clone().month(0).zone()||this.zone()<this.clone().month(5).zone()},day:function(a){var b=this._isUTC?this._d.getUTCDay():this._d.getDay();return null!=a?"string"==typeof a&&(a=this.lang().weekdaysParse(a),"number"!=typeof a)?this:this.add({d:a-b}):b},month:function(a){var b,c=this._isUTC?"UTC":"";return null!=a?"string"==typeof a&&(a=this.lang().monthsParse(a),"number"!=typeof a)?this:(b=this.date(),this.date(1),this._d["set"+c+"Month"](a),this.date(Math.min(b,this.daysInMonth())),L.updateOffset(this),this):this._d["get"+c+"Month"]()},startOf:function(a){switch(a=m(a)){case"year":this.month(0);case"month":this.date(1);case"week":case"isoweek":case"day":this.hours(0);case"hour":this.minutes(0);case"minute":this.seconds(0);case"second":this.milliseconds(0)}return"week"===a?this.weekday(0):"isoweek"===a&&this.isoWeekday(1),this},endOf:function(a){return a=m(a),this.startOf(a).add("isoweek"===a?"week":a,1).subtract("ms",1)},isAfter:function(a,b){return b="undefined"!=typeof b?b:"millisecond",+this.clone().startOf(b)>+L(a).startOf(b)},isBefore:function(a,b){return b="undefined"!=typeof b?b:"millisecond",+this.clone().startOf(b)<+L(a).startOf(b)},isSame:function(a,b){return b="undefined"!=typeof b?b:"millisecond",+this.clone().startOf(b)===+L(a).startOf(b)},min:function(a){return a=L.apply(null,arguments),this>a?this:a},max:function(a){return a=L.apply(null,arguments),a>this?this:a},zone:function(a){var b=this._offset||0;return null==a?this._isUTC?b:this._d.getTimezoneOffset():("string"==typeof a&&(a=v(a)),Math.abs(a)<16&&(a=60*a),this._offset=a,this._isUTC=!0,b!==a&&j(this,L.duration(b-a,"m"),1,!0),this)},zoneAbbr:function(){return this._isUTC?"UTC":""},zoneName:function(){return this._isUTC?"Coordinated Universal Time":""},hasAlignedHourOffset:function(a){return a=a?L(a).zone():0,0===(this.zone()-a)%60},daysInMonth:function(){return L.utc([this.year(),this.month()+1,0]).date()},dayOfYear:function(a){var b=O((L(this).startOf("day")-L(this).startOf("year"))/864e5)+1;return null==a?b:this.add("d",a-b)},weekYear:function(a){var b=G(this,this.lang()._week.dow,this.lang()._week.doy).year;return null==a?b:this.add("y",a-b)},isoWeekYear:function(a){var b=G(this,1,4).year;return null==a?b:this.add("y",a-b)},week:function(a){var b=this.lang().week(this);return null==a?b:this.add("d",7*(a-b))},isoWeek:function(a){var b=G(this,1,4).week;return null==a?b:this.add("d",7*(a-b))},weekday:function(a){var b=(this._d.getDay()+7-this.lang()._week.dow)%7;return null==a?b:this.add("d",a-b)},isoWeekday:function(a){return null==a?this.day()||7:this.day(this.day()%7?a:a-7)},get:function(a){return a=m(a),this[a.toLowerCase()]()},set:function(a,b){a=m(a),this[a.toLowerCase()](b)},lang:function(b){return b===a?this._lang:(this._lang=p(b),this)}}),M=0;M<gb.length;M++)I(gb[M].toLowerCase().replace(/s$/,""),gb[M]);I("year","FullYear"),L.fn.days=L.fn.day,L.fn.months=L.fn.month,L.fn.weeks=L.fn.week,L.fn.isoWeeks=L.fn.isoWeek,L.fn.toJSON=L.fn.toISOString,g(L.duration.fn=f.prototype,{_bubble:function(){var a,b,c,d,e=this._milliseconds,f=this._days,g=this._months,i=this._data;i.milliseconds=e%1e3,a=h(e/1e3),i.seconds=a%60,b=h(a/60),i.minutes=b%60,c=h(b/60),i.hours=c%24,f+=h(c/24),i.days=f%30,g+=h(f/30),i.months=g%12,d=h(g/12),i.years=d},weeks:function(){return h(this.days()/7)},valueOf:function(){return this._milliseconds+864e5*this._days+2592e6*(this._months%12)+31536e6*~~(this._months/12)},humanize:function(a){var b=+this,c=F(b,!a,this.lang());return a&&(c=this.lang().pastFuture(b,c)),this.lang().postformat(c)},add:function(a,b){var c=L.duration(a,b);return this._milliseconds+=c._milliseconds,this._days+=c._days,this._months+=c._months,this._bubble(),this},subtract:function(a,b){var c=L.duration(a,b);return this._milliseconds-=c._milliseconds,this._days-=c._days,this._months-=c._months,this._bubble(),this},get:function(a){return a=m(a),this[a.toLowerCase()+"s"]()},as:function(a){return a=m(a),this["as"+a.charAt(0).toUpperCase()+a.slice(1)+"s"]()},lang:L.fn.lang});for(M in hb)hb.hasOwnProperty(M)&&(K(M,hb[M]),J(M.toLowerCase()));K("Weeks",6048e5),L.duration.fn.asMonths=function(){return(+this-31536e6*this.years())/2592e6+12*this.years()},L.lang("en",{ordinal:function(a){var b=a%10,c=1===~~(a%100/10)?"th":1===b?"st":2===b?"nd":3===b?"rd":"th";return a+c}}),Q&&(module.exports=L),"undefined"==typeof ender&&(this.moment=L),"function"==typeof define&&define.amd&&define("moment",[],function(){return L})}).call(this);
// Livestamp.js / v1.1.2 / (c) 2012 Matt Bradley / MIT License
(function(d,g){var h=1E3,i=!1,e=d([]),j=function(b,a){var c=b.data("livestampdata");"number"==typeof a&&(a*=1E3);b.removeAttr("data-livestamp").removeData("livestamp");a=g(a);g.isMoment(a)&&!isNaN(+a)&&(c=d.extend({},{original:b.contents()},c),c.moment=g(a),b.data("livestampdata",c).empty(),e.push(b[0]))},k=function(){i||(f.update(),setTimeout(k,h))},f={update:function(){d("[data-livestamp]").each(function(){var a=d(this);j(a,a.data("livestamp"))});var b=[];e.each(function(){var a=d(this),c=a.data("livestampdata");
  if(void 0===c)b.push(this);else if(g.isMoment(c.moment)){var e=a.html(),c=c.moment.fromNow();if(e!=c){var f=d.Event("change.livestamp");a.trigger(f,[e,c]);f.isDefaultPrevented()||a.html(c)}}});e=e.not(b)},pause:function(){i=!0},resume:function(){i=!1;k()},interval:function(b){if(void 0===b)return h;h=b}},l={add:function(b,a){"number"==typeof a&&(a*=1E3);a=g(a);g.isMoment(a)&&!isNaN(+a)&&(b.each(function(){j(d(this),a)}),f.update());return b},destroy:function(b){e=e.not(b);b.each(function(){var a=
  d(this),c=a.data("livestampdata");if(void 0===c)return b;a.html(c.original?c.original:"").removeData("livestampdata")});return b},isLivestamp:function(b){return void 0!==b.data("livestampdata")}};d.livestamp=f;d(function(){f.resume()});d.fn.livestamp=function(b,a){l[b]||(a=b,b="add");return l[b](this,a)}})(jQuery,moment);
/*!
* Parsleyjs
* Guillaume Potier - <guillaume@wisembly.com>
* Version 2.0.0 - built Sat Apr 19 2014 17:29:18
* MIT Licensed
*
*/

!(function($) {
  var ParsleyUtils = {
    // Parsley DOM-API
    // returns object from dom attributes and values
    // if attr is given, returns bool if attr present in DOM or not
    attr: function ($element, namespace, checkAttr) {
      var
        attribute,
        obj = {},
        regex = new RegExp('^' + namespace, 'i');
      if ('undefined' === typeof $element || 'undefined' === typeof $element[0])
        return {};
      for (var i in $element[0].attributes) {
        attribute = $element[0].attributes[i];
        if ('undefined' !== typeof attribute && null !== attribute && attribute.specified && regex.test(attribute.name)) {
          if ('undefined' !== typeof checkAttr && new RegExp(checkAttr + '$', 'i').test(attribute.name))
            return true;
          obj[this.camelize(attribute.name.replace(namespace, ''))] = this.deserializeValue(attribute.value);
        }
      }
      return 'undefined' === typeof checkAttr ? obj : false;
    },
    setAttr: function ($element, namespace, attr, value) {
      $element[0].setAttribute(this.dasherize(namespace + attr), String(value));
    },
    // Recursive object / array getter
    get: function (obj, path) {
      var
        i = 0,
        paths = (path || '').split('.');
      while (this.isObject(obj) || this.isArray(obj)) {
        obj = obj[paths[i++]];
        if (i === paths.length)
          return obj;
      }
      return undefined;
    },
    hash: function (length) {
      return String(Math.random()).substring(2, length ? length + 2 : 9);
    },
    /** Third party functions **/
    // Underscore isArray
    isArray: function (mixed) {
      return Object.prototype.toString.call(mixed) === '[object Array]';
    },
    // Underscore isObject
    isObject: function (mixed) {
      return mixed === Object(mixed);
    },
    // Zepto deserialize function
    deserializeValue: function (value) {
      var num;
      try {
        return value ?
          value == "true" ||
          (value == "false" ? false :
          value == "null" ? null :
          !isNaN(num = Number(value)) ? num :
          /^[\[\{]/.test(value) ? $.parseJSON(value) :
          value)
          : value;
      } catch (e) { return value; }
    },
    // Zepto camelize function
    camelize: function (str) {
      return str.replace(/-+(.)?/g, function(match, chr) {
        return chr ? chr.toUpperCase() : '';
      });
    },
    // Zepto dasherize function
    dasherize: function (str) {
      return str.replace(/::/g, '/')
        .replace(/([A-Z]+)([A-Z][a-z])/g, '$1_$2')
        .replace(/([a-z\d])([A-Z])/g, '$1_$2')
        .replace(/_/g, '-')
        .toLowerCase();
    }
  };
// All these options could be overriden and specified directly in DOM using
// `data-parsley-` default DOM-API
// eg: `inputs` can be set in DOM using `data-parsley-inputs="input, textarea"`
// eg: `data-parsley-stop-on-first-failing-constraint="false"`
  var ParsleyDefaults = {
    // ### General
    // Default data-namespace for DOM API
    namespace: 'data-parsley-',
    // Supported inputs by default
    inputs: 'input, textarea, select',
    // Excluded inputs by default
    excluded: 'input[type=button], input[type=submit], input[type=reset], input[type=hidden]',
    // Stop validating field on highest priority failing constraint
    priorityEnabled: true,
    // ### UI
    // Enable\Disable error messages
    uiEnabled: true,
    // Key events threshold before validation
    validationThreshold: 3,
    // Focused field on form validation error. 'fist'|'last'|'none'
    focus: 'first',
    // `$.Event()` that will trigger validation. eg: `keyup`, `change`..
    trigger: false,
    // Class that would be added on every failing validation Parsley field
    errorClass: 'parsley-error',
    // Same for success validation
    successClass: 'parsley-success',
    // Return the `$element` that will receive these above success or error classes
    // Could also be (and given directly from DOM) a valid selector like `'#div'`
    classHandler: function (ParsleyField) {},
    // Return the `$element` where errors will be appended
    // Could also be (and given directly from DOM) a valid selector like `'#div'`
    errorsContainer: function (ParsleyField) {},
    // ul elem that would receive errors' list
    errorsWrapper: '<ul class="parsley-errors-list"></ul>',
    // li elem that would receive error message
    errorTemplate: '<li></li>'
  };

  var ParsleyAbstract = function() {};
  ParsleyAbstract.prototype = {
    asyncSupport: false,
    actualizeOptions: function () {
      this.options = this.OptionsFactory.get(this);
      return this;
    },
    // ParsleyValidator validate proxy function . Could be replaced by third party scripts
    validateThroughValidator: function (value, constraints, priority) {
      return window.ParsleyValidator.validate.apply(window.ParsleyValidator, [value, constraints, priority]);
    },
    // Subscribe an event and a handler for a specific field or a specific form
    // If on a ParsleyForm instance, it will be attached to form instance and also
    // To every field instance for this form
    subscribe: function (name, fn) {
      $.listenTo(this, name.toLowerCase(), fn);
      return this;
    },
    // Same as subscribe above. Unsubscribe an event for field, or form + its fields
    unsubscribe: function (name) {
      $.unsubscribeTo(this, name.toLowerCase());
      return this;
    },
    // Reset UI
    reset: function () {
      // Field case: just emit a reset event for UI
      if ('ParsleyForm' !== this.__class__)
        return $.emit('parsley:field:reset', this);
      // Form case: emit a reset event for each field
      for (var i = 0; i < this.fields.length; i++)
        $.emit('parsley:field:reset', this.fields[i]);
      $.emit('parsley:form:reset', this);
    },
    // Destroy Parsley instance (+ UI)
    destroy: function () {
      // Field case: emit destroy event to clean UI and then destroy stored instance
      if ('ParsleyForm' !== this.__class__) {
        this.$element.removeData('Parsley');
        this.$element.removeData('ParsleyFieldMultiple');
        $.emit('parsley:field:destroy', this);
        return;
      }
      // Form case: destroy all its fields and then destroy stored instance
      for (var i = 0; i < this.fields.length; i++)
        this.fields[i].destroy();
      this.$element.removeData('Parsley');
      $.emit('parsley:form:destroy', this);
    }
  };
/*!
* validator.js
* Guillaume Potier - <guillaume@wisembly.com>
* Version 0.5.8 - built Sun Mar 16 2014 17:18:21
* MIT Licensed
*
*/
( function ( exports ) {
  /**
  * Validator
  */
  var Validator = function ( options ) {
    this.__class__ = 'Validator';
    this.__version__ = '0.5.8';
    this.options = options || {};
    this.bindingKey = this.options.bindingKey || '_validatorjsConstraint';
    return this;
  };
  Validator.prototype = {
    constructor: Validator,
    /*
    * Validate string: validate( string, Assert, string ) || validate( string, [ Assert, Assert ], [ string, string ] )
    * Validate object: validate( object, Constraint, string ) || validate( object, Constraint, [ string, string ] )
    * Validate binded object: validate( object, string ) || validate( object, [ string, string ] )
    */
    validate: function ( objectOrString, AssertsOrConstraintOrGroup, group ) {
      if ( 'string' !== typeof objectOrString && 'object' !== typeof objectOrString )
        throw new Error( 'You must validate an object or a string' );
      // string / array validation
      if ( 'string' === typeof objectOrString || _isArray(objectOrString) )
        return this._validateString( objectOrString, AssertsOrConstraintOrGroup, group );
      // binded object validation
      if ( this.isBinded( objectOrString ) )
        return this._validateBindedObject( objectOrString, AssertsOrConstraintOrGroup );
      // regular object validation
      return this._validateObject( objectOrString, AssertsOrConstraintOrGroup, group );
    },
    bind: function ( object, constraint ) {
      if ( 'object' !== typeof object )
        throw new Error( 'Must bind a Constraint to an object' );
      object[ this.bindingKey ] = new Constraint( constraint );
      return this;
    },
    unbind: function ( object ) {
      if ( 'undefined' === typeof object._validatorjsConstraint )
        return this;
      delete object[ this.bindingKey ];
      return this;
    },
    isBinded: function ( object ) {
      return 'undefined' !== typeof object[ this.bindingKey ];
    },
    getBinded: function ( object ) {
      return this.isBinded( object ) ? object[ this.bindingKey ] : null;
    },
    _validateString: function ( string, assert, group ) {
      var result, failures = [];
      if ( !_isArray( assert ) )
        assert = [ assert ];
      for ( var i = 0; i < assert.length; i++ ) {
        if ( ! ( assert[ i ] instanceof Assert) )
          throw new Error( 'You must give an Assert or an Asserts array to validate a string' );
        result = assert[ i ].check( string, group );
        if ( result instanceof Violation )
          failures.push( result );
      }
      return failures.length ? failures : true;
    },
    _validateObject: function ( object, constraint, group ) {
      if ( 'object' !== typeof constraint )
        throw new Error( 'You must give a constraint to validate an object' );
      if ( constraint instanceof Constraint )
        return constraint.check( object, group );
      return new Constraint( constraint ).check( object, group );
    },
    _validateBindedObject: function ( object, group ) {
      return object[ this.bindingKey ].check( object, group );
    }
  };
  Validator.errorCode = {
    must_be_a_string: 'must_be_a_string',
    must_be_an_array: 'must_be_an_array',
    must_be_a_number: 'must_be_a_number',
    must_be_a_string_or_array: 'must_be_a_string_or_array'
  };
  /**
  * Constraint
  */
  var Constraint = function ( data, options ) {
    this.__class__ = 'Constraint';
    this.options = options || {};
    this.nodes = {};
    if ( data ) {
      try {
        this._bootstrap( data );
      } catch ( err ) {
        throw new Error( 'Should give a valid mapping object to Constraint', err, data );
      }
    }
    return this;
  };
  Constraint.prototype = {
    constructor: Constraint,
    check: function ( object, group ) {
      var result, failures = {};
      // check all constraint nodes if strict validation enabled. Else, only object nodes that have a constraint
      for ( var property in this.options.strict ? this.nodes : object ) {
        if ( this.options.strict ? this.has( property, object ) : this.has( property ) ) {
          result = this._check( property, object[ property ], group );
          // check returned an array of Violations or an object mapping Violations
          if ( ( _isArray( result ) && result.length > 0 ) || ( !_isArray( result ) && !_isEmptyObject( result ) ) )
            failures[ property ] = result;
        // in strict mode, get a violation for each constraint node not in object
        } else if ( this.options.strict ) {
          try {
            // we trigger here a HaveProperty Assert violation to have uniform Violation object in the end
            new Assert().HaveProperty( property ).validate( object );
          } catch ( violation ) {
            failures[ property ] = violation;
          }
        }
      }
      return _isEmptyObject(failures) ? true : failures;
    },
    add: function ( node, object ) {
      if ( object instanceof Assert  || ( _isArray( object ) && object[ 0 ] instanceof Assert ) ) {
        this.nodes[ node ] = object;
        return this;
      }
      if ( 'object' === typeof object && !_isArray( object ) ) {
        this.nodes[ node ] = object instanceof Constraint ? object : new Constraint( object );
        return this;
      }
      throw new Error( 'Should give an Assert, an Asserts array, a Constraint', object );
    },
    has: function ( node, nodes ) {
      nodes = 'undefined' !== typeof nodes ? nodes : this.nodes;
      return 'undefined' !== typeof nodes[ node ];
    },
    get: function ( node, placeholder ) {
      return this.has( node ) ? this.nodes[ node ] : placeholder || null;
    },
    remove: function ( node ) {
      var _nodes = [];
      for ( var i in this.nodes )
        if ( i !== node )
          _nodes[ i ] = this.nodes[ i ];
      this.nodes = _nodes;
      return this;
    },
    _bootstrap: function ( data ) {
      if ( data instanceof Constraint )
        return this.nodes = data.nodes;
      for ( var node in data )
        this.add( node, data[ node ] );
    },
    _check: function ( node, value, group ) {
      // Assert
      if ( this.nodes[ node ] instanceof Assert )
        return this._checkAsserts( value, [ this.nodes[ node ] ], group );
      // Asserts
      if ( _isArray( this.nodes[ node ] ) )
        return this._checkAsserts( value, this.nodes[ node ], group );
      // Constraint -> check api
      if ( this.nodes[ node ] instanceof Constraint )
        return this.nodes[ node ].check( value, group );
      throw new Error( 'Invalid node', this.nodes[ node ] );
    },
    _checkAsserts: function ( value, asserts, group ) {
      var result, failures = [];
      for ( var i = 0; i < asserts.length; i++ ) {
        result = asserts[ i ].check( value, group );
        if ( 'undefined' !== typeof result && true !== result )
          failures.push( result );
        // Some asserts (Collection for example) could return an object
        // if ( result && ! ( result instanceof Violation ) )
        //   return result;
        //
        // // Vast assert majority return Violation
        // if ( result instanceof Violation )
        //   failures.push( result );
      }
      return failures;
    }
  };
  /**
  * Violation
  */
  var Violation = function ( assert, value, violation ) {
    this.__class__ = 'Violation';
    if ( ! ( assert instanceof Assert ) )
      throw new Error( 'Should give an assertion implementing the Assert interface' );
    this.assert = assert;
    this.value = value;
    if ( 'undefined' !== typeof violation )
      this.violation = violation;
  };
  Violation.prototype = {
    show: function () {
      var show =  {
        assert: this.assert.__class__,
        value: this.value
      };
      if ( this.violation )
        show.violation = this.violation;
      return show;
    },
    __toString: function () {
      if ( 'undefined' !== typeof this.violation )
        this.violation = '", ' + this.getViolation().constraint + ' expected was ' + this.getViolation().expected;
      return this.assert.__class__ + ' assert failed for "' + this.value + this.violation || '';
    },
    getViolation: function () {
      var constraint, expected;
      for ( constraint in this.violation )
        expected = this.violation[ constraint ];
      return { constraint: constraint, expected: expected };
    }
  };
  /**
  * Assert
  */
  var Assert = function ( group ) {
    this.__class__ = 'Assert';
    this.__parentClass__ = this.__class__;
    this.groups = [];
    if ( 'undefined' !== typeof group )
      this.addGroup( group );
    return this;
  };
  Assert.prototype = {
    construct: Assert,
    check: function ( value, group ) {
      if ( group && !this.hasGroup( group ) )
        return;
      if ( !group && this.hasGroups() )
        return;
      try {
        return this.validate( value, group );
      } catch ( violation ) {
        return violation;
      }
    },
    hasGroup: function ( group ) {
      if ( _isArray( group ) )
        return this.hasOneOf( group );
      // All Asserts respond to "Any" group
      if ( 'Any' === group )
        return true;
      // Asserts with no group also respond to "Default" group. Else return false
      if ( !this.hasGroups() )
        return 'Default' === group;
      return -1 !== this.groups.indexOf( group );
    },
    hasOneOf: function ( groups ) {
      for ( var i = 0; i < groups.length; i++ )
        if ( this.hasGroup( groups[ i ] ) )
          return true;
      return false;
    },
    hasGroups: function () {
      return this.groups.length > 0;
    },
    addGroup: function ( group ) {
      if ( _isArray( group ) )
        return this.addGroups( group );
      if ( !this.hasGroup( group ) )
        this.groups.push( group );
      return this;
    },
    removeGroup: function ( group ) {
      var _groups = [];
      for ( var i = 0; i < this.groups.length; i++ )
        if ( group !== this.groups[ i ] )
          _groups.push( this.groups[ i ] );
      this.groups = _groups;
      return this;
    },
    addGroups: function ( groups ) {
      for ( var i = 0; i < groups.length; i++ )
        this.addGroup( groups[ i ] );
      return this;
    },
    /**
    * Asserts definitions
    */
    HaveProperty: function ( node ) {
      this.__class__ = 'HaveProperty';
      this.node = node;
      this.validate = function ( object ) {
        if ( 'undefined' === typeof object[ this.node ] )
          throw new Violation( this, object, { value: this.node } );
        return true;
      };
      return this;
    },
    Blank: function () {
      this.__class__ = 'Blank';
      this.validate = function ( value ) {
        if ( 'string' !== typeof value )
          throw new Violation( this, value, { value: Validator.errorCode.must_be_a_string } );
        if ( '' !== value.replace( /^\s+/g, '' ).replace( /\s+$/g, '' ) )
          throw new Violation( this, value );
        return true;
      };
      return this;
    },
    Callback: function ( fn ) {
      this.__class__ = 'Callback';
      this.arguments = Array.prototype.slice.call( arguments );
      if ( 1 === this.arguments.length )
        this.arguments = [];
      else
        this.arguments.splice( 0, 1 );
      if ( 'function' !== typeof fn )
        throw new Error( 'Callback must be instanciated with a function' );
      this.fn = fn;
      this.validate = function ( value ) {
        var result = this.fn.apply( this, [ value ].concat( this.arguments ) );
        if ( true !== result )
          throw new Violation( this, value, { result: result } );
        return true;
      };
      return this;
    },
    Choice: function ( list ) {
      this.__class__ = 'Choice';
      if ( !_isArray( list ) && 'function' !== typeof list )
        throw new Error( 'Choice must be instanciated with an array or a function' );
      this.list = list;
      this.validate = function ( value ) {
        var list = 'function' === typeof this.list ? this.list() : this.list;
        for ( var i = 0; i < list.length; i++ )
          if ( value === list[ i ] )
            return true;
        throw new Violation( this, value, { choices: list } );
      };
      return this;
    },
    Collection: function ( constraint ) {
      this.__class__ = 'Collection';
      this.constraint = 'undefined' !== typeof constraint ? new Constraint( constraint ) : false;
      this.validate = function ( collection, group ) {
        var result, validator = new Validator(), count = 0, failures = {}, groups = this.groups.length ? this.groups : group;
        if ( !_isArray( collection ) )
          throw new Violation( this, array, { value: Validator.errorCode.must_be_an_array } );
        for ( var i = 0; i < collection.length; i++ ) {
          result = this.constraint ?
            validator.validate( collection[ i ], this.constraint, groups ) :
            validator.validate( collection[ i ], groups );
          if ( !_isEmptyObject( result ) )
            failures[ count ] = result;
          count++;
        }
        return !_isEmptyObject( failures ) ? failures : true;
      };
      return this;
    },
    Count: function ( count ) {
      this.__class__ = 'Count';
      this.count = count;
      this.validate = function ( array ) {
        if ( !_isArray( array ) )
          throw new Violation( this, array, { value: Validator.errorCode.must_be_an_array } );
        var count = 'function' === typeof this.count ? this.count( array ) : this.count;
        if ( isNaN( Number( count ) ) )
          throw new Error( 'Count must be a valid interger', count );
        if ( count !== array.length )
          throw new Violation( this, array, { count: count } );
        return true;
      };
      return this;
    },
    Email: function () {
      this.__class__ = 'Email';
      this.validate = function ( value ) {
        var regExp = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i;
        if ( 'string' !== typeof value )
          throw new Violation( this, value, { value: Validator.errorCode.must_be_a_string } );
        if ( !regExp.test( value ) )
          throw new Violation( this, value );
        return true;
      };
      return this;
    },
    Eql: function ( eql ) {
      this.__class__ = 'Eql';
      if ( 'undefined' === typeof eql )
        throw new Error( 'Equal must be instanciated with an Array or an Object' );
      this.eql = eql;
      this.validate = function ( value ) {
        var eql = 'function' === typeof this.eql ? this.eql( value ) : this.eql;
        if ( !expect.eql( eql, value ) )
          throw new Violation( this, value, { eql: eql } );
        return true;
      };
      return this;
    },
    EqualTo: function ( reference ) {
      this.__class__ = 'EqualTo';
      if ( 'undefined' === typeof reference )
        throw new Error( 'EqualTo must be instanciated with a value or a function' );
      this.reference = reference;
      this.validate = function ( value ) {
        var reference = 'function' === typeof this.reference ? this.reference( value ) : this.reference;
        if ( reference !== value )
          throw new Violation( this, value, { value: reference } );
        return true;
      };
      return this;
    },
    GreaterThan: function ( threshold ) {
      this.__class__ = 'GreaterThan';
      if ( 'undefined' === typeof threshold )
        throw new Error( 'Should give a threshold value' );
      this.threshold = threshold;
      this.validate = function ( value ) {
        if ( '' === value || isNaN( Number( value ) ) )
          throw new Violation( this, value, { value: Validator.errorCode.must_be_a_number } );
        if ( this.threshold >= value )
          throw new Violation( this, value, { threshold: this.threshold } );
        return true;
      };
      return this;
    },
    GreaterThanOrEqual: function ( threshold ) {
      this.__class__ = 'GreaterThanOrEqual';
      if ( 'undefined' === typeof threshold )
        throw new Error( 'Should give a threshold value' );
      this.threshold = threshold;
      this.validate = function ( value ) {
        if ( '' === value || isNaN( Number( value ) ) )
          throw new Violation( this, value, { value: Validator.errorCode.must_be_a_number } );
        if ( this.threshold > value )
          throw new Violation( this, value, { threshold: this.threshold } );
        return true;
      };
      return this;
    },
    InstanceOf: function ( classRef ) {
      this.__class__ = 'InstanceOf';
      if ( 'undefined' === typeof classRef )
        throw new Error( 'InstanceOf must be instanciated with a value' );
      this.classRef = classRef;
      this.validate = function ( value ) {
        if ( true !== (value instanceof this.classRef) )
          throw new Violation( this, value, { classRef: this.classRef } );
        return true;
      };
      return this;
    },
    IPv4: function () {
      this.__class__ = 'IPv4';
      this.validate = function ( value ) {
        var regExp = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
        if ( 'string' !== typeof value )
          throw new Violation( this, value, { value: Validator.errorCode.must_be_a_string } );
        if ( !regExp.test( value ) )
          throw new Violation( this, value );
        return true;
      };
      return this;
    },
    Length: function ( boundaries ) {
      this.__class__ = 'Length';
      if ( !boundaries.min && !boundaries.max )
        throw new Error( 'Lenth assert must be instanciated with a { min: x, max: y } object' );
      this.min = boundaries.min;
      this.max = boundaries.max;
      this.validate = function ( value ) {
        if ( 'string' !== typeof value && !_isArray( value ) )
          throw new Violation( this, value, { value: Validator.errorCode.must_be_a_string_or_array } );
        if ( 'undefined' !== typeof this.min && this.min === this.max && value.length !== this.min )
          throw new Violation( this, value, { min: this.min, max: this.max } );
        if ( 'undefined' !== typeof this.max && value.length > this.max )
          throw new Violation( this, value, { max: this.max } );
        if ( 'undefined' !== typeof this.min && value.length < this.min )
          throw new Violation( this, value, { min: this.min } );
        return true;
      };
      return this;
    },
    LessThan: function ( threshold ) {
      this.__class__ = 'LessThan';
      if ( 'undefined' === typeof threshold )
        throw new Error( 'Should give a threshold value' );
      this.threshold = threshold;
      this.validate = function ( value ) {
        if ( '' === value || isNaN( Number( value ) ) )
          throw new Violation( this, value, { value: Validator.errorCode.must_be_a_number } );
        if ( this.threshold <= value )
          throw new Violation( this, value, { threshold: this.threshold } );
        return true;
      };
      return this;
    },
    LessThanOrEqual: function ( threshold ) {
      this.__class__ = 'LessThanOrEqual';
      if ( 'undefined' === typeof threshold )
        throw new Error( 'Should give a threshold value' );
      this.threshold = threshold;
      this.validate = function ( value ) {
        if ( '' === value || isNaN( Number( value ) ) )
          throw new Violation( this, value, { value: Validator.errorCode.must_be_a_number } );
        if ( this.threshold < value )
          throw new Violation( this, value, { threshold: this.threshold } );
        return true;
      };
      return this;
    },
    Mac: function () {
      this.__class__ = 'Mac';
      this.validate = function ( value ) {
        var regExp = /^(?:[0-9A-F]{2}:){5}[0-9A-F]{2}$/i;
        if ( 'string' !== typeof value )
          throw new Violation( this, value, { value: Validator.errorCode.must_be_a_string } );
        if ( !regExp.test( value ) )
          throw new Violation( this, value );
        return true;
      };
      return this;
    },
    NotNull: function () {
      this.__class__ = 'NotNull';
      this.validate = function ( value ) {
        if ( null === value || 'undefined' === typeof value )
          throw new Violation( this, value );
        return true;
      };
      return this;
    },
    NotBlank: function () {
      this.__class__ = 'NotBlank';
      this.validate = function ( value ) {
        if ( 'string' !== typeof value )
          throw new Violation( this, value, { value: Validator.errorCode.must_be_a_string } );
        if ( '' === value.replace( /^\s+/g, '' ).replace( /\s+$/g, '' ) )
          throw new Violation( this, value );
        return true;
      };
      return this;
    },
    Null: function () {
      this.__class__ = 'Null';
      this.validate = function ( value ) {
        if ( null !== value )
          throw new Violation( this, value );
        return true;
      };
      return this;
    },
    Range: function ( min, max ) {
      this.__class__ = 'Range';
      if ( 'undefined' === typeof min || 'undefined' === typeof max )
        throw new Error( 'Range assert expects min and max values' );
      this.min = min;
      this.max = max;
      this.validate = function ( value ) {
          try {
            // validate strings and objects with their Length
            if ( ( 'string' === typeof value && isNaN( Number( value ) ) ) || _isArray( value ) )
              new Assert().Length( { min: this.min, max: this.max } ).validate( value );
            // validate numbers with their value
            else
              new Assert().GreaterThanOrEqual( this.min ).validate( value ) && new Assert().LessThanOrEqual( this.max ).validate( value );
            return true;
          } catch ( violation ) {
            throw new Violation( this, value, violation.violation );
          }
        return true;
      };
      return this;
    },
    Regexp: function ( regexp, flag ) {
      this.__class__ = 'Regexp';
      if ( 'undefined' === typeof regexp )
        throw new Error( 'You must give a regexp' );
      this.regexp = regexp;
      this.flag = flag || '';
      this.validate = function ( value ) {
        if ( 'string' !== typeof value )
          throw new Violation( this, value, { value: Validator.errorCode.must_be_a_string } );
        if ( !new RegExp( this.regexp, this.flag ).test( value ) )
          throw new Violation( this, value, { regexp: this.regexp, flag: this.flag } );
        return true;
      };
      return this;
    },
    Required: function () {
      this.__class__ = 'Required';
      this.validate = function ( value ) {
        if ( 'undefined' === typeof value )
          throw new Violation( this, value );
        try {
          if ( 'string' === typeof value )
            new Assert().NotNull().validate( value ) && new Assert().NotBlank().validate( value );
          else if ( true === _isArray( value ) )
            new Assert().Length( { min: 1 } ).validate( value );
        } catch ( violation ) {
          throw new Violation( this, value );
        }
        return true;
      };
      return this;
    },
    // Unique() or Unique ( { key: foo } )
    Unique: function ( object ) {
      this.__class__ = 'Unique';
      if ( 'object' === typeof object )
        this.key = object.key;
      this.validate = function ( array ) {
        var value, store = [];
        if ( !_isArray( array ) )
          throw new Violation( this, array, { value: Validator.errorCode.must_be_an_array } );
        for ( var i = 0; i < array.length; i++ ) {
          value = 'object' === typeof array[ i ] ? array[ i ][ this.key ] : array[ i ];
          if ( 'undefined' === typeof value )
            continue;
          if ( -1 !== store.indexOf( value ) )
            throw new Violation( this, array, { value: value } );
          store.push( value );
        }
        return true;
      };
      return this;
    }
  };
  // expose to the world these awesome classes
  exports.Assert = Assert;
  exports.Validator = Validator;
  exports.Violation = Violation;
  exports.Constraint = Constraint;
  /**
  * Some useful object prototypes / functions here
  */
  // IE8<= compatibility
  // https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Array/indexOf
  if (!Array.prototype.indexOf)
    Array.prototype.indexOf = function (searchElement /*, fromIndex */ ) {
        
        if (this === null) {
            throw new TypeError();
        }
        var t = Object(this);
        var len = t.length >>> 0;
        if (len === 0) {
            return -1;
        }
        var n = 0;
        if (arguments.length > 1) {
            n = Number(arguments[1]);
            if (n != n) { // shortcut for verifying if it's NaN
                n = 0;
            } else if (n !== 0 && n != Infinity && n != -Infinity) {
                n = (n > 0 || -1) * Math.floor(Math.abs(n));
            }
        }
        if (n >= len) {
            return -1;
        }
        var k = n >= 0 ? n : Math.max(len - Math.abs(n), 0);
        for (; k < len; k++) {
            if (k in t && t[k] === searchElement) {
                return k;
            }
        }
        return -1;
    };
  // Test if object is empty, useful for Constraint violations check
  var _isEmptyObject = function ( obj ) {
    for ( var property in obj )
      return false;
    return true;
  };
  var _isArray = function ( obj ) {
    return Object.prototype.toString.call( obj ) === '[object Array]';
  };
  // https://github.com/LearnBoost/expect.js/blob/master/expect.js
  var expect = {
    eql: function ( actual, expected ) {
      if ( actual === expected ) {
        return true;
      } else if ( 'undefined' !== typeof Buffer && Buffer.isBuffer( actual ) && Buffer.isBuffer( expected ) ) {
        if ( actual.length !== expected.length ) return false;
        for ( var i = 0; i < actual.length; i++ )
          if ( actual[i] !== expected[i] ) return false;
        return true;
      } else if ( actual instanceof Date && expected instanceof Date ) {
        return actual.getTime() === expected.getTime();
      } else if ( typeof actual !== 'object' && typeof expected !== 'object' ) {
        // loosy ==
        return actual == expected;
      } else {
        return this.objEquiv(actual, expected);
      }
    },
    isUndefinedOrNull: function ( value ) {
      return value === null || typeof value === 'undefined';
    },
    isArguments: function ( object ) {
      return Object.prototype.toString.call(object) == '[object Arguments]';
    },
    keys: function ( obj ) {
      if ( Object.keys )
        return Object.keys( obj );
      var keys = [];
      for ( var i in obj )
        if ( Object.prototype.hasOwnProperty.call( obj, i ) )
          keys.push(i);
      return keys;
    },
    objEquiv: function ( a, b ) {
      if ( this.isUndefinedOrNull( a ) || this.isUndefinedOrNull( b ) )
        return false;
      if ( a.prototype !== b.prototype ) return false;
      if ( this.isArguments( a ) ) {
        if ( !this.isArguments( b ) )
          return false;
        return eql( pSlice.call( a ) , pSlice.call( b ) );
      }
      try {
        var ka = this.keys( a ), kb = this.keys( b ), key, i;
        if ( ka.length !== kb.length )
          return false;
        ka.sort();
        kb.sort();
        for ( i = ka.length - 1; i >= 0; i-- )
          if ( ka[ i ] != kb[ i ] )
            return false;
        for ( i = ka.length - 1; i >= 0; i-- ) {
          key = ka[i];
          if ( !this.eql( a[ key ], b[ key ] ) )
             return false;
        }
        return true;
      } catch ( e ) {
        return false;
      }
    }
  };
  // AMD Compliance
  if ( "function" === typeof define && define.amd ) {
    define( 'validator', [],function() { return exports; } );
  }
} )( 'undefined' === typeof exports ? this[ 'undefined' !== typeof validatorjs_ns ? validatorjs_ns : 'Validator' ] = {} : exports );


  var ParsleyValidator = function (validators, catalog) {
    this.__class__ = 'ParsleyValidator';
    this.Validator = Validator;
    // Default Parsley locale is en
    this.locale = 'en';
    this.init(validators || {}, catalog || {});
  };
  ParsleyValidator.prototype = {
    init: function (validators, catalog) {
      this.catalog = catalog;
      for (var name in validators)
        this.addValidator(name, validators[name].fn, validators[name].priority);
      $.emit('parsley:validator:init');
    },
    // Set new messages locale if we have dictionary loaded in ParsleyConfig.i18n
    setLocale: function (locale) {
      if ('undefined' === typeof this.catalog[locale])
        throw new Error(locale + ' is not available in the catalog');
      this.locale = locale;
      return this;
    },
    // Add a new messages catalog for a given locale. Set locale for this catalog if set === `true`
    addCatalog: function (locale, messages, set) {
      if ('object' === typeof messages)
        this.catalog[locale] = messages;
      if (true === set)
        return this.setLocale(locale);
      return this;
    },
    // Add a specific message for a given constraint in a given locale
    addMessage: function (locale, name, message) {
      if (undefined === typeof this.catalog[locale])
        this.catalog[locale] = {};
      this.catalog[locale][name.toLowerCase()] = message;
      return this;
    },
    validate: function (value, constraints, priority) {
      return new this.Validator.Validator().validate.apply(new Validator.Validator(), arguments);
    },
    // Add a new validator
    addValidator: function (name, fn, priority) {
      this.validators[name.toLowerCase()] = function (requirements) {
        return $.extend(new Validator.Assert().Callback(fn, requirements), { priority: priority });
      };
      return this;
    },
    updateValidator: function (name, fn, priority) {
      return addValidator(name, fn, priority);
    },
    removeValidator: function (name) {
      delete this.validators[name];
      return this;
    },
    getErrorMessage: function (constraint) {
      var message;
      // Type constraints are a bit different, we have to match their requirements too to find right error message
      if ('type' === constraint.name)
        message = this.catalog[this.locale][constraint.name][constraint.requirements];
      else
        message = this.formatMessage(this.catalog[this.locale][constraint.name], constraint.requirements);
      return '' !== message ? message : this.catalog[this.locale].defaultMessage;
    },
    // Kind of light `sprintf()` implementation
    formatMessage: function (string, parameters) {
      if ('object' === typeof parameters) {
        for (var i in parameters)
          string = this.formatMessage(string, parameters[i]);
        return string;
      }
      return 'string' === typeof string ? string.replace(new RegExp('%s', 'i'), parameters) : '';
    },
    // Here is the Parsley default validators list.
    // This is basically Validatorjs validators, with different API for some of them
    // and a Parsley priority set
    validators: {
      notblank: function () {
        return $.extend(new Validator.Assert().NotBlank(), { priority: 2 });
      },
      required: function () {
        return $.extend(new Validator.Assert().Required(), { priority: 512 });
      },
      type: function (type) {
        var assert;
        switch (type) {
          case 'email':
            assert = new Validator.Assert().Email();
            break;
          case 'number':
            assert = new Validator.Assert().Regexp('^-?(?:\\d+|\\d{1,3}(?:,\\d{3})+)?(?:\\.\\d+)?$');
            break;
          case 'integer':
            assert = new Validator.Assert().Regexp('^-?\\d+$');
            break;
          case 'digits':
            assert = new Validator.Assert().Regexp('^\\d+$');
            break;
          case 'alphanum':
            assert = new Validator.Assert().Regexp('^\\w+$', 'i');
            break;
          case 'url':
            assert = new Validator.Assert().Regexp('(https?:\\/\\/)?(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,4}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)', 'i');
            break;
          default:
            throw new Error('validator type `' + type + '` is not supported');
        }
        return $.extend(assert, { priority: 256 });
      },
      pattern: function (regexp) {
        var flags = '';
        // Test if RegExp is literal, if not, nothing to be done, otherwise, we need to isolate flags and pattern
        if (!!(/^\/.*\/(?:[gimy]*)$/.test(regexp))) {
          // Replace the regexp literal string with the first match group: ([gimy]*)
          // If no flag is present, this will be a blank string
          flags = regexp.replace(/.*\/([gimy]*)$/, '$1');
          // Again, replace the regexp literal string with the first match group:
          // everything excluding the opening and closing slashes and the flags
          regexp = regexp.replace(new RegExp('^/(.*?)/' + flags + '$'), '$1');
        }
        return $.extend(new Validator.Assert().Regexp(regexp, flags), { priority: 64 });
      },
      minlength: function (value) {
        return $.extend(new Validator.Assert().Length({ min: value }), {
          priority: 30,
          requirementsTransformer: function () {
            return 'string' === typeof value && !isNaN(value) ? parseInt(value, 10) : value;
          }
        });
      },
      maxlength: function (value) {
        return $.extend(new Validator.Assert().Length({ max: value }), {
        priority: 30,
        requirementsTransformer: function () {
            return 'string' === typeof value && !isNaN(value) ? parseInt(value, 10) : value;
          }
      });
      },
      length: function (array) {
        return $.extend(new Validator.Assert().Length({ min: array[0], max: array[1] }), { priority: 32 });
      },
      mincheck: function (length) {
        return this.minlength(length);
      },
      maxcheck: function (length) {
        return this.maxlength(length);
      },
      check: function (array) {
        return this.length(array);
      },
      min: function (value) {
        return $.extend(new Validator.Assert().GreaterThanOrEqual(value), {
          priority: 30,
          requirementsTransformer: function () {
            return 'string' === typeof value && !isNaN(value) ? parseInt(value, 10) : value;
          }
        });
      },
      max: function (value) {
        return $.extend(new Validator.Assert().LessThanOrEqual(value), {
          priority: 30,
          requirementsTransformer: function () {
            return 'string' === typeof value && !isNaN(value) ? parseInt(value, 10) : value;
          }
        });
      },
      range: function (array) {
        return $.extend(new Validator.Assert().Range(array[0], array[1]), {
          priority: 32,
          requirementsTransformer: function () {
            for (var i = 0; i < array.length; i++)
              array[i] = 'string' === typeof array[i] && !isNaN(array[i]) ? parseInt(array[i], 10) : array[i];
            return array;
          }
        });
      },
      equalto: function (value) {
        return $.extend(new Validator.Assert().EqualTo(value), {
          priority: 256,
          requirementsTransformer: function () {
            return $(value).length ? $(value).val() : value;
          }
        });
      }
    }
  };

  var ParsleyUI = function (options) {
    this.__class__ = 'ParsleyUI';
  };
  ParsleyUI.prototype = {
    listen: function () {
      $.listen('parsley:form:init', this, this.setupForm);
      $.listen('parsley:field:init', this, this.setupField);
      $.listen('parsley:field:validated', this, this.reflow);
      $.listen('parsley:form:validated', this, this.focus);
      $.listen('parsley:field:reset', this, this.reset);
      $.listen('parsley:form:destroy', this, this.destroy);
      $.listen('parsley:field:destroy', this, this.destroy);
      return this;
    },
    reflow: function (fieldInstance) {
      // If this field has not an active UI (case for multiples) don't bother doing something
      if ('undefined' === typeof fieldInstance._ui || false === fieldInstance._ui.active)
        return;
      // Diff between two validation results
      var diff = this._diff(fieldInstance.validationResult, fieldInstance._ui.lastValidationResult);
      // Then store current validation result for next reflow
      fieldInstance._ui.lastValidationResult = fieldInstance.validationResult;
      // Field have been validated at least once if here. Useful for binded key events..
      fieldInstance._ui.validatedOnce = true;
      // Handle valid / invalid / none field class
      this.manageStatusClass(fieldInstance);
      // Add, remove, updated errors messages
      this.manageErrorsMessages(fieldInstance, diff);
      // Triggers impl
      this.actualizeTriggers(fieldInstance);
      // If field is not valid for the first time, bind keyup trigger to ease UX and quickly inform user
      if ((diff.kept.length || diff.added.length) && 'undefined' === typeof fieldInstance._ui.failedOnce)
        this.manageFailingFieldTrigger(fieldInstance);
    },
    // Returns an array of field's error message(s)
    getErrorsMessages: function (fieldInstance) {
      // No error message, field is valid
      if (true === fieldInstance.validationResult)
        return [];
      var messages = [];
      for (var i = 0; i < fieldInstance.validationResult.length; i++)
        messages.push(this._getErrorMessage(fieldInstance, fieldInstance.validationResult[i].assert));
      return messages;
    },
    manageStatusClass: function (fieldInstance) {
      if (true === fieldInstance.validationResult)
        this._successClass(fieldInstance);
      else if (fieldInstance.validationResult.length > 0)
        this._errorClass(fieldInstance);
      else
        this._resetClass(fieldInstance);
    },
    manageErrorsMessages: function (fieldInstance, diff) {
      if ('undefined' !== typeof fieldInstance.options.errorsMessagesDisabled)
        return;
      // Case where we have errorMessage option that configure an unique field error message, regardless failing validators
      if ('undefined' !== typeof fieldInstance.options.errorMessage) {
        if ((diff.added.length || diff.kept.length)) {
          if (0 === fieldInstance._ui.$errorsWrapper.find('.parsley-custom-error-message').length)
            fieldInstance._ui.$errorsWrapper
              .append($(fieldInstance.options.errorTemplate)
              .addClass('parsley-custom-error-message'));
          return fieldInstance._ui.$errorsWrapper
            .addClass('filled')
            .find('.parsley-custom-error-message')
            .html(fieldInstance.options.errorMessage);
        }
        return fieldInstance._ui.$errorsWrapper
          .removeClass('filled')
          .find('.parsley-custom-error-message')
          .remove();
      }
      // Show, hide, update failing constraints messages
      for (var i = 0; i < diff.removed.length; i++)
        this.removeError(fieldInstance, diff.removed[i].assert.name, true);
      for (i = 0; i < diff.added.length; i++)
        this.addError(fieldInstance, diff.added[i].assert.name, undefined, diff.added[i].assert, true);
      for (i = 0; i < diff.kept.length; i++)
        this.updateError(fieldInstance, diff.kept[i].assert.name, undefined, diff.kept[i].assert, true);
    },
    // TODO: strange API here, intuitive for manual usage with addError(pslyInstance, 'foo', 'bar')
    // but a little bit complex for above internal usage, with forced undefined parametter..
    addError: function (fieldInstance, name, message, assert, doNotUpdateClass) {
      fieldInstance._ui.$errorsWrapper
        .addClass('filled')
        .append($(fieldInstance.options.errorTemplate)
        .addClass('parsley-' + name)
        .html(message || this._getErrorMessage(fieldInstance, assert)));
      if (true !== doNotUpdateClass)
        this._errorClass(fieldInstance);
    },
    // Same as above
    updateError: function (fieldInstance, name, message, assert, doNotUpdateClass) {
      fieldInstance._ui.$errorsWrapper
        .addClass('filled')
        .find('.parsley-' + name)
        .html(message || this._getErrorMessage(fieldInstance, assert));
      if (true !== doNotUpdateClass)
        this._errorClass(fieldInstance);
    },
    // Same as above twice
    removeError: function (fieldInstance, name, doNotUpdateClass) {
      fieldInstance._ui.$errorsWrapper
        .removeClass('filled')
        .find('.parsley-' + name)
        .remove();
      // edge case possible here: remove a standard Parsley error that is still failing in fieldInstance.validationResult
      // but highly improbable cuz' manually removing a well Parsley handled error makes no sense.
      if (true !== doNotUpdateClass)
        this.manageStatusClass(fieldInstance);
    },
    focus: function (formInstance) {
      if (true === formInstance.validationResult || 'none' === formInstance.options.focus)
        return formInstance._focusedField = null;
      formInstance._focusedField = null;
      for (var i = 0; i < formInstance.fields.length; i++)
        if (true !== formInstance.fields[i].validationResult && formInstance.fields[i].validationResult.length > 0 && 'undefined' === typeof formInstance.fields[i].options.noFocus) {
          if ('first' === formInstance.options.focus) {
            formInstance._focusedField = formInstance.fields[i].$element;
            return formInstance._focusedField.focus();
          }
          formInstance._focusedField = formInstance.fields[i].$element;
        }
      if (null === formInstance._focusedField)
        return null;
      return formInstance._focusedField.focus();
    },
    _getErrorMessage: function (fieldInstance, constraint) {
      var customConstraintErrorMessage = constraint.name + 'Message';
      if ('undefined' !== typeof fieldInstance.options[customConstraintErrorMessage])
        return window.ParsleyValidator.formatMessage(fieldInstance.options[customConstraintErrorMessage], constraint.requirements);
      return window.ParsleyValidator.getErrorMessage(constraint);
    },
    _diff: function (newResult, oldResult, deep) {
      var
        added = [],
        kept = [];
      for (var i = 0; i < newResult.length; i++) {
        var found = false;
        for (var j = 0; j < oldResult.length; j++)
          if (newResult[i].assert.name === oldResult[j].assert.name) {
            found = true;
            break;
          }
        if (found)
          kept.push(newResult[i]);
        else
          added.push(newResult[i]);
      }
      return {
        kept: kept,
        added: added,
        removed: !deep ? this._diff(oldResult, newResult, true).added : []
      };
    },
    setupForm: function (formInstance) {
      formInstance.$element.on('submit.Parsley', false, $.proxy(formInstance.onSubmitValidate, formInstance));
      // UI could be disabled
      if (false === formInstance.options.uiEnabled)
        return;
      formInstance.$element.attr('novalidate', '');
    },
    setupField: function (fieldInstance) {
      var _ui = { active: false };
      // UI could be disabled
      if (false === fieldInstance.options.uiEnabled)
        return;
      _ui.active = true;
      // Give field its Parsley id in DOM
      fieldInstance.$element.attr(fieldInstance.options.namespace + 'id', fieldInstance.__id__);
      /** Generate important UI elements and store them in fieldInstance **/
      // $errorClassHandler is the $element that woul have parsley-error and parsley-success classes
      _ui.$errorClassHandler = this._manageClassHandler(fieldInstance);
      // $errorsWrapper is a div that would contain the various field errors, it will be appended into $errorsContainer
      _ui.errorsWrapperId = 'parsley-id-' + ('undefined' !== typeof fieldInstance.options.multiple ? 'multiple-' + fieldInstance.options.multiple : fieldInstance.__id__);
      _ui.$errorsWrapper = $(fieldInstance.options.errorsWrapper).attr('id', _ui.errorsWrapperId);
      // ValidationResult UI storage to detect what have changed bwt two validations, and update DOM accordingly
      _ui.lastValidationResult = [];
      _ui.validatedOnce = false;
      _ui.validationInformationVisible = false;
      // Store it in fieldInstance for later
      fieldInstance._ui = _ui;
      /** Mess with DOM now **/
      this._insertErrorWrapper(fieldInstance);
      // Bind triggers first time
      this.actualizeTriggers(fieldInstance);
    },
    // Determine which element will have `parsley-error` and `parsley-success` classes
    _manageClassHandler: function (fieldInstance) {
      // An element selector could be passed through DOM with `data-parsley-class-handler=#foo`
      if ('string' === typeof fieldInstance.options.classHandler && $(fieldInstance.options.classHandler).length)
        return $(fieldInstance.options.classHandler);
      // Class handled could also be determined by function given in Parsley options
      var $handler = fieldInstance.options.classHandler(fieldInstance);
      // If this function returned a valid existing DOM element, go for it
      if ('undefined' !== typeof $handler && $handler.length)
        return $handler;
      // Otherwise, if simple element (input, texatrea, select..) it will perfectly host the classes
      if ('undefined' === typeof fieldInstance.options.multiple || fieldInstance.$element.is('select'))
        return fieldInstance.$element;
      // But if multiple element (radio, checkbox), that would be their parent
      return fieldInstance.$element.parent();
    },
    _insertErrorWrapper: function (fieldInstance) {
      var $errorsContainer;
      if ('string' === typeof fieldInstance.options.errorsContainer )
        if ($(fieldInstance.options.errorsContainer + '').length)
          return $(fieldInstance.options.errorsContainer).append(fieldInstance._ui.$errorsWrapper);
        else if (window.console && window.console.warn)
          window.console.warn('The errors container `' + fieldInstance.options.errorsContainer + '` does not exist in DOM');

      if ('function' === typeof fieldInstance.options.errorsContainer)
        $errorsContainer = fieldInstance.options.errorsContainer(fieldInstance);
      if ('undefined' !== typeof $errorsContainer && $errorsContainer.length)
        return $errorsContainer.append(fieldInstance._ui.$errorsWrapper);
      return 'undefined' === typeof fieldInstance.options.multiple ? fieldInstance.$element.after(fieldInstance._ui.$errorsWrapper) : fieldInstance.$element.parent().after(fieldInstance._ui.$errorsWrapper);
    },
    actualizeTriggers: function (fieldInstance) {
      var that = this;
      // Remove Parsley events already binded on this field
      if (fieldInstance.options.multiple)
        $('[' + fieldInstance.options.namespace + 'multiple="' + fieldInstance.options.multiple + '"]').each(function () {
          $(this).off('.Parsley');
        });
      else
        fieldInstance.$element.off('.Parsley');
      // If no trigger is set, all good
      if (false === fieldInstance.options.trigger)
        return;
      var triggers = fieldInstance.options.trigger.replace(/^\s+/g , '').replace(/\s+$/g , '');
      if ('' === triggers)
        return;
      // Bind fieldInstance.eventValidate if exists (for parsley.ajax for example), ParsleyUI.eventValidate otherwise
      if (fieldInstance.options.multiple)
        $('[' + fieldInstance.options.namespace + 'multiple="' + fieldInstance.options.multiple + '"]').each(function () {
          $(this).on(
            triggers.split(' ').join('.Parsley ') + '.Parsley',
            false,
            $.proxy('function' === typeof fieldInstance.eventValidate ? fieldInstance.eventValidate : that.eventValidate, fieldInstance));
        });
      else
        fieldInstance.$element
          .on(
            triggers.split(' ').join('.Parsley ') + '.Parsley',
            false,
            $.proxy('function' === typeof fieldInstance.eventValidate ? fieldInstance.eventValidate : this.eventValidate, fieldInstance));
    },
    // Called through $.proxy with fieldInstance. `this` context is ParsleyField
    eventValidate: function(event) {
      // For keyup, keypress, keydown.. events that could be a little bit obstrusive
      // do not validate if val length < min threshold on first validation. Once field have been validated once and info
      // about success or failure have been displayed, always validate with this trigger to reflect every yalidation change.
      if (new RegExp('key').test(event.type))
        if (!this._ui.validationInformationVisible && this.getValue().length <= this.options.validationThreshold)
          return;
      this._ui.validatedOnce = true;
      this.validate();
    },
    manageFailingFieldTrigger: function (fieldInstance) {
      fieldInstance._ui.failedOnce = true;
      // Radio and checkboxes fields must bind every field multiple
      if (fieldInstance.options.multiple)
        $('[' + fieldInstance.options.namespace + 'multiple="' + fieldInstance.options.multiple + '"]').each(function () {
          if (!new RegExp('change', 'i').test($(this).parsley().options.trigger || ''))
            return $(this).on('change.ParsleyFailedOnce', false, $.proxy(fieldInstance.validate, fieldInstance));
        });
      // Select case
      if (fieldInstance.$element.is('select'))
        if (!new RegExp('change', 'i').test(fieldInstance.options.trigger || ''))
          return fieldInstance.$element.on('change.ParsleyFailedOnce', false, $.proxy(fieldInstance.validate, fieldInstance));
      // All other inputs fields
      if (!new RegExp('keyup', 'i').test(fieldInstance.options.trigger || ''))
        return fieldInstance.$element.on('keyup.ParsleyFailedOnce', false, $.proxy(fieldInstance.validate, fieldInstance));
    },
    reset: function (parsleyInstance) {
      // Reset all event listeners
      parsleyInstance.$element.off('.Parsley');
      parsleyInstance.$element.off('.ParsleyFailedOnce');
      // Nothing to do if UI never initialized for this field
      if ('undefined' === typeof parsleyInstance._ui)
        return;
      if ('ParsleyForm' === parsleyInstance.__class__)
        return;
      // Reset all errors' li
      parsleyInstance._ui.$errorsWrapper.children().each(function () {
        $(this).remove();
      });
      // Reset validation class
      this._resetClass(parsleyInstance);
      // Reset validation flags and last validation result
      parsleyInstance._ui.validatedOnce = false;
      parsleyInstance._ui.lastValidationResult = [];
      parsleyInstance._ui.validationInformationVisible = false;
    },
    destroy: function (parsleyInstance) {
      this.reset(parsleyInstance);
      if ('ParsleyForm' === parsleyInstance.__class__)
        return;
      parsleyInstance._ui.$errorsWrapper.remove();
      delete parsleyInstance._ui;
    },
    _successClass: function (fieldInstance) {
      fieldInstance._ui.validationInformationVisible = true;
      fieldInstance._ui.$errorClassHandler.removeClass(fieldInstance.options.errorClass).addClass(fieldInstance.options.successClass);
    },
    _errorClass: function (fieldInstance) {
      fieldInstance._ui.validationInformationVisible = true;
      fieldInstance._ui.$errorClassHandler.removeClass(fieldInstance.options.successClass).addClass(fieldInstance.options.errorClass);
    },
    _resetClass: function (fieldInstance) {
      fieldInstance._ui.$errorClassHandler.removeClass(fieldInstance.options.successClass).removeClass(fieldInstance.options.errorClass);
    }
  };

  var ParsleyOptionsFactory = function (defaultOptions, globalOptions, userOptions, namespace) {
    this.__class__ = 'OptionsFactory';
    this.__id__ = ParsleyUtils.hash(4);
    this.formOptions = null;
    this.fieldOptions = null;
    this.staticOptions = $.extend(true, {}, defaultOptions, globalOptions, userOptions, { namespace: namespace });
  };
  ParsleyOptionsFactory.prototype = {
    get: function (parsleyInstance) {
      if ('undefined' === typeof parsleyInstance.__class__)
        throw new Error('Parsley Instance expected');
      switch (parsleyInstance.__class__) {
        case 'Parsley':
          return this.staticOptions;
        case 'ParsleyForm':
          return this.getFormOptions(parsleyInstance);
        case 'ParsleyField':
        case 'ParsleyFieldMultiple':
          return this.getFieldOptions(parsleyInstance);
        default:
          throw new Error('Instance ' + parsleyInstance.__class__ + ' is not supported');
      }
    },
    getFormOptions: function (formInstance) {
      this.formOptions = ParsleyUtils.attr(formInstance.$element, this.staticOptions.namespace);
      // not deep extend, since formOptions is a 1 level deep object
      return $.extend({}, this.staticOptions, this.formOptions);
    },
    getFieldOptions: function (fieldInstance) {
      this.fieldOptions = ParsleyUtils.attr(fieldInstance.$element, this.staticOptions.namespace);
      if (null === this.formOptions && 'undefined' !== typeof fieldInstance.parent)
        this.formOptions = this.getFormOptions(fieldInstance.parent);
      // not deep extend, since formOptions and fieldOptions is a 1 level deep object
      return $.extend({}, this.staticOptions, this.formOptions, this.fieldOptions);
    }
  };

  var ParsleyForm = function (element, OptionsFactory) {
    this.__class__ = 'ParsleyForm';
    this.__id__ = ParsleyUtils.hash(4);
    if ('OptionsFactory' !== ParsleyUtils.get(OptionsFactory, '__class__'))
      throw new Error('You must give an OptionsFactory instance');
    this.OptionsFactory = OptionsFactory;
    this.$element = $(element);
    this.validationResult = null;
    this.options = this.OptionsFactory.get(this);
  };
  ParsleyForm.prototype = {
    onSubmitValidate: function (event) {
      this.validate(undefined, undefined, event);
      // prevent form submission if validation fails
      if (false === this.validationResult && event instanceof $.Event) {
        event.stopImmediatePropagation();
        event.preventDefault();
      }
      return this;
    },
    // @returns boolean
    validate: function (group, force, event) {
      this.submitEvent = event;
      this.validationResult = true;
      var fieldValidationResult = [];
      // Refresh form DOM options and form's fields that could have changed
      this._refreshFields();
      $.emit('parsley:form:validate', this);
      // loop through fields to validate them one by one
      for (var i = 0; i < this.fields.length; i++) {
        // do not validate a field if not the same as given validation group
        if (group && group !== this.fields[i].options.group)
          continue;
        fieldValidationResult = this.fields[i].validate(force);
        if (true !== fieldValidationResult && fieldValidationResult.length > 0 && this.validationResult)
          this.validationResult = false;
      }
      $.emit('parsley:form:validated', this);
      return this.validationResult;
    },
    // Iterate over refreshed fields, and stop on first failure
    isValid: function (group, force) {
      this._refreshFields();
      for (var i = 0; i < this.fields.length; i++) {
        // do not validate a field if not the same as given validation group
        if (group && group !== this.fields[i].options.group)
          continue;
        if (false === this.fields[i].isValid(force))
          return false;
      }
      return true;
    },
    _refreshFields: function () {
      return this.actualizeOptions()._bindFields();
    },
    _bindFields: function () {
      var self = this;
      this.fields = [];
      this.fieldsMappedById = {};
      this.$element.find(this.options.inputs).each(function () {
        var fieldInstance = new window.Parsley(this, {}, self);
        // Only add valid and not excluded `ParsleyField` and `ParsleyFieldMultiple` children
        if (('ParsleyField' === fieldInstance.__class__ || 'ParsleyFieldMultiple' === fieldInstance.__class__) && !fieldInstance.$element.is(fieldInstance.options.excluded))
          if ('undefined' === typeof self.fieldsMappedById[fieldInstance.__class__ + '-' + fieldInstance.__id__]) {
            self.fieldsMappedById[fieldInstance.__class__ + '-' + fieldInstance.__id__] = fieldInstance;
            self.fields.push(fieldInstance);
          }
      });
      return this;
    }
  };

  var ConstraintFactory = function (parsleyField, name, requirements, priority, isDomConstraint) {
    if (!new RegExp('ParsleyField').test(ParsleyUtils.get(parsleyField, '__class__')))
      throw new Error('ParsleyField or ParsleyFieldMultiple instance expected');
    if ('function' !== typeof window.ParsleyValidator.validators[name] &&
      'Assert' !== window.ParsleyValidator.validators[name](requirements).__parentClass__)
      throw new Error('Valid validator expected');
    var getPriority = function (parsleyField, name) {
      if ('undefined' !== typeof parsleyField.options[name + 'Priority'])
        return parsleyField.options[name + 'Priority'];
      return ParsleyUtils.get(window.ParsleyValidator.validators[name](requirements), 'priority') || 2;
    };
    priority = priority || getPriority(parsleyField, name);
    // If validator have a requirementsTransformer, execute it
    if ('function' === typeof window.ParsleyValidator.validators[name](requirements).requirementsTransformer)
      requirements = window.ParsleyValidator.validators[name](requirements).requirementsTransformer();
    return $.extend(window.ParsleyValidator.validators[name](requirements), {
      name: name,
      requirements: requirements,
      priority: priority,
      groups: [priority],
      isDomConstraint: isDomConstraint || ParsleyUtils.attr(parsleyField.$element, parsleyField.options.namespace, name)
    });
  };

  var ParsleyField = function (field, OptionsFactory, parsleyFormInstance) {
    this.__class__ = 'ParsleyField';
    this.__id__ = ParsleyUtils.hash(4);
    this.$element = $(field);
    // If we have a parent `ParsleyForm` instance given, use its `OptionsFactory`, and save parent
    if ('undefined' !== typeof parsleyFormInstance) {
      this.parent = parsleyFormInstance;
      this.OptionsFactory = this.parent.OptionsFactory;
      this.options = this.OptionsFactory.get(this);
    // Else, take the `Parsley` one
    } else {
      this.OptionsFactory = OptionsFactory;
      this.options = this.OptionsFactory.get(this);
    }
    // Initialize some properties
    this.constraints = [];
    this.constraintsByName = {};
    this.validationResult = [];
    // Bind constraints
    this._bindConstraints();
  };
  ParsleyField.prototype = {
    // # Public API
    // Validate field and $.emit some events for mainly `ParsleyUI`
    // @returns validationResult:
    //  - `true` if all constraint passes
    //  - `[]` if not required field and empty (not validated)
    //  - `[Violation, [Violation..]]` if there were validation errors
    validate: function (force) {
      this.value = this.getValue();
      // Field Validate event. `this.value` could be altered for custom needs
      $.emit('parsley:field:validate', this);
      $.emit('parsley:field:' + (this.isValid(force, this.value) ? 'success' : 'error'), this);
      // Field validated event. `this.validationResult` could be altered for custom needs too
      $.emit('parsley:field:validated', this);
      return this.validationResult;
    },
    // Just validate field. Do not trigger any event
    // Same @return as `validate()`
    isValid: function (force, value) {
      // Recompute options and rebind constraints to have latest changes
      this.refreshConstraints();
      // Sort priorities to validate more important first
      var priorities = this._getConstraintsSortedPriorities();
      // Value could be passed as argument, needed to add more power to 'parsley:field:validate'
      value = value || this.getValue();
      // If a field is empty and not required, leave it alone, it's just fine
      // Except if `data-parsley-validate-if-empty` explicitely added, useful for some custom validators
      if (0 === value.length && !this._isRequired() && 'undefined' === typeof this.options.validateIfEmpty && true !== force)
        return this.validationResult = [];
      // If we want to validate field against all constraints, just call Validator and let it do the job
      if (false === this.options.priorityEnabled)
        return true === (this.validationResult = this.validateThroughValidator(value, this.constraints, 'Any'));
      // Else, iterate over priorities one by one, and validate related asserts one by one
      for (var i = 0; i < priorities.length; i++)
        if (true !== (this.validationResult = this.validateThroughValidator(value, this.constraints, priorities[i])))
          return false;
      return true;
    },
    // @returns Parsley field computed value that could be overrided or configured in DOM
    getValue: function () {
      var value;
      // Value could be overriden in DOM
      if ('undefined' !== typeof this.options.value)
        value = this.options.value;
      else
        value = this.$element.val();
      // Handle wrong DOM or configurations
      if ('undefined' === typeof value || null === value)
        return '';
      // Use `data-parsley-trim-value="true"` to auto trim inputs entry
      if (true === this.options.trimValue)
        return value.replace(/^\s+|\s+$/g, '');
      return value;
    },
    // Actualize options that could have change since previous validation
    // Re-bind accordingly constraints (could be some new, removed or updated)
    refreshConstraints: function () {
      return this.actualizeOptions()._bindConstraints();
    },
    /**
    * Add a new constraint to a field
    *
    * @method addConstraint
    * @param {String}   name
    * @param {Mixed}    requirements      optional
    * @param {Number}   priority          optional
    * @param {Boolean}  isDomConstraint   optional
    */
    addConstraint: function (name, requirements, priority, isDomConstraint) {
      name = name.toLowerCase();
      if ('function' === typeof window.ParsleyValidator.validators[name]) {
        var constraint = new ConstraintFactory(this, name, requirements, priority, isDomConstraint);
        // if constraint already exist, delete it and push new version
        if ('undefined' !== this.constraintsByName[constraint.name])
          this.removeConstraint(constraint.name);
        this.constraints.push(constraint);
        this.constraintsByName[constraint.name] = constraint;
      }
      return this;
    },
    // Remove a constraint
    removeConstraint: function (name) {
      for (var i = 0; i < this.constraints.length; i++)
        if (name === this.constraints[i].name) {
          this.constraints.splice(i, 1);
          break;
        }
      return this;
    },
    // Update a constraint (Remove + re-add)
    updateConstraint: function (name, parameters, priority) {
      return this.removeConstraint(name)
        .addConstraint(name, parameters, priority);
    },
    // # Internals
    // Internal only.
    // Bind constraints from config + options + DOM
    _bindConstraints: function () {
      var constraints = [];
      // clean all existing DOM constraints to only keep javascript user constraints
      for (var i = 0; i < this.constraints.length; i++)
        if (false === this.constraints[i].isDomConstraint)
          constraints.push(this.constraints[i]);
      this.constraints = constraints;
      // then re-add Parsley DOM-API constraints
      for (var name in this.options)
        this.addConstraint(name, this.options[name]);
      // finally, bind special HTML5 constraints
      return this._bindHtml5Constraints();
    },
    // Internal only.
    // Bind specific HTML5 constraints to be HTML5 compliant
    _bindHtml5Constraints: function () {
      // html5 required
      if (this.$element.hasClass('required') || this.$element.attr('required'))
        this.addConstraint('required', true, undefined, true);
      // html5 pattern
      if ('string' === typeof this.$element.attr('pattern'))
        this.addConstraint('pattern', this.$element.attr('pattern'), undefined, true);
      // range
      if ('undefined' !== typeof this.$element.attr('min') && 'undefined' !== typeof this.$element.attr('max'))
        this.addConstraint('range', [this.$element.attr('min'), this.$element.attr('max')], undefined, true);
      // HTML5 min
      else if ('undefined' !== typeof this.$element.attr('min'))
        this.addConstraint('min', this.$element.attr('min'), undefined, true);
      // HTML5 max
      else if ('undefined' !== typeof this.$element.attr('max'))
        this.addConstraint('max', this.$element.attr('max'), undefined, true);
      // html5 types
      var type = this.$element.attr('type');
      if ('undefined' === typeof type)
        return this;
      // Small special case here for HTML5 number, that is in fact an integer validator
      if ('number' === type)
        return this.addConstraint('type', 'integer', undefined, true);
      // Regular other HTML5 supported types
      else if (new RegExp(type, 'i').test('email url range'))
        return this.addConstraint('type', type, undefined, true);
      return this;
    },
    // Internal only.
    // Field is required if have required constraint without `false` value
    _isRequired: function () {
      if ('undefined' === typeof this.constraintsByName.required)
        return false;
      return false !== this.constraintsByName.required.requirements;
    },
    // Internal only.
    // Sort constraints by priority DESC
    _getConstraintsSortedPriorities: function () {
      var priorities = [];
      // Create array unique of priorities
      for (var i = 0; i < this.constraints.length; i++)
        if (-1 === priorities.indexOf(this.constraints[i].priority))
          priorities.push(this.constraints[i].priority);
      // Sort them by priority DESC
      priorities.sort(function (a, b) { return b - a; });
      return priorities;
    }
  };

  var ParsleyMultiple = function () {
    this.__class__ = 'ParsleyFieldMultiple';
  };
  ParsleyMultiple.prototype = {
    // Add new `$element` sibling for multiple field
    addElement: function ($element) {
      this.$elements.push($element);
      return this;
    },
    // See `ParsleyField.refreshConstraints()`
    refreshConstraints: function () {
      var fieldConstraints;
      this.constraints = [];
      // Select multiple special treatment
      if (this.$element.is('select')) {
        this.actualizeOptions()._bindConstraints();
        return this;
      }
      // Gather all constraints for each input in the multiple group
      for (var i = 0; i < this.$elements.length; i++) {
        fieldConstraints = this.$elements[i].data('ParsleyFieldMultiple').refreshConstraints().constraints;
        for (var j = 0; j < fieldConstraints.length; j++)
          this.addConstraint(fieldConstraints[j].name, fieldConstraints[j].requirements, fieldConstraints[j].priority, fieldConstraints[j].isDomConstraint);
      }
      return this;
    },
    // See `ParsleyField.getValue()`
    getValue: function () {
      // Value could be overriden in DOM
      if ('undefined' !== typeof this.options.value)
        return this.options.value;
      // Radio input case
      if (this.$element.is('input[type=radio]'))
        return $('[' + this.options.namespace + 'multiple="' + this.options.multiple + '"]:checked').val() || '';
      // checkbox input case
      if (this.$element.is('input[type=checkbox]')) {
        var values = [];
        $('[' + this.options.namespace + 'multiple="' + this.options.multiple + '"]:checked').each(function () {
          values.push($(this).val());
        });
        return values.length ? values : [];
      }
      // Select multiple case
      if (this.$element.is('select') && null === this.$element.val())
        return [];
      // Default case that should never happen
      return this.$element.val();
    },
    _init: function (multiple) {
      this.$elements = [this.$element];
      this.options.multiple = multiple;
      return this;
    }
  };

  var
    o = $({}),
    subscribed = {};
  // $.listen(name, callback);
  // $.listen(name, context, callback);
  $.listen = function (name) {
    if ('undefined' === typeof subscribed[name])
      subscribed[name] = [];
    if ('function' === typeof arguments[1])
      return subscribed[name].push({ fn: arguments[1] });
    if ('object' === typeof arguments[1] && 'function' === typeof arguments[2])
      return subscribed[name].push({ fn: arguments[2], ctxt: arguments[1] });
    throw new Error('Wrong parameters');
  };
  $.listenTo = function (instance, name, fn) {
    if ('undefined' === typeof subscribed[name])
      subscribed[name] = [];
    if (!(instance instanceof ParsleyField) && !(instance instanceof ParsleyForm))
      throw new Error('Must give Parsley instance');
    if ('string' !== typeof name || 'function' !== typeof fn)
      throw new Error('Wrong parameters');
    subscribed[name].push({ instance: instance, fn: fn });
  };
  $.unsubscribe = function (name, fn) {
    if ('undefined' === typeof subscribed[name])
      return;
    if ('string' !== typeof name || 'function' !== typeof fn)
      throw new Error('Wrong arguments');
    for (var i = 0; i < subscribed[name].length; i++)
      if (subscribed[name][i].fn === fn)
        return subscribed[name].splice(i, 1);
  };
  $.unsubscribeTo = function (instance, name) {
    if ('undefined' === typeof subscribed[name])
      return;
    if (!(instance instanceof ParsleyField) && !(instance instanceof ParsleyForm))
      throw new Error('Must give Parsley instance');
    for (var i = 0; i < subscribed[name].length; i++)
      if ('undefined' !== typeof subscribed[name][i].instance && subscribed[name][i].instance.__id__ === instance.__id__)
        return subscribed[name].splice(i, 1);
  };
  $.unsubscribeAll = function (name) {
    if ('undefined' === typeof subscribed[name])
      return;
    delete subscribed[name];
  };
  // $.emit(name [, arguments...]);
  // $.emit(name, instance [, arguments..]);
  $.emit = function (name, instance) {
    if ('undefined' === typeof subscribed[name])
      return;
    // loop through registered callbacks for this event
    for (var i = 0; i < subscribed[name].length; i++) {
      // if instance is not registered, simple emit
      if ('undefined' === typeof subscribed[name][i].instance) {
        subscribed[name][i].fn.apply('undefined' !== typeof subscribed[name][i].ctxt ? subscribed[name][i].ctxt : o, Array.prototype.slice.call(arguments, 1));
        continue;
      }
      // if instance registered but no instance given for the emit, continue
      if (!(instance instanceof ParsleyField) && !(instance instanceof ParsleyForm))
        continue;
      // if instance is registered and same id, emit
      if (subscribed[name][i].instance.__id__ === instance.__id__) {
        subscribed[name][i].fn.apply(o, Array.prototype.slice.call(arguments, 1));
        continue;
      }
      // if registered instance is a Form and fired one is a Field, loop over all its fields and emit if field found
      if (subscribed[name][i].instance instanceof ParsleyForm && instance instanceof ParsleyField)
        for (var j = 0; j < subscribed[name][i].instance.fields.length; j++)
          if (subscribed[name][i].instance.fields[j].__id__ === instance.__id__) {
            subscribed[name][i].fn.apply(o, Array.prototype.slice.call(arguments, 1));
            continue;
          }
    }
  };
  $.subscribed = function () { return subscribed; };

// ParsleyConfig definition if not already set
window.ParsleyConfig = window.ParsleyConfig || {};
window.ParsleyConfig.i18n = window.ParsleyConfig.i18n || {};
// Define then the messages
window.ParsleyConfig.i18n.en = $.extend(window.ParsleyConfig.i18n.en || {}, {
  defaultMessage: "This value seems to be invalid.",
  type: {
    email:        "This value should be a valid email.",
    url:          "This value should be a valid url.",
    number:       "This value should be a valid number.",
    integer:      "This value should be a valid integer.",
    digits:       "This value should be digits.",
    alphanum:     "This value should be alphanumeric."
  },
  notblank:       "This value should not be blank.",
  required:       "This value is required.",
  pattern:        "This value seems to be invalid.",
  min:            "This value should be greater than or equal to %s.",
  max:            "This value should be lower than or equal to %s.",
  range:          "This value should be between %s and %s.",
  minlength:      "This value is too short. It should have %s characters or more.",
  maxlength:      "This value is too long. It should have %s characters or less.",
  length:         "This value length is invalid. It should be between %s and %s characters long.",
  mincheck:       "You must select at least %s choices.",
  maxcheck:       "You must select %s choices or less.",
  check:          "You must select between %s and %s choices.",
  equalto:        "This value should be the same."
});
// If file is loaded after Parsley main file, auto-load locale
if ('undefined' !== typeof window.ParsleyValidator)
  window.ParsleyValidator.addCatalog('en', window.ParsleyConfig.i18n.en, true);

//     Parsley.js 2.0.0
//     http://parsleyjs.org
//     (c) 20012-2014 Guillaume Potier, Wisembly
//     Parsley may be freely distributed under the MIT license.

  // ### Parsley factory
  var Parsley = function (element, options, parsleyFormInstance) {
    this.__class__ = 'Parsley';
    this.__version__ = '2.0.0';
    this.__id__ = ParsleyUtils.hash(4);
    // Parsley must be instanciated with a DOM element or jQuery $element
    if ('undefined' === typeof element)
      throw new Error('You must give an element');
    if ('undefined' !== typeof parsleyFormInstance && 'ParsleyForm' !== parsleyFormInstance.__class__)
      throw new Error('Parent instance must be a ParsleyForm instance');
    return this.init($(element), options, parsleyFormInstance);
  };
  Parsley.prototype = {
    init: function ($element, options, parsleyFormInstance) {
      if (!$element.length)
        throw new Error('You must bind Parsley on an existing element.');
      this.$element = $element;
      // If element have already been binded, returns its saved Parsley instance
      if (this.$element.data('Parsley')) {
        var savedparsleyFormInstance = this.$element.data('Parsley');
        // If saved instance have been binded without a ParsleyForm parent and there is one given in this call, add it
        if ('undefined' !== typeof parsleyFormInstance)
          savedparsleyFormInstance.parent = parsleyFormInstance;
        return savedparsleyFormInstance;
      }
      // Handle 'static' options
      this.OptionsFactory = new ParsleyOptionsFactory(ParsleyDefaults, ParsleyUtils.get(window, 'ParsleyConfig') || {}, options, this.getNamespace(options));
      this.options = this.OptionsFactory.get(this);
      // A ParsleyForm instance is obviously a `<form>` elem but also every node that is not an input and have `data-parsley-validate` attribute
      if (this.$element.is('form') || (ParsleyUtils.attr(this.$element, this.options.namespace, 'validate') && !this.$element.is(this.options.inputs)))
        return this.bind('parsleyForm');
      // Every other supported element and not excluded element is binded as a `ParsleyField` or `ParsleyFieldMultiple`
      else if (this.$element.is(this.options.inputs) && !this.$element.is(this.options.excluded))
        return this.isMultiple() ? this.handleMultiple(parsleyFormInstance) : this.bind('parsleyField', parsleyFormInstance);
      return this;
    },
    isMultiple: function () {
      return (this.$element.is('input[type=radio], input[type=checkbox]') && 'undefined' === typeof this.options.multiple) || (this.$element.is('select') && 'undefined' !== typeof this.$element.attr('multiple'));
    },
    // Multiples fields are a real nightmare :(
    // Maybe some refacto would be appreciated here..
    handleMultiple: function (parsleyFormInstance) {
      var
        that = this,
        name,
        multiple,
        parsleyMultipleInstance;
      // Get parsleyFormInstance options if exist, mixed with element attributes
      this.options = $.extend(this.options, parsleyFormInstance ? parsleyFormInstance.OptionsFactory.get(parsleyFormInstance) : {}, ParsleyUtils.attr(this.$element, this.options.namespace));
      // Handle multiple name
      if (this.options.multiple) {
        multiple = this.options.multiple;
      } else if ('undefined' !== typeof this.$element.attr('name') && this.$element.attr('name').length) {
        multiple = name = this.$element.attr('name');
      } else if ('undefined' !== typeof this.$element.attr('id') && this.$element.attr('id').length) {
        multiple = this.$element.attr('id');
      }
      // Special select multiple input
      if (this.$element.is('select') && 'undefined' !== typeof this.$element.attr('multiple')) {
        return this.bind('parsleyFieldMultiple', parsleyFormInstance, multiple || this.__id__);
      // Else for radio / checkboxes, we need a `name` or `data-parsley-multiple` to properly bind it
      } else if ('undefined' === typeof multiple) {
        if (window.console && window.console.warn)
          window.console.warn('To be binded by Parsley, a radio, a checkbox and a multiple select input must have either a name or a multiple option.', this.$element);
        return this;
      }
      // Remove special chars
      multiple = multiple.replace(/(:|\.|\[|\]|\$)/g, '');
      // Add proper `data-parsley-multiple` to siblings if we had a name
      if ('undefined' !== typeof name)
        $('input[name="' + name + '"]').each(function () {
          if ($(this).is('input[type=radio], input[type=checkbox]'))
            $(this).attr(that.options.namespace + 'multiple', multiple);
        });
      // Check here if we don't already have a related multiple instance saved
      if ($('[' + this.options.namespace + 'multiple=' + multiple +']').length)
        for (var i = 0; i < $('[' + this.options.namespace + 'multiple=' + multiple +']').length; i++)
          if ('undefined' !== typeof $($('[' + this.options.namespace + 'multiple=' + multiple +']').get(i)).data('Parsley')) {
            parsleyMultipleInstance = $($('[' + this.options.namespace + 'multiple=' + multiple +']').get(i)).data('Parsley');
            if (!this.$element.data('ParsleyFieldMultiple')) {
              parsleyMultipleInstance.addElement(this.$element);
              this.$element.attr(this.options.namespace + 'id', parsleyMultipleInstance.__id__);
            }
            break;
          }
      // Create a secret ParsleyField instance for every multiple field. It would be stored in `data('ParsleyFieldMultiple')`
      // And would be useful later to access classic `ParsleyField` stuff while being in a `ParsleyFieldMultiple` instance
      this.bind('parsleyField', parsleyFormInstance, multiple, true);
      return parsleyMultipleInstance || this.bind('parsleyFieldMultiple', parsleyFormInstance, multiple);
    },
    // Retrieve namespace used for DOM-API
    getNamespace: function (options) {
      // `data-parsley-namespace=<namespace>`
      if ('undefined' !== typeof this.$element.data('parsleyNamespace'))
        return this.$element.data('parsleyNamespace');
      if ('undefined' !== typeof ParsleyUtils.get(options, 'namespace'))
        return options.namespace;
      if ('undefined' !== typeof ParsleyUtils.get(window, 'ParsleyConfig.namespace'))
        return window.ParsleyConfig.namespace;
      return ParsleyDefaults.namespace;
    },
    // Return proper `ParsleyForm`, `ParsleyField` or `ParsleyFieldMultiple`
    bind: function (type, parentParsleyFormInstance, multiple, doNotStore) {
      var parsleyInstance;
      switch (type) {
        case 'parsleyForm':
          parsleyInstance = $.extend(
            new ParsleyForm(this.$element, this.OptionsFactory),
            new ParsleyAbstract(),
            window.ParsleyExtend
          )._bindFields();
          break;
        case 'parsleyField':
          parsleyInstance = $.extend(
            new ParsleyField(this.$element, this.OptionsFactory, parentParsleyFormInstance),
            new ParsleyAbstract(),
            window.ParsleyExtend
          );
          break;
        case 'parsleyFieldMultiple':
          parsleyInstance = $.extend(
            new ParsleyField(this.$element, this.OptionsFactory, parentParsleyFormInstance),
            new ParsleyAbstract(),
            new ParsleyMultiple(),
            window.ParsleyExtend
          )._init(multiple);
          break;
        default:
          throw new Error(type + 'is not a supported Parsley type');
      }
      if ('undefined' !== typeof multiple)
        ParsleyUtils.setAttr(this.$element, this.options.namespace, 'multiple', multiple);
      if ('undefined' !== typeof doNotStore) {
        this.$element.data('ParsleyFieldMultiple', parsleyInstance);
        return parsleyInstance;
      }
      // Store instance if `ParsleyForm`, `ParsleyField` or `ParsleyFieldMultiple`
      if (new RegExp('ParsleyF', 'i').test(parsleyInstance.__class__)) {
        // Store for later access the freshly binded instance in DOM element itself using jQuery `data()`
        this.$element.data('Parsley', parsleyInstance);
        // Tell the world we got a new ParsleyForm or ParsleyField instance!
        $.emit('parsley:' + ('parsleyForm' === type ? 'form' : 'field') + ':init', parsleyInstance);
      }
      return parsleyInstance;
    }
  };
  // ### jQuery API
  // `$('.elem').parsley(options)` or `$('.elem').psly(options)`
  $.fn.parsley = $.fn.psly = function (options) {
    if (this.length > 1) {
      var instances = [];
      this.each(function () {
        instances.push($(this).parsley(options));
      });
      return instances;
    }
    // Return undefined if applied to non existing DOM element
    if (!$(this).length) {
      if (window.console && window.console.warn)
        window.console.warn('You must bind Parsley on an existing element.');
      return;
    }
    return new Parsley(this, options);
  };
  // ### ParsleyUI
  // UI is a class apart that only listen to some events and them modify DOM accordingly
  // Could be overriden by defining a `window.ParsleyConfig.ParsleyUI` appropriate class (with `listen()` method basically)
  window.ParsleyUI = 'function' === typeof ParsleyUtils.get(window, 'ParsleyConfig.ParsleyUI') ?
    new window.ParsleyConfig.ParsleyUI().listen() : new ParsleyUI().listen();
  // ### ParsleyField and ParsleyForm extension
  // Ensure that defined if not already the case
  if ('undefined' === typeof window.ParsleyExtend)
    window.ParsleyExtend = {};
  // ### ParsleyConfig
  // Ensure that defined if not already the case
  if ('undefined' === typeof window.ParsleyConfig)
    window.ParsleyConfig = {};
  // ### Globals
  window.Parsley = window.psly = Parsley;
  window.ParsleyUtils = ParsleyUtils;
  window.ParsleyValidator = new ParsleyValidator(window.ParsleyConfig.validators, window.ParsleyConfig.i18n);
  // ### PARSLEY auto-binding
  // Prevent it by setting `ParsleyConfig.autoBind` to `false`
  if (false !== ParsleyUtils.get(window, 'ParsleyConfig.autoBind'))
    $(document).ready(function () {
      // Works only on `data-parsley-validate`.
      if ($('[data-parsley-validate]').length)
        $('[data-parsley-validate]').parsley();
    });

// AMD Compliance
if ('function' === typeof define && define.amd)
  define('parsley', function() { return window.Parsley; } );
})(window.jQuery);
/*! NProgress (c) 2013, Rico Sta. Cruz
 *  http://ricostacruz.com/nprogress */


;(function(factory) {

  if (typeof module === 'function') {
    module.exports = factory();
  } else if (typeof define === 'function' && define.amd) {
    define(factory);
  } else {
    this.NProgress = factory();
  }

})(function() {
  var NProgress = {};

  NProgress.version = '0.1.3';

  var Settings = NProgress.settings = {
    minimum: 0.08,
    easing: 'ease',
    positionUsing: '',
    speed: 200,
    trickle: true,
    trickleRate: 0.02,
    trickleSpeed: 800,
    showSpinner: true,
    barSelector: '[role="bar"]',
    spinnerSelector: '[role="spinner"]',
    template: '<div class="bar" role="bar"><div class="peg"></div></div><div class="spinner" role="spinner"><div class="spinner-icon"></div></div>'
  };

  /**
   * Updates configuration.
   *
   *     NProgress.configure({
   *       minimum: 0.1
   *     });
   */
  NProgress.configure = function(options) {
    var key, value;
    for (key in options) {
      value = options[key];
      if (value !== undefined && options.hasOwnProperty(key)) Settings[key] = value;
    }

    return this;
  };

  /**
   * Last number.
   */

  NProgress.status = null;

  /**
   * Sets the progress bar status, where `n` is a number from `0.0` to `1.0`.
   *
   *     NProgress.set(0.4);
   *     NProgress.set(1.0);
   */

  NProgress.set = function(n) {
    var started = NProgress.isStarted();

    n = clamp(n, Settings.minimum, 1);
    NProgress.status = (n === 1 ? null : n);

    var progress = NProgress.render(!started),
        bar      = progress.querySelector(Settings.barSelector),
        speed    = Settings.speed,
        ease     = Settings.easing;

    progress.offsetWidth; /* Repaint */

    queue(function(next) {
      // Set positionUsing if it hasn't already been set
      if (Settings.positionUsing === '') Settings.positionUsing = NProgress.getPositioningCSS();

      // Add transition
      css(bar, barPositionCSS(n, speed, ease));

      if (n === 1) {
        // Fade out
        css(progress, {
          transition: 'none',
          opacity: 1
        });
        progress.offsetWidth; /* Repaint */

        setTimeout(function() {
          css(progress, {
            transition: 'all ' + speed + 'ms linear',
            opacity: 0
          });
          setTimeout(function() {
            NProgress.remove();
            next();
          }, speed);
        }, speed);
      } else {
        setTimeout(next, speed);
      }
    });

    return this;
  };

  NProgress.isStarted = function() {
    return typeof NProgress.status === 'number';
  };

  /**
   * Shows the progress bar.
   * This is the same as setting the status to 0%, except that it doesn't go backwards.
   *
   *     NProgress.start();
   *
   */
  NProgress.start = function() {
    if (!NProgress.status) NProgress.set(0);

    var work = function() {
      setTimeout(function() {
        if (!NProgress.status) return;
        NProgress.trickle();
        work();
      }, Settings.trickleSpeed);
    };

    if (Settings.trickle) work();

    return this;
  };

  /**
   * Hides the progress bar.
   * This is the *sort of* the same as setting the status to 100%, with the
   * difference being `done()` makes some placebo effect of some realistic motion.
   *
   *     NProgress.done();
   *
   * If `true` is passed, it will show the progress bar even if its hidden.
   *
   *     NProgress.done(true);
   */

  NProgress.done = function(force) {
    if (!force && !NProgress.status) return this;

    return NProgress.inc(0.3 + 0.5 * Math.random()).set(1);
  };

  /**
   * Increments by a random amount.
   */

  NProgress.inc = function(amount) {
    var n = NProgress.status;

    if (!n) {
      return NProgress.start();
    } else {
      if (typeof amount !== 'number') {
        amount = (1 - n) * clamp(Math.random() * n, 0.1, 0.95);
      }

      n = clamp(n + amount, 0, 0.994);
      return NProgress.set(n);
    }
  };

  NProgress.trickle = function() {
    return NProgress.inc(Math.random() * Settings.trickleRate);
  };

  /**
   * Waits for all supplied jQuery promises and
   * increases the progress as the promises resolve.
   *
   * @param $promise jQUery Promise
   */
  (function() {
    var initial = 0, current = 0;

    NProgress.promise = function($promise) {
      if (!$promise || $promise.state() == "resolved") {
        return this;
      }

      if (current == 0) {
        NProgress.start();
      }

      initial++;
      current++;

      $promise.always(function() {
        current--;
        if (current == 0) {
            initial = 0;
            NProgress.done();
        } else {
            NProgress.set((initial - current) / initial);
        }
      });

      return this;
    };

  })();

  /**
   * (Internal) renders the progress bar markup based on the `template`
   * setting.
   */

  NProgress.render = function(fromStart) {
    if (NProgress.isRendered()) return document.getElementById('nprogress');

    addClass(document.documentElement, 'nprogress-busy');

    var progress = document.createElement('div');
    progress.id = 'nprogress';
    progress.innerHTML = Settings.template;

    var bar      = progress.querySelector(Settings.barSelector),
        perc     = fromStart ? '-100' : toBarPerc(NProgress.status || 0),
        spinner;

    css(bar, {
      transition: 'all 0 linear',
      transform: 'translate3d(' + perc + '%,0,0)'
    });

    if (!Settings.showSpinner) {
      spinner = progress.querySelector(Settings.spinnerSelector);
      spinner && removeElement(spinner);
    }

    document.body.appendChild(progress);
    return progress;
  };

  /**
   * Removes the element. Opposite of render().
   */

  NProgress.remove = function() {
    removeClass(document.documentElement, 'nprogress-busy');
    var progress = document.getElementById('nprogress');
    progress && removeElement(progress);
  };

  /**
   * Checks if the progress bar is rendered.
   */

  NProgress.isRendered = function() {
    return !!document.getElementById('nprogress');
  };

  /**
   * Determine which positioning CSS rule to use.
   */

  NProgress.getPositioningCSS = function() {
    // Sniff on document.body.style
    var bodyStyle = document.body.style;

    // Sniff prefixes
    var vendorPrefix = ('WebkitTransform' in bodyStyle) ? 'Webkit' :
                       ('MozTransform' in bodyStyle) ? 'Moz' :
                       ('msTransform' in bodyStyle) ? 'ms' :
                       ('OTransform' in bodyStyle) ? 'O' : '';

    if (vendorPrefix + 'Perspective' in bodyStyle) {
      // Modern browsers with 3D support, e.g. Webkit, IE10
      return 'translate3d';
    } else if (vendorPrefix + 'Transform' in bodyStyle) {
      // Browsers without 3D support, e.g. IE9
      return 'translate';
    } else {
      // Browsers without translate() support, e.g. IE7-8
      return 'margin';
    }
  };

  /**
   * Helpers
   */

  function clamp(n, min, max) {
    if (n < min) return min;
    if (n > max) return max;
    return n;
  }

  /**
   * (Internal) converts a percentage (`0..1`) to a bar translateX
   * percentage (`-100%..0%`).
   */

  function toBarPerc(n) {
    return (-1 + n) * 100;
  }


  /**
   * (Internal) returns the correct CSS for changing the bar's
   * position given an n percentage, and speed and ease from Settings
   */

  function barPositionCSS(n, speed, ease) {
    var barCSS;

    if (Settings.positionUsing === 'translate3d') {
      barCSS = { transform: 'translate3d('+toBarPerc(n)+'%,0,0)' };
    } else if (Settings.positionUsing === 'translate') {
      barCSS = { transform: 'translate('+toBarPerc(n)+'%,0)' };
    } else {
      barCSS = { 'margin-left': toBarPerc(n)+'%' };
    }

    barCSS.transition = 'all '+speed+'ms '+ease;

    return barCSS;
  }

  /**
   * (Internal) Queues a function to be executed.
   */

  var queue = (function() {
    var pending = [];

    function next() {
      var fn = pending.shift();
      if (fn) {
        fn(next);
      }
    }

    return function(fn) {
      pending.push(fn);
      if (pending.length == 1) next();
    };
  })();

  /**
   * (Internal) Applies css properties to an element, similar to the jQuery
   * css method.
   *
   * While this helper does assist with vendor prefixed property names, it
   * does not perform any manipulation of values prior to setting styles.
   */

  var css = (function() {
    var cssPrefixes = [ 'Webkit', 'O', 'Moz', 'ms' ],
        cssProps    = {};

    function camelCase(string) {
      return string.replace(/^-ms-/, 'ms-').replace(/-([\da-z])/gi, function(match, letter) {
        return letter.toUpperCase();
      });
    }

    function getVendorProp(name) {
      var style = document.body.style;
      if (name in style) return name;

      var i = cssPrefixes.length,
          capName = name.charAt(0).toUpperCase() + name.slice(1),
          vendorName;
      while (i--) {
        vendorName = cssPrefixes[i] + capName;
        if (vendorName in style) return vendorName;
      }

      return name;
    }

    function getStyleProp(name) {
      name = camelCase(name);
      return cssProps[name] || (cssProps[name] = getVendorProp(name));
    }

    function applyCss(element, prop, value) {
      prop = getStyleProp(prop);
      element.style[prop] = value;
    }

    return function(element, properties) {
      var args = arguments,
          prop,
          value;

      if (args.length == 2) {
        for (prop in properties) {
          value = properties[prop];
          if (value !== undefined && properties.hasOwnProperty(prop)) applyCss(element, prop, value);
        }
      } else {
        applyCss(element, args[1], args[2]);
      }
    }
  })();

  /**
   * (Internal) Determines if an element or space separated list of class names contains a class name.
   */

  function hasClass(element, name) {
    var list = typeof element == 'string' ? element : classList(element);
    return list.indexOf(' ' + name + ' ') >= 0;
  }

  /**
   * (Internal) Adds a class to an element.
   */

  function addClass(element, name) {
    var oldList = classList(element),
        newList = oldList + name;

    if (hasClass(oldList, name)) return;

    // Trim the opening space.
    element.className = newList.substring(1);
  }

  /**
   * (Internal) Removes a class from an element.
   */

  function removeClass(element, name) {
    var oldList = classList(element),
        newList;

    if (!hasClass(element, name)) return;

    // Replace the class name.
    newList = oldList.replace(' ' + name + ' ', ' ');

    // Trim the opening and closing spaces.
    element.className = newList.substring(1, newList.length - 1);
  }

  /**
   * (Internal) Gets a space separated list of the class names on the element.
   * The list is wrapped with a single space on each end to facilitate finding
   * matches within the list.
   */

  function classList(element) {
    return (' ' + (element.className || '') + ' ').replace(/\s+/gi, ' ');
  }

  /**
   * (Internal) Removes an element from the DOM.
   */

  function removeElement(element) {
    element && element.parentNode && element.parentNode.removeChild(element);
  }

  return NProgress;
});
$(function() {
  $(document).on('page:fetch',   function() { NProgress.start();  });
  $(document).on('page:change',  function() { NProgress.done();   });
  $(document).on('page:restore', function() { NProgress.remove(); });
});
/*
 * Chartkick.js
 * Create beautiful Javascript charts with minimal code
 * https://github.com/ankane/chartkick.js
 * v1.2.1
 * MIT License
 */

/*jslint browser: true, indent: 2, plusplus: true, vars: true */


(function (window) {
  'use strict';

  var Chartkick, ISO8601_PATTERN, DECIMAL_SEPARATOR, adapters = [];

  var $ = window.jQuery || window.Zepto || window.$;

  // helpers

  function isArray(variable) {
    return Object.prototype.toString.call(variable) === "[object Array]";
  }

  function isFunction(variable) {
    return variable instanceof Function;
  }

  function isPlainObject(variable) {
    return !isFunction(variable) && variable instanceof Object;
  }

  // https://github.com/madrobby/zepto/blob/master/src/zepto.js
  function extend(target, source) {
    var key;
    for (key in source) {
      if (isPlainObject(source[key]) || isArray(source[key])) {
        if (isPlainObject(source[key]) && !isPlainObject(target[key])) {
          target[key] = {};
        }
        if (isArray(source[key]) && !isArray(target[key])) {
          target[key] = [];
        }
        extend(target[key], source[key]);
      } else if (source[key] !== undefined) {
        target[key] = source[key];
      }
    }
  }

  function merge(obj1, obj2) {
    var target = {};
    extend(target, obj1);
    extend(target, obj2);
    return target;
  }

  // https://github.com/Do/iso8601.js
  ISO8601_PATTERN = /(\d\d\d\d)(\-)?(\d\d)(\-)?(\d\d)(T)?(\d\d)(:)?(\d\d)?(:)?(\d\d)?([\.,]\d+)?($|Z|([\+\-])(\d\d)(:)?(\d\d)?)/i;
  DECIMAL_SEPARATOR = String(1.5).charAt(1);

  function parseISO8601(input) {
    var day, hour, matches, milliseconds, minutes, month, offset, result, seconds, type, year;
    type = Object.prototype.toString.call(input);
    if (type === '[object Date]') {
      return input;
    }
    if (type !== '[object String]') {
      return;
    }
    if (matches = input.match(ISO8601_PATTERN)) {
      year = parseInt(matches[1], 10);
      month = parseInt(matches[3], 10) - 1;
      day = parseInt(matches[5], 10);
      hour = parseInt(matches[7], 10);
      minutes = matches[9] ? parseInt(matches[9], 10) : 0;
      seconds = matches[11] ? parseInt(matches[11], 10) : 0;
      milliseconds = matches[12] ? parseFloat(DECIMAL_SEPARATOR + matches[12].slice(1)) * 1000 : 0;
      result = Date.UTC(year, month, day, hour, minutes, seconds, milliseconds);
      if (matches[13] && matches[14]) {
        offset = matches[15] * 60;
        if (matches[17]) {
          offset += parseInt(matches[17], 10);
        }
        offset *= matches[14] === '-' ? -1 : 1;
        result -= offset * 60 * 1000;
      }
      return new Date(result);
    }
  }
  // end iso8601.js

  function negativeValues(series) {
    var i, j, data;
    for (i = 0; i < series.length; i++) {
      data = series[i].data;
      for (j = 0; j < data.length; j++) {
        if (data[j][1] < 0) {
          return true;
        }
      }
    }
    return false;
  }

  function jsOptionsFunc(defaultOptions, hideLegend, setMin, setMax, setStacked) {
    return function (series, opts, chartOptions) {
      var options = merge({}, defaultOptions);
      options = merge(options, chartOptions || {});

      // hide legend
      // this is *not* an external option!
      if (opts.hideLegend) {
        hideLegend(options);
      }

      // min
      if ("min" in opts) {
        setMin(options, opts.min);
      } else if (!negativeValues(series)) {
        setMin(options, 0);
      }

      // max
      if ("max" in opts) {
        setMax(options, opts.max);
      }

      if (opts.stacked) {
        setStacked(options);
      }

      if (opts.colors) {
        options.colors = opts.colors;
      }

      // merge library last
      options = merge(options, opts.library || {});

      return options;
    };
  }

  function setText(element, text) {
    if (document.body.innerText) {
      element.innerText = text;
    } else {
      element.textContent = text;
    }
  }

  function chartError(element, message) {
    setText(element, "Error Loading Chart: " + message);
    element.style.color = "#ff0000";
  }

  function getJSON(element, url, success) {
    $.ajax({
      dataType: "json",
      url: url,
      success: success,
      error: function (jqXHR, textStatus, errorThrown) {
        var message = (typeof errorThrown === "string") ? errorThrown : errorThrown.message;
        chartError(element, message);
      }
    });
  }

  function errorCatcher(chart, callback) {
    try {
      callback(chart);
    } catch (err) {
      chartError(chart.element, err.message);
      throw err;
    }
  }

  function fetchDataSource(chart, callback) {
    if (typeof chart.dataSource === "string") {
      getJSON(chart.element, chart.dataSource, function (data, textStatus, jqXHR) {
        chart.data = data;
        errorCatcher(chart, callback);
      });
    } else {
      chart.data = chart.dataSource;
      errorCatcher(chart, callback);
    }
  }

  // type conversions

  function toStr(n) {
    return "" + n;
  }

  function toFloat(n) {
    return parseFloat(n);
  }

  function toDate(n) {
    if (typeof n !== "object") {
      if (typeof n === "number") {
        n = new Date(n * 1000); // ms
      } else { // str
        // try our best to get the str into iso8601
        // TODO be smarter about this
        var str = n.replace(/ /, "T").replace(" ", "").replace("UTC", "Z");
        n = parseISO8601(str) || new Date(n);
      }
    }
    return n;
  }

  function toArr(n) {
    if (!isArray(n)) {
      var arr = [], i;
      for (i in n) {
        if (n.hasOwnProperty(i)) {
          arr.push([i, n[i]]);
        }
      }
      n = arr;
    }
    return n;
  }

  function sortByTime(a, b) {
    return a[0].getTime() - b[0].getTime();
  }

  if ("Highcharts" in window) {
    var HighchartsAdapter = new function () {
      var Highcharts = window.Highcharts;

      var defaultOptions = {
        chart: {},
        xAxis: {
          labels: {
            style: {
              fontSize: "12px"
            }
          }
        },
        yAxis: {
          title: {
            text: null
          },
          labels: {
            style: {
              fontSize: "12px"
            }
          }
        },
        title: {
          text: null
        },
        credits: {
          enabled: false
        },
        legend: {
          borderWidth: 0
        },
        tooltip: {
          style: {
            fontSize: "12px"
          }
        },
        plotOptions: {
          areaspline: {},
          series: {
            marker: {}
          }
        }
      };

      var hideLegend = function (options) {
        options.legend.enabled = false;
      };

      var setMin = function (options, min) {
        options.yAxis.min = min;
      };

      var setMax = function (options, max) {
        options.yAxis.max = max;
      };

      var setStacked = function (options) {
        options.plotOptions.series.stacking = "normal";
      };

      var jsOptions = jsOptionsFunc(defaultOptions, hideLegend, setMin, setMax, setStacked);

      this.renderLineChart = function (chart, chartType) {
        chartType = chartType || "spline";
        var chartOptions = {};
        if (chartType === "areaspline") {
          chartOptions = {
            plotOptions: {
              areaspline: {
                stacking: "normal"
              },
              series: {
                marker: {
                  enabled: false
                }
              }
            }
          };
        }
        var options = jsOptions(chart.data, chart.options, chartOptions), data, i, j;
        options.xAxis.type = chart.options.discrete ? "category" : "datetime";
        options.chart.type = chartType;
        options.chart.renderTo = chart.element.id;

        var series = chart.data;
        for (i = 0; i < series.length; i++) {
          data = series[i].data;
          if (!chart.options.discrete) {
            for (j = 0; j < data.length; j++) {
              data[j][0] = data[j][0].getTime();
            }
          }
          series[i].marker = {symbol: "circle"};
        }
        options.series = series;
        new Highcharts.Chart(options);
      };

      this.renderPieChart = function (chart) {
        var chartOptions = {};
        if (chart.options.colors) {
          chartOptions.colors = chart.options.colors;
        }
        var options = merge(merge(defaultOptions, chartOptions), chart.options.library || {});
        options.chart.renderTo = chart.element.id;
        options.series = [{
          type: "pie",
          name: "Value",
          data: chart.data
        }];
        new Highcharts.Chart(options);
      };

      this.renderColumnChart = function (chart, chartType) {
        var chartType = chartType || "column";
        var series = chart.data;
        var options = jsOptions(series, chart.options), i, j, s, d, rows = [];
        options.chart.type = chartType;
        options.chart.renderTo = chart.element.id;

        for (i = 0; i < series.length; i++) {
          s = series[i];

          for (j = 0; j < s.data.length; j++) {
            d = s.data[j];
            if (!rows[d[0]]) {
              rows[d[0]] = new Array(series.length);
            }
            rows[d[0]][i] = d[1];
          }
        }

        var categories = [];
        for (i in rows) {
          if (rows.hasOwnProperty(i)) {
            categories.push(i);
          }
        }
        options.xAxis.categories = categories;

        var newSeries = [];
        for (i = 0; i < series.length; i++) {
          d = [];
          for (j = 0; j < categories.length; j++) {
            d.push(rows[categories[j]][i] || 0);
          }

          newSeries.push({
            name: series[i].name,
            data: d
          });
        }
        options.series = newSeries;

        new Highcharts.Chart(options);
      };

      var self = this;

      this.renderBarChart = function (chart) {
        self.renderColumnChart(chart, "bar");
      };

      this.renderAreaChart = function (chart) {
        self.renderLineChart(chart, "areaspline");
      };
    };
    adapters.push(HighchartsAdapter);
  }
  if (window.google && window.google.setOnLoadCallback) {
    var GoogleChartsAdapter = new function () {
      var google = window.google;

      // load from google
      var loaded = false;
      google.setOnLoadCallback(function () {
        loaded = true;
      });
      google.load("visualization", "1.0", {"packages": ["corechart"]});

      var waitForLoaded = function (callback) {
        google.setOnLoadCallback(callback); // always do this to prevent race conditions (watch out for other issues due to this)
        if (loaded) {
          callback();
        }
      };

      // Set chart options
      var defaultOptions = {
        chartArea: {},
        fontName: "'Lucida Grande', 'Lucida Sans Unicode', Verdana, Arial, Helvetica, sans-serif",
        pointSize: 6,
        legend: {
          textStyle: {
            fontSize: 12,
            color: "#444"
          },
          alignment: "center",
          position: "right"
        },
        curveType: "function",
        hAxis: {
          textStyle: {
            color: "#666",
            fontSize: 12
          },
          gridlines: {
            color: "transparent"
          },
          baselineColor: "#ccc",
          viewWindow: {}
        },
        vAxis: {
          textStyle: {
            color: "#666",
            fontSize: 12
          },
          baselineColor: "#ccc",
          viewWindow: {}
        },
        tooltip: {
          textStyle: {
            color: "#666",
            fontSize: 12
          }
        }
      };

      var hideLegend = function (options) {
        options.legend.position = "none";
      };

      var setMin = function (options, min) {
        options.vAxis.viewWindow.min = min;
      };

      var setMax = function (options, max) {
        options.vAxis.viewWindow.max = max;
      };

      var setBarMin = function (options, min) {
        options.hAxis.viewWindow.min = min;
      };

      var setBarMax = function (options, max) {
        options.hAxis.viewWindow.max = max;
      };

      var setStacked = function (options) {
        options.isStacked = true;
      };

      var jsOptions = jsOptionsFunc(defaultOptions, hideLegend, setMin, setMax, setStacked);

      // cant use object as key
      var createDataTable = function (series, columnType) {
        var data = new google.visualization.DataTable();
        data.addColumn(columnType, "");

        var i, j, s, d, key, rows = [];
        for (i = 0; i < series.length; i++) {
          s = series[i];
          data.addColumn("number", s.name);

          for (j = 0; j < s.data.length; j++) {
            d = s.data[j];
            key = (columnType === "datetime") ? d[0].getTime() : d[0];
            if (!rows[key]) {
              rows[key] = new Array(series.length);
            }
            rows[key][i] = toFloat(d[1]);
          }
        }

        var rows2 = [];
        for (i in rows) {
          if (rows.hasOwnProperty(i)) {
            rows2.push([(columnType === "datetime") ? new Date(toFloat(i)) : i].concat(rows[i]));
          }
        }
        if (columnType === "datetime") {
          rows2.sort(sortByTime);
        }
        data.addRows(rows2);

        return data;
      };

      var resize = function (callback) {
        if (window.attachEvent) {
          window.attachEvent("onresize", callback);
        } else if (window.addEventListener) {
          window.addEventListener("resize", callback, true);
        }
        callback();
      };

      this.renderLineChart = function (chart) {
        waitForLoaded(function () {
          var options = jsOptions(chart.data, chart.options);
          var data = createDataTable(chart.data, chart.options.discrete ? "string" : "datetime");
          chart.chart = new google.visualization.LineChart(chart.element);
          resize(function () {
            chart.chart.draw(data, options);
          });
        });
      };

      this.renderPieChart = function (chart) {
        waitForLoaded(function () {
          var chartOptions = {
            chartArea: {
              top: "10%",
              height: "80%"
            }
          };
          if (chart.options.colors) {
            chartOptions.colors = chart.options.colors;
          }
          var options = merge(merge(defaultOptions, chartOptions), chart.options.library || {});

          var data = new google.visualization.DataTable();
          data.addColumn("string", "");
          data.addColumn("number", "Value");
          data.addRows(chart.data);

          chart.chart = new google.visualization.PieChart(chart.element);
          resize(function () {
            chart.chart.draw(data, options);
          });
        });
      };

      this.renderColumnChart = function (chart) {
        waitForLoaded(function () {
          var options = jsOptions(chart.data, chart.options);
          var data = createDataTable(chart.data, "string");
          chart.chart = new google.visualization.ColumnChart(chart.element);
          resize(function () {
            chart.chart.draw(data, options);
          });
        });
      };

      this.renderBarChart = function (chart) {
        waitForLoaded(function () {
          var chartOptions = {
            hAxis: {
              gridlines: {
                color: "#ccc"
              }
            }
          };
          var options = jsOptionsFunc(defaultOptions, hideLegend, setBarMin, setBarMax, setStacked)(chart.data, chart.options, chartOptions);
          var data = createDataTable(chart.data, "string");
          chart.chart = new google.visualization.BarChart(chart.element);
          resize(function () {
            chart.chart.draw(data, options);
          });
        });
      };

      this.renderAreaChart = function (chart) {
        waitForLoaded(function () {
          var chartOptions = {
            isStacked: true,
            pointSize: 0,
            areaOpacity: 0.5
          };
          var options = jsOptions(chart.data, chart.options, chartOptions);
          var data = createDataTable(chart.data, chart.options.discrete ? "string" : "datetime");
          chart.chart = new google.visualization.AreaChart(chart.element);
          resize(function () {
            chart.chart.draw(data, options);
          });
        });
      };

      this.renderGeoChart = function (chart) {
        waitForLoaded(function () {
          var chartOptions = {
            legend: "none",
            colorAxis: {
              colors: chart.options.colors || ["#f6c7b6", "#ce502d"]
            }
          };
          var options = merge(merge(defaultOptions, chartOptions), chart.options.library || {});

          var data = new google.visualization.DataTable();
          data.addColumn("string", "");
          data.addColumn("number", "Value");
          data.addRows(chart.data);

          chart.chart = new google.visualization.GeoChart(chart.element);
          resize(function () {
            chart.chart.draw(data, options);
          });
        });
      };
    };
    adapters.push(GoogleChartsAdapter);
  }

  // TODO add adapter option
  // TODO remove chartType if cross-browser way
  // to get the name of the chart class
  function renderChart(chartType, chart) {
    var i, adapter, fnName;
    fnName = "render" + chartType + "Chart";

    for (i = 0; i < adapters.length; i++) {
      adapter = adapters[i];
      if (isFunction(adapter[fnName])) {
        return adapter[fnName](chart);
      }
    }
    throw new Error("No adapter found");
  }

  // process data

  function processSeries(series, opts, time) {
    var i, j, data, r, key;

    // see if one series or multiple
    if (!isArray(series) || typeof series[0] !== "object" || isArray(series[0])) {
      series = [{name: "Value", data: series}];
      opts.hideLegend = true;
    } else {
      opts.hideLegend = false;
    }
    if (opts.discrete) {
      time = false;
    }

    // right format
    for (i = 0; i < series.length; i++) {
      data = toArr(series[i].data);
      r = [];
      for (j = 0; j < data.length; j++) {
        key = data[j][0];
        key = time ? toDate(key) : toStr(key);
        r.push([key, toFloat(data[j][1])]);
      }
      if (time) {
        r.sort(sortByTime);
      }
      series[i].data = r;
    }

    return series;
  }

  function processSimple(data) {
    var perfectData = toArr(data), i;
    for (i = 0; i < perfectData.length; i++) {
      perfectData[i] = [toStr(perfectData[i][0]), toFloat(perfectData[i][1])];
    }
    return perfectData;
  }

  function processLineData(chart) {
    chart.data = processSeries(chart.data, chart.options, true);
    renderChart("Line", chart);
  }

  function processColumnData(chart) {
    chart.data = processSeries(chart.data, chart.options, false);
    renderChart("Column", chart);
  }

  function processPieData(chart) {
    chart.data = processSimple(chart.data);
    renderChart("Pie", chart);
  }

  function processBarData(chart) {
    chart.data = processSeries(chart.data, chart.options, false);
    renderChart("Bar", chart);
  }

  function processAreaData(chart) {
    chart.data = processSeries(chart.data, chart.options, true);
    renderChart("Area", chart);
  }

  function processGeoData(chart) {
    chart.data = processSimple(chart.data);
    renderChart("Geo", chart);
  }

  function setElement(chart, element, dataSource, opts, callback) {
    if (typeof element === "string") {
      element = document.getElementById(element);
    }
    chart.element = element;
    chart.options = opts || {};
    chart.dataSource = dataSource;
    Chartkick.charts[element.id] = chart;
    fetchDataSource(chart, callback);
  }

  // define classes

  Chartkick = {
    LineChart: function (element, dataSource, opts) {
      setElement(this, element, dataSource, opts, processLineData);
    },
    PieChart: function (element, dataSource, opts) {
      setElement(this, element, dataSource, opts, processPieData);
    },
    ColumnChart: function (element, dataSource, opts) {
      setElement(this, element, dataSource, opts, processColumnData);
    },
    BarChart: function (element, dataSource, opts) {
      setElement(this, element, dataSource, opts, processBarData);
    },
    AreaChart: function (element, dataSource, opts) {
      setElement(this, element, dataSource, opts, processAreaData);
    },
    GeoChart: function (element, dataSource, opts) {
      setElement(this, element, dataSource, opts, processGeoData);
    },
    charts: {}
  };

  window.Chartkick = Chartkick;
}(window));
(function() {
  var CSRFToken, Click, ComponentUrl, Link, browserCompatibleDocumentParser, browserIsntBuggy, browserSupportsCustomEvents, browserSupportsPushState, browserSupportsTurbolinks, bypassOnLoadPopstate, cacheCurrentPage, cacheSize, changePage, constrainPageCacheTo, createDocument, currentState, enableTransitionCache, executeScriptTags, extractTitleAndBody, fetch, fetchHistory, fetchReplacement, historyStateIsDefined, initializeTurbolinks, installDocumentReadyPageEventTriggers, installHistoryChangeHandler, installJqueryAjaxSuccessPageUpdateTrigger, loadedAssets, pageCache, pageChangePrevented, pagesCached, popCookie, processResponse, recallScrollPosition, referer, reflectNewUrl, reflectRedirectedUrl, rememberCurrentState, rememberCurrentUrl, rememberReferer, removeNoscriptTags, requestMethodIsSafe, resetScrollPosition, transitionCacheEnabled, transitionCacheFor, triggerEvent, visit, xhr, _ref,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  pageCache = {};

  cacheSize = 10;

  transitionCacheEnabled = false;

  currentState = null;

  loadedAssets = null;

  referer = null;

  createDocument = null;

  xhr = null;

  fetch = function(url) {
    var cachedPage;
    url = new ComponentUrl(url);
    rememberReferer();
    cacheCurrentPage();
    reflectNewUrl(url);
    if (transitionCacheEnabled && (cachedPage = transitionCacheFor(url.absolute))) {
      fetchHistory(cachedPage);
      return fetchReplacement(url);
    } else {
      return fetchReplacement(url, resetScrollPosition);
    }
  };

  transitionCacheFor = function(url) {
    var cachedPage;
    cachedPage = pageCache[url];
    if (cachedPage && !cachedPage.transitionCacheDisabled) {
      return cachedPage;
    }
  };

  enableTransitionCache = function(enable) {
    if (enable == null) {
      enable = true;
    }
    return transitionCacheEnabled = enable;
  };

  fetchReplacement = function(url, onLoadFunction) {
    if (onLoadFunction == null) {
      onLoadFunction = (function(_this) {
        return function() {};
      })(this);
    }
    triggerEvent('page:fetch', {
      url: url.absolute
    });
    if (xhr != null) {
      xhr.abort();
    }
    xhr = new XMLHttpRequest;
    xhr.open('GET', url.withoutHashForIE10compatibility(), true);
    xhr.setRequestHeader('Accept', 'text/html, application/xhtml+xml, application/xml');
    xhr.setRequestHeader('X-XHR-Referer', referer);
    xhr.onload = function() {
      var doc;
      triggerEvent('page:receive');
      if (doc = processResponse()) {
        changePage.apply(null, extractTitleAndBody(doc));
        reflectRedirectedUrl();
        onLoadFunction();
        return triggerEvent('page:load');
      } else {
        return document.location.href = url.absolute;
      }
    };
    xhr.onloadend = function() {
      return xhr = null;
    };
    xhr.onerror = function() {
      return document.location.href = url.absolute;
    };
    return xhr.send();
  };

  fetchHistory = function(cachedPage) {
    if (xhr != null) {
      xhr.abort();
    }
    changePage(cachedPage.title, cachedPage.body);
    recallScrollPosition(cachedPage);
    return triggerEvent('page:restore');
  };

  cacheCurrentPage = function() {
    var currentStateUrl;
    currentStateUrl = new ComponentUrl(currentState.url);
    pageCache[currentStateUrl.absolute] = {
      url: currentStateUrl.relative,
      body: document.body,
      title: document.title,
      positionY: window.pageYOffset,
      positionX: window.pageXOffset,
      cachedAt: new Date().getTime(),
      transitionCacheDisabled: document.querySelector('[data-no-transition-cache]') != null
    };
    return constrainPageCacheTo(cacheSize);
  };

  pagesCached = function(size) {
    if (size == null) {
      size = cacheSize;
    }
    if (/^[\d]+$/.test(size)) {
      return cacheSize = parseInt(size);
    }
  };

  constrainPageCacheTo = function(limit) {
    var cacheTimesRecentFirst, key, pageCacheKeys, _i, _len, _results;
    pageCacheKeys = Object.keys(pageCache);
    cacheTimesRecentFirst = pageCacheKeys.map(function(url) {
      return pageCache[url].cachedAt;
    }).sort(function(a, b) {
      return b - a;
    });
    _results = [];
    for (_i = 0, _len = pageCacheKeys.length; _i < _len; _i++) {
      key = pageCacheKeys[_i];
      if (!(pageCache[key].cachedAt <= cacheTimesRecentFirst[limit])) {
        continue;
      }
      triggerEvent('page:expire', pageCache[key]);
      _results.push(delete pageCache[key]);
    }
    return _results;
  };

  changePage = function(title, body, csrfToken, runScripts) {
    document.title = title;
    document.documentElement.replaceChild(body, document.body);
    if (csrfToken != null) {
      CSRFToken.update(csrfToken);
    }
    if (runScripts) {
      executeScriptTags();
    }
    currentState = window.history.state;
    triggerEvent('page:change');
    return triggerEvent('page:update');
  };

  executeScriptTags = function() {
    var attr, copy, nextSibling, parentNode, script, scripts, _i, _j, _len, _len1, _ref, _ref1;
    scripts = Array.prototype.slice.call(document.body.querySelectorAll('script:not([data-turbolinks-eval="false"])'));
    for (_i = 0, _len = scripts.length; _i < _len; _i++) {
      script = scripts[_i];
      if (!((_ref = script.type) === '' || _ref === 'text/javascript')) {
        continue;
      }
      copy = document.createElement('script');
      _ref1 = script.attributes;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        attr = _ref1[_j];
        copy.setAttribute(attr.name, attr.value);
      }
      copy.appendChild(document.createTextNode(script.innerHTML));
      parentNode = script.parentNode, nextSibling = script.nextSibling;
      parentNode.removeChild(script);
      parentNode.insertBefore(copy, nextSibling);
    }
  };

  removeNoscriptTags = function(node) {
    node.innerHTML = node.innerHTML.replace(/<noscript[\S\s]*?<\/noscript>/ig, '');
    return node;
  };

  reflectNewUrl = function(url) {
    if ((url = new ComponentUrl(url)).absolute !== referer) {
      return window.history.pushState({
        turbolinks: true,
        url: url.absolute
      }, '', url.absolute);
    }
  };

  reflectRedirectedUrl = function() {
    var location, preservedHash;
    if (location = xhr.getResponseHeader('X-XHR-Redirected-To')) {
      location = new ComponentUrl(location);
      preservedHash = location.hasNoHash() ? document.location.hash : '';
      return window.history.replaceState(currentState, '', location.href + preservedHash);
    }
  };

  rememberReferer = function() {
    return referer = document.location.href;
  };

  rememberCurrentUrl = function() {
    return window.history.replaceState({
      turbolinks: true,
      url: document.location.href
    }, '', document.location.href);
  };

  rememberCurrentState = function() {
    return currentState = window.history.state;
  };

  recallScrollPosition = function(page) {
    return window.scrollTo(page.positionX, page.positionY);
  };

  resetScrollPosition = function() {
    if (document.location.hash) {
      return document.location.href = document.location.href;
    } else {
      return window.scrollTo(0, 0);
    }
  };

  popCookie = function(name) {
    var value, _ref;
    value = ((_ref = document.cookie.match(new RegExp(name + "=(\\w+)"))) != null ? _ref[1].toUpperCase() : void 0) || '';
    document.cookie = name + '=; expires=Thu, 01-Jan-70 00:00:01 GMT; path=/';
    return value;
  };

  triggerEvent = function(name, data) {
    var event;
    event = document.createEvent('Events');
    if (data) {
      event.data = data;
    }
    event.initEvent(name, true, true);
    return document.dispatchEvent(event);
  };

  pageChangePrevented = function() {
    return !triggerEvent('page:before-change');
  };

  processResponse = function() {
    var assetsChanged, clientOrServerError, doc, extractTrackAssets, intersection, validContent;
    clientOrServerError = function() {
      var _ref;
      return (400 <= (_ref = xhr.status) && _ref < 600);
    };
    validContent = function() {
      return xhr.getResponseHeader('Content-Type').match(/^(?:text\/html|application\/xhtml\+xml|application\/xml)(?:;|$)/);
    };
    extractTrackAssets = function(doc) {
      var node, _i, _len, _ref, _results;
      _ref = doc.head.childNodes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        if ((typeof node.getAttribute === "function" ? node.getAttribute('data-turbolinks-track') : void 0) != null) {
          _results.push(node.getAttribute('src') || node.getAttribute('href'));
        }
      }
      return _results;
    };
    assetsChanged = function(doc) {
      var fetchedAssets;
      loadedAssets || (loadedAssets = extractTrackAssets(document));
      fetchedAssets = extractTrackAssets(doc);
      return fetchedAssets.length !== loadedAssets.length || intersection(fetchedAssets, loadedAssets).length !== loadedAssets.length;
    };
    intersection = function(a, b) {
      var value, _i, _len, _ref, _results;
      if (a.length > b.length) {
        _ref = [b, a], a = _ref[0], b = _ref[1];
      }
      _results = [];
      for (_i = 0, _len = a.length; _i < _len; _i++) {
        value = a[_i];
        if (__indexOf.call(b, value) >= 0) {
          _results.push(value);
        }
      }
      return _results;
    };
    if (!clientOrServerError() && validContent()) {
      doc = createDocument(xhr.responseText);
      if (doc && !assetsChanged(doc)) {
        return doc;
      }
    }
  };

  extractTitleAndBody = function(doc) {
    var title;
    title = doc.querySelector('title');
    return [title != null ? title.textContent : void 0, removeNoscriptTags(doc.body), CSRFToken.get(doc).token, 'runScripts'];
  };

  CSRFToken = {
    get: function(doc) {
      var tag;
      if (doc == null) {
        doc = document;
      }
      return {
        node: tag = doc.querySelector('meta[name="csrf-token"]'),
        token: tag != null ? typeof tag.getAttribute === "function" ? tag.getAttribute('content') : void 0 : void 0
      };
    },
    update: function(latest) {
      var current;
      current = this.get();
      if ((current.token != null) && (latest != null) && current.token !== latest) {
        return current.node.setAttribute('content', latest);
      }
    }
  };

  browserCompatibleDocumentParser = function() {
    var createDocumentUsingDOM, createDocumentUsingParser, createDocumentUsingWrite, e, testDoc, _ref;
    createDocumentUsingParser = function(html) {
      return (new DOMParser).parseFromString(html, 'text/html');
    };
    createDocumentUsingDOM = function(html) {
      var doc;
      doc = document.implementation.createHTMLDocument('');
      doc.documentElement.innerHTML = html;
      return doc;
    };
    createDocumentUsingWrite = function(html) {
      var doc;
      doc = document.implementation.createHTMLDocument('');
      doc.open('replace');
      doc.write(html);
      doc.close();
      return doc;
    };
    try {
      if (window.DOMParser) {
        testDoc = createDocumentUsingParser('<html><body><p>test');
        return createDocumentUsingParser;
      }
    } catch (_error) {
      e = _error;
      testDoc = createDocumentUsingDOM('<html><body><p>test');
      return createDocumentUsingDOM;
    } finally {
      if ((testDoc != null ? (_ref = testDoc.body) != null ? _ref.childNodes.length : void 0 : void 0) !== 1) {
        return createDocumentUsingWrite;
      }
    }
  };

  ComponentUrl = (function() {
    function ComponentUrl(original) {
      this.original = original != null ? original : document.location.href;
      if (this.original.constructor === ComponentUrl) {
        return this.original;
      }
      this._parse();
    }

    ComponentUrl.prototype.withoutHash = function() {
      return this.href.replace(this.hash, '');
    };

    ComponentUrl.prototype.withoutHashForIE10compatibility = function() {
      return this.withoutHash();
    };

    ComponentUrl.prototype.hasNoHash = function() {
      return this.hash.length === 0;
    };

    ComponentUrl.prototype._parse = function() {
      var _ref;
      (this.link != null ? this.link : this.link = document.createElement('a')).href = this.original;
      _ref = this.link, this.href = _ref.href, this.protocol = _ref.protocol, this.host = _ref.host, this.hostname = _ref.hostname, this.port = _ref.port, this.pathname = _ref.pathname, this.search = _ref.search, this.hash = _ref.hash;
      this.origin = [this.protocol, '//', this.hostname].join('');
      if (this.port.length !== 0) {
        this.origin += ":" + this.port;
      }
      this.relative = [this.pathname, this.search, this.hash].join('');
      return this.absolute = this.href;
    };

    return ComponentUrl;

  })();

  Link = (function(_super) {
    __extends(Link, _super);

    Link.HTML_EXTENSIONS = ['html'];

    Link.allowExtensions = function() {
      var extension, extensions, _i, _len;
      extensions = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      for (_i = 0, _len = extensions.length; _i < _len; _i++) {
        extension = extensions[_i];
        Link.HTML_EXTENSIONS.push(extension);
      }
      return Link.HTML_EXTENSIONS;
    };

    function Link(link) {
      this.link = link;
      if (this.link.constructor === Link) {
        return this.link;
      }
      this.original = this.link.href;
      Link.__super__.constructor.apply(this, arguments);
    }

    Link.prototype.shouldIgnore = function() {
      return this._crossOrigin() || this._anchored() || this._nonHtml() || this._optOut() || this._target();
    };

    Link.prototype._crossOrigin = function() {
      return this.origin !== (new ComponentUrl).origin;
    };

    Link.prototype._anchored = function() {
      var current;
      return ((this.hash && this.withoutHash()) === (current = new ComponentUrl).withoutHash()) || (this.href === current.href + '#');
    };

    Link.prototype._nonHtml = function() {
      return this.pathname.match(/\.[a-z]+$/g) && !this.pathname.match(new RegExp("\\.(?:" + (Link.HTML_EXTENSIONS.join('|')) + ")?$", 'g'));
    };

    Link.prototype._optOut = function() {
      var ignore, link;
      link = this.link;
      while (!(ignore || link === document)) {
        ignore = link.getAttribute('data-no-turbolink') != null;
        link = link.parentNode;
      }
      return ignore;
    };

    Link.prototype._target = function() {
      return this.link.target.length !== 0;
    };

    return Link;

  })(ComponentUrl);

  Click = (function() {
    Click.installHandlerLast = function(event) {
      if (!event.defaultPrevented) {
        document.removeEventListener('click', Click.handle, false);
        return document.addEventListener('click', Click.handle, false);
      }
    };

    Click.handle = function(event) {
      return new Click(event);
    };

    function Click(event) {
      this.event = event;
      if (this.event.defaultPrevented) {
        return;
      }
      this._extractLink();
      if (this._validForTurbolinks()) {
        if (!pageChangePrevented()) {
          visit(this.link.href);
        }
        this.event.preventDefault();
      }
    }

    Click.prototype._extractLink = function() {
      var link;
      link = this.event.target;
      while (!(!link.parentNode || link.nodeName === 'A')) {
        link = link.parentNode;
      }
      if (link.nodeName === 'A' && link.href.length !== 0) {
        return this.link = new Link(link);
      }
    };

    Click.prototype._validForTurbolinks = function() {
      return (this.link != null) && !(this.link.shouldIgnore() || this._nonStandardClick());
    };

    Click.prototype._nonStandardClick = function() {
      return this.event.which > 1 || this.event.metaKey || this.event.ctrlKey || this.event.shiftKey || this.event.altKey;
    };

    return Click;

  })();

  bypassOnLoadPopstate = function(fn) {
    return setTimeout(fn, 500);
  };

  installDocumentReadyPageEventTriggers = function() {
    return document.addEventListener('DOMContentLoaded', (function() {
      triggerEvent('page:change');
      return triggerEvent('page:update');
    }), true);
  };

  installJqueryAjaxSuccessPageUpdateTrigger = function() {
    if (typeof jQuery !== 'undefined') {
      return jQuery(document).on('ajaxSuccess', function(event, xhr, settings) {
        if (!jQuery.trim(xhr.responseText)) {
          return;
        }
        return triggerEvent('page:update');
      });
    }
  };

  installHistoryChangeHandler = function(event) {
    var cachedPage, _ref;
    if ((_ref = event.state) != null ? _ref.turbolinks : void 0) {
      if (cachedPage = pageCache[(new ComponentUrl(event.state.url)).absolute]) {
        cacheCurrentPage();
        return fetchHistory(cachedPage);
      } else {
        return visit(event.target.location.href);
      }
    }
  };

  initializeTurbolinks = function() {
    rememberCurrentUrl();
    rememberCurrentState();
    createDocument = browserCompatibleDocumentParser();
    document.addEventListener('click', Click.installHandlerLast, true);
    return bypassOnLoadPopstate(function() {
      return window.addEventListener('popstate', installHistoryChangeHandler, false);
    });
  };

  historyStateIsDefined = window.history.state !== void 0 || navigator.userAgent.match(/Firefox\/2[6|7]/);

  browserSupportsPushState = window.history && window.history.pushState && window.history.replaceState && historyStateIsDefined;

  browserIsntBuggy = !navigator.userAgent.match(/CriOS\//);

  requestMethodIsSafe = (_ref = popCookie('request_method')) === 'GET' || _ref === '';

  browserSupportsTurbolinks = browserSupportsPushState && browserIsntBuggy && requestMethodIsSafe;

  browserSupportsCustomEvents = document.addEventListener && document.createEvent;

  if (browserSupportsCustomEvents) {
    installDocumentReadyPageEventTriggers();
    installJqueryAjaxSuccessPageUpdateTrigger();
  }

  if (browserSupportsTurbolinks) {
    visit = fetch;
    initializeTurbolinks();
  } else {
    visit = function(url) {
      return document.location.href = url;
    };
  }

  this.Turbolinks = {
    visit: visit,
    pagesCached: pagesCached,
    enableTransitionCache: enableTransitionCache,
    allowLinkExtensions: Link.allowExtensions,
    supported: browserSupportsTurbolinks
  };

}).call(this);











