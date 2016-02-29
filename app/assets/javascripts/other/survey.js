$(document).ready(function () {

  $('input[name="survey[has_business]"]').click(function () {
    $("#business_spending_form_group").toggle(
      this.value === "with_ein" || this.value === "without_ein"
    )
  });

});
