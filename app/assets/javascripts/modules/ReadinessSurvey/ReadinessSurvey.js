$(document).ready(function () {
  $("[name='readiness_survey[main_passenger_ready]']").click(function () {
    const showReason = $(this).val() === "false";
    const $reason    = $("#main_passenger_unreadiness_reason_form_group");
    $reason.toggle(showReason);
    if (showReason) {
      $reason.focus();
    } else {
      $reason.val("")
    }
  });

  $("[name='readiness_survey[companion_ready]']").click(function () {
    const showReason = $(this).val() === "false";
    const $reason    = $("#companion_unreadiness_reason_form_group");
    $reason.toggle(showReason);
    if (showReason) {
      $reason.focus();
    } else {
      $reason.val("")
    }
  });
});
