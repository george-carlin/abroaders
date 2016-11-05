$(document).ready(function () {
  var nameMaxLength = 50;
  $("#couples_account_form").submit(function (e) {
    var name = $("#account_companion_first_name").val().trim();
    if (name && name.length <= nameMaxLength) {
      $("#couples_account_form_error_msg").hide();
    } else {
      $("#couples_account_form_error_msg").show();
      e.preventDefault();
      // Rails UJS has disabled the submit button, so enable it again.
      $("#couples_account_form input[type=submit]").prop("disabled", false);
      // Or maybe UJS hasn't run yet, in which case make sure it doesn't:
      e.stopPropagation();
    }
  });
});
