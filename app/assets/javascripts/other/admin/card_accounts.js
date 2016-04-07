$(document).ready(function () {
  $("#new_card_account input[name='create_mode']").click(function () {
    var form_group = document.getElementById("card_account_status_form_group");
    if (this.value === "recommendation") {
      form_group.style.display = "none";
    } else {
      form_group.style.display = "";
    }
  });


  $(".card-survey-checkbox").click(function (e) {
    var $checkbox = $(this).find("input[type=checkbox]");
    // The click handler will be called when the user clicks *anywhere* within
    // the <div>, but if they have clicked specifically on the checkbox, we
    // DON'T want to check/uncheck it via jQuery, because it's about to be
    // checked/unchecked anyway. Without wrapping this in a if statement, the
    // checkbox would be checked and then immediately unchecked.
    if (e.target.nodeName !== "INPUT") {
      $checkbox.prop("checked", !$checkbox.prop("checked"));;
    }
  });

});
