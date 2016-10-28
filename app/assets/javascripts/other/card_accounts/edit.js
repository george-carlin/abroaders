/* global $ */
$(document).ready(function () {
  function toggleCloseYear(openYear) {
    var $closedYearElem = $("#card_account_closed_year");

    $closedYearElem.find("option").each(function (index, elem) {
      if (parseInt(elem.value, 10) < openYear) {
        $(elem).hide();
      }
    });

    var optionSelector = "option[value=" + $closedYearElem.val() + "]";
    if ($closedYearElem.find(optionSelector).css("display") === "none") {
      $closedYearElem.val($("#card_account_opened_year").val());
    }
  }

  function toggleCloseMonth(openMonth) {
    var $closedMonthElem = $("#card_account_closed_month");
    $closedMonthElem.find("option").each(function (index, elem) {
      if (parseInt(elem.value, 10) < openMonth) {
        $(elem).hide();
      }
    });

    var optionSelector = "option[value=" + $closedMonthElem.val() + "]";
    if ($closedMonthElem.find(optionSelector).css("display") === "none") {
      $closedMonthElem.val($("#card_account_opened_month").val());
    }
  }

  function toggleDateSelect() {
    var $closedYearElem = $("#card_account_closed_year"),
        $closedMonthElem = $("#card_account_closed_month");
    var openYear = parseInt($("#card_account_opened_year").val(), 10),
        openMonth = parseInt($("#card_account_opened_month").val(), 10),
        closeYear = parseInt($closedYearElem.val(), 10),
        closeMonth = parseInt($closedMonthElem.val(), 10);

    $closedYearElem.find("option").show();
    $closedMonthElem.find("option").show();

    toggleCloseYear(openYear, openMonth);

    if (closeYear === openYear) {
      toggleCloseMonth(openMonth, closeMonth);
    }
  }

  $(".card_account_date").change(function () {
    toggleDateSelect();
  });

  $(".cards_survey_card_account_closed").click(function () {
    var checked = $(this).prop("checked");
    $('.card-survey-closed').toggleClass("hide", !checked);

    toggleDateSelect();
  });
});
