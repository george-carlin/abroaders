/* global $ */
$(document).ready(function () {
  $(".cards_survey_card_closed").click(function () {
    var checked = $(this).prop("checked");
    $('.card-survey-closed').toggleClass("hide", !checked);
  });
});
