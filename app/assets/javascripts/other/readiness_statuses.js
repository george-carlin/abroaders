$(document).ready(function () {
  $("[name='person[ready]']").click(function () {
    var showReason = $(this).val() === "false";
    var $reason    = $("#unreadiness_reason_form_group");
    $reason.toggle(showReason);
    if (showReason) {
      $reason.focus();
    } else {
      $reason.val("")
    }
  });
});
