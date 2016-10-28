/* global $ */
$(document).ready(function () {
  function toggleCloseYear(closedYearElem, openedYearElem, openYear) {
    closedYearElem.find("option").each(function (index, elem) {
      if (parseInt(elem.value, 10) < openYear) {
        $(elem).hide();
      }
    });

    var optionSelector = "option[value=" + closedYearElem.val() + "]";
    if (closedYearElem.find(optionSelector).css("display") === "none") {
      closedYearElem.val(openedYearElem.val());
    }
  }

  function toggleCloseMonth(closedMonthElem, openedMonthElem, openMonth) {
    closedMonthElem.find("option").each(function (index, elem) {
      if (parseInt(elem.value, 10) < openMonth) {
        $(elem).hide();
      }
    });

    var optionSelector = "option[value=" + closedMonthElem.val() + "]";
    if (closedMonthElem.find(optionSelector).css("display") === "none") {
      closedMonthElem.val(openedMonthElem.val());
    }
  }

  function toggleDateSelect(parentElem) {
    var $openedYearElem = parentElem.find($(".cards_survey_card_account_opened_at_year")),
        $openedMonthElem = parentElem.find($(".cards_survey_card_account_opened_at_month")),
        $closedYearElem = parentElem.find($(".cards_survey_card_account_closed_at_year")),
        $closedMonthElem = parentElem.find($(".cards_survey_card_account_closed_at_month"));
    var closeYear = parseInt($closedYearElem.val(), 10),
        openYear = parseInt($openedYearElem.val(), 10),
        openMonth = parseInt($openedMonthElem.val(), 10);

    $closedYearElem.find("option").show();
    $closedMonthElem.find("option").show();

    toggleCloseYear($closedYearElem, $openedYearElem, openYear);

    if (closeYear === openYear) {
      toggleCloseMonth($closedMonthElem, $openedMonthElem, openMonth);
    }
  }

  $(".card_account_date").change(function () {
    toggleDateSelect($(this).parents(".card_account_wrapper"));
  });

  // Allow the user to check/uncheck the box by clicking anywhere within the
  // picture/description of the card:
  $(".cards_survey_card_account_opened").click(function (e) {
    var $this = $(this);
    var checked = $this.prop("checked");

    // Toggling this class will show/hide the 'opened at' and 'closed' inputs
    // via CSS.
    $this.closest(".card-survey-checkbox").toggleClass("opened", checked);
  });

  $(".cards_survey_card_account_closed").click(function () {
    var $this = $(this);
    var checked = $this.prop("checked");

    $this.closest(".card-survey-checkbox").toggleClass("closed", checked);

    toggleDateSelect($(this).parents(".card_account_wrapper"));
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
