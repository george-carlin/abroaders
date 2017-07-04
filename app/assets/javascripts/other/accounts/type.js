$(document).ready(function () {
  function showError(e, msg) {
    $("#couples_account_form_error_msg").text(msg).show();
    e.preventDefault();
    // Rails UJS has disabled the submit button, so enable it again.
    $("#couples_account_form input[type=submit]").prop("disabled", false);
    // Or maybe UJS hasn't run yet, in which case make sure it doesn't:
    e.stopPropagation();
  }

  var nameMaxLength = 50;

  $("#couples_account_form").submit(function (e) {
    var name = $("#account_companion_first_name").val().trim();
    var ownerName = $("#couples_account_form").data('ownerFirstName');
    if (!name) {
      showError(e, 'Please enter a valid name');
    } else if (name.length > nameMaxLength) {
      showError(e, 'Name is too long - must be 50 characters or less');
    } else if (name.toLowerCase() === ownerName.toLowerCase()) {
      showError(e, 'Names must be unique');
    } else {
      $("#couples_account_form_error_msg").hide();
    }
  });
});
