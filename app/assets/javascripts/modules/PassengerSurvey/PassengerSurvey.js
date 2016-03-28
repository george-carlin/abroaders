const $ = require("jquery");
const _ = require("underscore");

$(document).ready(function () {

  $("#passenger_survey_has_companion").click(function () {
    if ($(this).is(":checked")) {
      $("#companion_survey").slideDown();
    } else {
      $("#companion_survey").slideUp();
    }
  });

  // The four 'are you/is your companion willing to apply for cards' radios:
  $("input[name*='willing_to_apply']").click(function () {
    const $errMsg = $("#unwilling_to_apply_err_msg");

    const $nos    = $("input[name*='willing_to_apply'][value=false]")
    // If 'no' has been selected for both main and companion passenger:
    if (_.all($nos, (radio) => radio.checked)) {
      $errMsg.show();
      // Disable all inputs except the 'willing' radios:
      $("input:not([name*=willing_to_apply]), select, button")
        .prop("disabled", true)
    } else {
      $errMsg.hide();
      // Reenable all the other inputs:
      $("input:not([name*=willing_to_apply]), select, button")
        .prop("disabled", false)
    }
  });
});

// Nothing to export
