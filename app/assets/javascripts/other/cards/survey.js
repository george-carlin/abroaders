/* global $ */
$(document).ready(function () {
  // Allow the user to check/uncheck the box by clicking anywhere within the
  // picture/description of the card:
  $(".cards_survey_card_opened").click(function (e) {
    var $this = $(this);
    var checked = $this.prop("checked");

    // Toggling this class will show/hide the 'opened at' and 'closed' inputs
    // via CSS.
    $this.closest(".card-survey-checkbox").toggleClass("opened", checked);
  });

  $(".cards_survey_card_closed").click(function () {
    var $this = $(this);
    var checked = $this.prop("checked");

    $this.closest(".card-survey-checkbox").toggleClass("closed", checked);
  });

  $("#card-survey-initial-yes-btn").click(function (e) {
    e.preventDefault();
    $("#card-survey-initial").hide();
    $("#card-survey-main-body").show();
    $("#card-survey-main-header").show();
  });

  $("#card-survey-initial-no-btn").click(function (e) {
    e.preventDefault();
    $("#card-survey-confirm-no").show();
    $("#card-survey-initial").hide();
  });

  $("#card-survey-confirm-no-back-btn").click(function (e) {
    e.preventDefault();
    $("#card-survey-confirm-no").hide();
    $("#card-survey-initial").show();
  });

  $('.collapse').on('shown.bs.collapse', function () {
    $(this)
        .closest('.bank-section')
          .find(".fa-sort-desc")
            .removeClass("fa-sort-desc")
            .addClass("fa-sort-asc");
  }).on('hidden.bs.collapse', function () {
    $(this)
        .closest('.bank-section')
          .find(".fa-sort-asc")
            .removeClass("fa-sort-asc")
            .addClass("fa-sort-desc");
  });
});
