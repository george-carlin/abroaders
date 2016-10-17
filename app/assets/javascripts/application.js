// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts,
// vendor/assets/javascripts, or any plugin's vendor/assets/javascripts
// directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
// TODO we're loading too much goddam javascript! And I'm sure some
// of this isn't even being used.
//
//= require jquery2
//= require jquery_ujs
//= require bootstrap.min
//= require bootstrap-datepicker
//= require jquery.tablesorter
//= require underscore
//= require metisMenu
//= require typeahead.bundle.js
//= require jquery.countdown.min.js
//= require components/react_ujs
//= require_tree ./other

// Load all browserify modules below.

// Polyfill must be loaded before everything else.
require("babel-polyfill");

// I really don't like this 'hybrid of Sprockets and Node' setup that we have,
// but I'm still learning Node/Browserify etc and haven't figured out the
// best way to handle things yet. The long-term solution will probably be
// to move away from Sprockets and use the Node-y approach for everything,
// but it's not worth the effort for now.

window.components = {
  AccountTypeForm:       require("./components/AccountTypeForm"),
  AccountPage:           require("./components/AccountPage"),
  CardApplicationSurvey: require("./components/CardApplicationSurvey"),
  PointsEstimateTable:   require("./components/PointsEstimateTable"),
};

window.numbro = require("numbro");
window.diacritics = require("diacritics");

// Note that something more DRY like this won't work:
//
// window.components = {}
//
// _.each([
//   "CardAccountApplyOrDecline",
//   "CardApplicationSurvey",
//   "AccountTypeForm"
//  ], function (name) {
//   window.components[name] = require(`./components/${name}`);
// });
//
// ... because Browserify's 'require' statement must be passed a string literal.
//
// See https://stackoverflow.com/questions/26434214/
