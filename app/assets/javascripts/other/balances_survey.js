/* global $ */

$(document).ready(function () {
  $(".currency_balance_checkbox").click(function () {
    var $this  = $(this);
    var $textField = $this.closest(".currency").find(".currency_balance_value");
    var checked    = $this.is(":checked");

    $textField
      // Disable the input if it's hidden to make sure the value doesn't get
      // submitted.
      .prop("disabled", !checked)
      .toggle(checked);
  });

  $("#balances-survey-initial-yes-btn").click(function (e) {
    e.preventDefault();
    $("#balances-survey-initial").hide();
    $("#balances-survey-main").show();
  });

  $("#balances-survey-initial-no-btn").click(function (e) {
    e.preventDefault();
    $("#balances-survey-confirm-no").show();
    $("#balances-survey-initial").hide();
  });

  $("#balances-survey-confirm-no-back-btn").click(function (e) {
    e.preventDefault();
    $("#balances-survey-confirm-no").hide();
    $("#balances-survey-initial").show();
  });
});
