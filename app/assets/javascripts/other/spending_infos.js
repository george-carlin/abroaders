$(document).ready(function () {
  $("input[name*=has_business]").click(function () {
    // on edit page:
    $("#business_spending_form_group")
      .toggle(
        ["with_ein", "without_ein"].indexOf(this.value) > -1
      );
  });

  $('.spending_info_owner_has_business').click(function () {
    $("#owner_business_spending_form_group")
      .toggle(
        ["with_ein", "without_ein"].indexOf(this.value) > -1
      );
  });

  $('.spending_info_companion_has_business').click(function () {
    $("#companion_business_spending_form_group")
      .toggle(
        ["with_ein", "without_ein"].indexOf(this.value) > -1
      );
  });
});
