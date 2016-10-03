$(document).ready(function () {
  var $unreadiness_inputs = $(".unreadiness_reason_form_group");

  $(".readiness-radio").click(function () {
    $unreadiness_inputs.hide();

    var ready_person = $(this).find("input").val();
    switch (ready_person) {
      case "owner":
        $(".unreadiness_reason_form_group.companion").show();
        break;
      case "companion":
        $(".unreadiness_reason_form_group.owner").show();
        break;
      case "neither":
        $unreadiness_inputs.show();
        break;
    }
  });
});
