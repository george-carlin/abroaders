const $ = require("jquery");

$(document).ready(function () {

  $(".currency_balance_checkbox").click(function () {
    var $this  = $(this),
    $textField = $this.closest(".currency").find(".currency_balance_value"),
    checked    = $this.is(":checked");

    $textField
      // Disable the input if it's hidden to make sure the value doesn't get
      // submitted.
      .prop("disabled", !checked)
      .toggle(checked);
  });
  
});

// Nothing to export
