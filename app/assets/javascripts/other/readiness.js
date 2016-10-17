$(document).ready(function () {
  var $unreadinessInputs = $(".unreadiness_reason_form_group");

  $(".readiness-radio").click(function () {
    $unreadinessInputs.hide();

    var readyPerson = $(this).find("input").val();
    switch (readyPerson) {
      case "owner":
        $(".unreadiness_reason_form_group.companion").show();
        break;
      case "companion":
        $(".unreadiness_reason_form_group.owner").show();
        break;
      case "neither":
        $unreadinessInputs.show();
        break;
    }
  });
});
