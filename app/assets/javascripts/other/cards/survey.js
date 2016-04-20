$(document).ready(function () {

  // Allow the user to check/uncheck the box by clicking anywhere within the
  // picture/description of the card:
  $(".cards_survey_card_account_opened").click(function (e) {
    var $this = $(this);
    var checked = $this.prop("checked")

    // Toggling this class will show/hide the 'opened at' and 'closed' inputs
    // via CSS.
    $this.closest(".card-survey-checkbox").toggleClass("opened", checked);
  });


  $(".cards_survey_card_account_closed").click(function () {
    var $this = $(this);
    var checked = $this.prop("checked")

    $this.closest(".card-survey-checkbox").toggleClass("closed", checked);
  });

});
