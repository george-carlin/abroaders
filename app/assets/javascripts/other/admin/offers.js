$(document).ready(function () {
  $("#offer_condition").change(function () {
    switch ($(this).children(":selected").val()) {
      case "on_minimum_spend":
        $("#offer_spend_form_group").show();
        $("#offer_days_form_group").show()
        break;
      case "on_approval":
        $("#offer_spend_form_group").hide();
        $("#offer_days_form_group").hide()
        break;
      case "on_first_purchase":
        $("#offer_spend_form_group").hide();
        $("#offer_days_form_group").show()
        break;
    }
  });
});
