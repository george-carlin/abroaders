$(document).ready(function () {
  $('.card_recommendation_decline_btn').click(function () {
    var $rec = $(this).closest('.card_recommendation');
    $rec.find('.card_recommendation_decline_form').show();
    $rec.find('.card_recommendation_apply_decline_btn_group').hide();
  });

  $('.card_recommendation_decline_confirm_btn').click(function (e) {
    var $rec = $(this).closest('.card_recommendation');
    $field  = $rec.find('.card_recommendation_decline_reason');
    $errMsg = $rec.find('.decline_card_recommendation_error_message');
    $declineReasonWrapper = $rec.find('.card_recommendation_decline_reason_wrapper');
    if (!$field.val().trim()) {
      e.preventDefault();
      $errMsg.show();
      $declineReasonWrapper.addClass('field_with_errors');
    } else {
      $errMsg.hide();
      $declineReasonWrapper.removeClass('field_with_errors');
    }
  });

  $('.card_recommendation_decline_cancel_btn').click(function (e) {
    e.preventDefault();
    var $rec = $(this).closest('.card_recommendation');
    $rec.find('.card_recommendation_decline_form').hide();
    $rec.find('.card_recommendation_apply_decline_btn_group').show();
  });
});
