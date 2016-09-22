$(document).ready(function () {
  $("#type_solo").click(function () {
    $(".partner-form").hide();
    $(".companion-field").prop("disabled", true);
  });

  $("#type_partner").click(function () {
    $(".partner-form").show();
    $(".companion-field").prop("disabled", false);
  });
});
