$(document).ready(function () {
  $(".card_recommendation_decline_btn").click(function () {
    var $this = $(this);
    $this
      .closest(".card_recommendation_actions")
        .hide()
        .siblings(".decline_card_recommendation_form")
          .show();
  });


  $(".card_recommendation_cancel_decline_btn").click(function (e) {
    e.preventDefault();
    var $this = $(this),
    $form = $this.closest(".decline_card_recommendation_form");

    $form.find(".decline_card_recommendation_error_message").hide();
    $form.find(".card_account_decline_reason")
      .parent().removeClass("field_with_errors");
    $form.hide();

    $form.siblings(".card_recommendation_actions").show();
  });

  $(".card_recommendation_confirm_decline_btn").click(function (e) {
    var $this = $(this),
    $form  = $this.closest(".decline_card_recommendation_form"),
    $input = $form.find(".card_account_decline_reason");

    if ($input.val().trim()) {
      $form.find(".decline_card_recommendation_error_message").hide();
      $form.find(".card_account_decline_reason")
        .parent().removeClass("field_with_errors");
    } else {
      e.preventDefault();
      $form.find(".decline_card_recommendation_error_message").show();
      $form.find(".card_account_decline_reason")
        .parent().addClass("field_with_errors");
    }
  });
});
