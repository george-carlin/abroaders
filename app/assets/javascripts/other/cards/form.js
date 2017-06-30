/* global $ */
$(document).ready(function () {
  $("input#card_closed").click(function () {
    var closed = $(this).prop("checked");
    $('.card-survey-closed').toggleClass("hide", !closed);
    // Disable the closed_on inputs when necessary, so they don't get submitted
    $('[name^="card[closed_on"]').prop({ disabled: !closed });
  });
});
