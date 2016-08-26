$(document).ready(function () {
  $("[name='spending_info[ready]']").click(function () {
    var showReason = $(this).val() === "false";
    var $reason    = $("#unreadiness_reason_form_group");
    $reason.toggle(showReason);
    if (showReason) {
      $reason.focus();
    } else {
      $reason.val("");
    }
  });

  $("input[name*=has_business]").click(function () {
    $("#business_spending_form_group")
      .toggle(
        ["with_ein", "without_ein"].indexOf(this.value) > -1
      );
  });
});
