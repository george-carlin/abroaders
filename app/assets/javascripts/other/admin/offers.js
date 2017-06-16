$(document).ready(function () {
  $("#offer_condition").change(function () {
    switch ($(this).children(":selected").val()) {
      case "on_minimum_spend":
        $("#offer_spend_form_group").show();
        $("#offer_points_awarded_form_group").show();
        $("#offer_days_form_group").show();
        break;
      case "on_approval":
        $("#offer_spend_form_group").hide();
        $("#offer_points_awarded_form_group").show();
        $("#offer_days_form_group").hide();
        break;
      case "on_first_purchase":
        $("#offer_points_awarded_form_group").show();
        $("#offer_spend_form_group").hide();
        $("#offer_days_form_group").show();
        break;
      case "no_bonus":
        $("#offer_points_awarded_form_group").hide();
        $("#offer_spend_form_group").hide();
        $("#offer_days_form_group").hide();
        break;
    }
  });

  // Review page:
  $('.replace_offer_check_box').click(function () {
    var $cb = $(this);
    var replacementId = $cb.val();
    var $killBtn = $cb.closest('tr').find('.kill_offer_btn');

    if ($cb.prop('checked')) {
      $killBtn.text('Kill & Replace');
      $killBtn.data('params', { replacement_id: replacementId });
    } else {
      $killBtn.text('Kill');
      $killBtn.data('params', '');
    }
  });
});
