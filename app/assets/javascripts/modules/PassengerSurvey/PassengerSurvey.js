const $ = require("jquery");
const _ = require("underscore");

$(document).ready(function () {
  // TODO this belongs in a different JS file methinks:
//const inputName = "passenger_survey[main_passenger_attributes][has_business]";
//// TODO: this interpolated string syntax works in the browser but fails
//// silently in tests (in fact, it makes the entire suite of JS tests fail
//// with no error message, which wasn't fun to debug.). Either this needs
//// transpiling, or the tests need updating to handle ES6 syntax better, or
//// both.
//// $(`input[name="${inputName}"]`).click(function () {)
//$("input[name='" + inputName + "']").click(function () {
//  $(this)
//    .closest(".passenger-spending-info-fields")
//    .find(".business_spending_form_group")
//      .toggle(
//        ["with_ein", "without_ein"].indexOf(this.value) > -1
//      );
//});

  $("#passenger_survey_has_companion").click(function () {
    var slideFunc;
    if ($(this).is(":checked")) {
      slideFunc = "slideDown";
    } else {
      slideFunc = "slideUp";
    }
    $(
      "#passenger_survey_willing_to_apply, " +     
      "#passenger_survey_companion_contact_info"
    )[slideFunc]()
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
