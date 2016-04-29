$(document).ready(function () {
  $("#card_offer_condition").change(function () {
    switch ($(this).children(":selected").val()) {
      case "on_minimum_spend":
        $("#card_offer_spend_form_group").show();
        $("#card_offer_days_form_group").show()
        break;
      case "on_approval":
        $("#card_offer_spend_form_group").hide();
        $("#card_offer_days_form_group").hide()
        break;
      case "on_first_purchase":
        $("#card_offer_spend_form_group").hide();
        $("#card_offer_days_form_group").show()
        break;
    }
  });
});
