$(document).ready(function () {
  $("input[name*=has_business]").click(function () {
    $("#business_spending_form_group")
      .toggle(
        ["with_ein", "without_ein"].indexOf(this.value) > -1
      );
  });
});
