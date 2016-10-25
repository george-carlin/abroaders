$(document).ready(function () {
  $("input[name='readiness_survey[who]']").click(function () {
    var showOwnerUnreadiness, showCompanionUnreadiness;
    switch ($(this).val()) {
      case "both":
        showCompanionUnreadiness = false;
        showOwnerUnreadiness     = false;
        break;
      case "owner":
        showCompanionUnreadiness = true;
        showOwnerUnreadiness     = false;
        break;
      case "companion":
        showCompanionUnreadiness = false;
        showOwnerUnreadiness     = true;
        break;
      case "neither":
        showCompanionUnreadiness = true;
        showOwnerUnreadiness     = true;
        break;
    }
    $("#readiness_survey_owner_unreadiness_reason_form_group").toggle(showOwnerUnreadiness);
    $("#readiness_survey_companion_unreadiness_reason_form_group").toggle(showCompanionUnreadiness);
  });
});
