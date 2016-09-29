/* eslint no-param-reassign: 0 */

$(document).ready(function () {
  $(".new_card_account table").tablesorter({
    // The table can't be sorted by the first column:
    headers: { 0: { sorter: false } }
  });

  var $personCardTable = $("#admin_person_card_accounts_table");
  $personCardTable.tablesorter({
    headers: {
      0:  { sorter: false }, // ID
      1:  { sorter: false }, // Name
      2:  { sorter: false }, // Status
      3:  { sorter: true  }, // Rec'ed
      4:  { sorter: false }, // Seen
      5:  { sorter: false }, // Clicked
      6:  { sorter: true  }, // Applied
      7:  { sorter: false }, // Denied
      8:  { sorter: false }, // Declined
      9:  { sorter: true  }, // Opened
      10: { sorter: true  }  // Closed
    },
    sortList : [[9, 1], [6, 1]]
  });

  $(".sortable-column.opened").click(function () {
    sortColumn($(this), 9, 6);
  });

  $(".sortable-column.closed").click(function () {
    sortColumn($(this), 10, 9);
  });

  $(".sortable-column.applied").click(function () {
    sortColumn($(this), 6, 9);
  });

  $(".sortable-column.recommended").click(function () {
    sortColumn($(this), 3, 9);
  });

  function sortColumn(element, primary_column, secondary_column) {
    $(".sortable-column.sorted-column").removeClass("sorted-column");
    element.addClass("sorted-column");
    $personCardTable.trigger("sorton", [ [[primary_column, 1], [secondary_column, 1]] ]);
  }

  function filterTable() {
    var checkedBPs, checkedBanks, checkedCurrencies;

    checkedBPs = $(".card_bp_filter:checked").map(function (i, cb) {
      return cb.dataset.value;
    }).toArray();

    checkedBanks = $(".card_bank_filter:checked").map(function (i, cb) {
      return cb.dataset.value;
    }).toArray();

    var selector = ".card_currency_filter:checked";
    checkedCurrencies = $(selector).map(function (i, cb) {
      return cb.dataset.value;
    }).toArray();

    $("tr.admin_recommend_card").each(function (i, tr) {
      var bankIsShown = checkedBanks.indexOf(tr.dataset.bank) > -1,
          bpIsShown   = checkedBPs.indexOf(tr.dataset.bp) > -1,
          currIsShown = checkedCurrencies.indexOf(tr.dataset.currency) > -1,
          $cardTr  = $(tr),
          show = bankIsShown && bpIsShown && currIsShown;

      // Show/hide both the TR which contains information about the card, and
      // the TR which contains the nested table with the information about the
      // the card's offers.
      $cardTr
        .toggle(show)
        .next()
          .toggle(show);
    });

    $("tr.card_account").each(function (i, tr) {
      var bankIsShown = checkedBanks.indexOf(tr.dataset.bank) > -1;
      var bpIsShown   = checkedBPs.indexOf(tr.dataset.bp) > -1;
      var currIsShown = checkedCurrencies.indexOf(tr.dataset.currency) > -1;

      $(tr).toggle(bankIsShown && bpIsShown && currIsShown);
    });
  }

  $('.card_bp_filter').click(function (e) {
    filterTable();
  });

  function toggle_one(checkboxes, toggle_elem) {
    // Show/hide the toggle all button:
    // If *all* other boxes are also checked:
    var allAreChecked = true;
    checkboxes.each(function (i, checkbox) {
      if (checkbox.checked) {
        return true;
      } else {
        allAreChecked = false;
        return false; // Return false to break out of the each loop early.
      }
    });
    toggle_elem.prop("checked", allAreChecked);

    filterTable();
  }

  function toggle_all(toggle_elem, checkboxes) {
    checkboxes.each(function (i, cb) {
      cb.checked = toggle_elem.checked;
    });
    filterTable();
  }

  var $cardBankFilterCheckboxes = $('.card_bank_filter');
  $cardBankFilterCheckboxes.click(function (e) {
    toggle_one($cardBankFilterCheckboxes, $("#card_bank_filter_all"));
  });

  var $cardCurrencyFilterCheckboxes = $('.card_currency_filter');
  $cardCurrencyFilterCheckboxes.click(function (e) {
    var toggle_all_checkbox = $(this).closest(".panel-body").find(".toggle-all-currency-checkbox");
    toggle_one($cardCurrencyFilterCheckboxes, toggle_all_checkbox);
  });

  $("#card_bank_filter_all").click(function () {
    toggle_all(this, $cardBankFilterCheckboxes)
  });

  $(".toggle-all-currency-checkbox").click(function () {
    var checkboxes = $(this).closest(".panel-body").find(".card_currency_filter");
    toggle_all(this, checkboxes)
  });

  $(".recommend_offer_btn").click(function (e) {
    e.preventDefault();
    $(this)
      .hide()
      .siblings(".new_card_recommendation")
        .show();
  });

  $(".cancel_recommend_offer_btn").click(function (e) {
    e.preventDefault();
    $(this)
      .closest("form")
        .hide()
        .siblings(".recommend_offer_btn")
          .show();
  });
});
