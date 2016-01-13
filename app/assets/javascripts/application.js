// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap.min
//= require bootstrap3-typeahead
//= require bootstrap-datepicker
//= require humps
//= require react
//= require react_ujs
//= require components
//= require_tree .

if (!Function.prototype.bind) {
  Function.prototype.bind = function(oThis) {
    if (typeof this !== 'function') {
      // closest thing possible to the ECMAScript 5
      // internal IsCallable function
      throw new TypeError('Function.prototype.bind - what is trying to be bound is not callable');
    }

    var aArgs   = Array.prototype.slice.call(arguments, 1),
      fToBind = this,
        fNOP    = function() {},
          fBound  = function() {
            return fToBind.apply(this instanceof fNOP
              ? this
              : oThis,
              aArgs.concat(Array.prototype.slice.call(arguments)));
          };

          if (this.prototype) {
            // native functions don't have a prototype
            fNOP.prototype = this.prototype; 
          }
          fBound.prototype = new fNOP();

          return fBound;
  };
}
