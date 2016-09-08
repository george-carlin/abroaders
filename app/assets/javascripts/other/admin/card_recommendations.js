/* eslint no-param-reassign: 0 */

$(document).ready(function () {
  $(".new_card_account table").tablesorter({
    // The table can't be sorted by the first column:
    headers: { 0: { sorter: false } }
  });

  var $personCardTable = $("#admin_person_card_accounts_table");
  $personCardTable.tablesorter({
    headers: {
      0: { sorter: false }, // ID
      1: { sorter: false }, // Name
      2: { sorter: false }, // Status
      3: { sorter: true  }, // Rec'ed
      4: { sorter: false }, // Seen
      5: { sorter: false }, // Clicked
      6: { sorter: true },  // Applied
      7: { sorter: false }, // Denied
      8: { sorter: false }, // Declined
      9: { sorter: true },  // Opened
      10: { sorter: true }  // Closed
    }
  });

  $(".sortable-column.opened").trigger("click");
  $(".sortable-column.opened").click(function () {
    if (isDataExists($personCardTable.find(".card_account_opened_at")) == false) {
      sortColumn(6);
    }
    else {
      sortColumn(9);
    }
  });

  $(".sortable-column.closed").click(function () {
    if (isDataExists($personCardTable.find(".card_account_closed_at")) == false) {
      sortColumn(9);
    }
    else {
      sortColumn(10);
    }
  });

  $(".sortable-column.applied").click(function () {
    if (isDataExists($personCardTable.find(".card_account_applied_at")) == false) {
      sortColumn(9);
    }
    else {
      sortColumn(6);
    }
  });

  $(".sortable-column.recommended").click(function () {
    if (isDataExists($personCardTable.find(".card_account_recommended_at")) == false) {
      sortColumn(9);
    }
    else {
      sortColumn(3);
    }
  });

  function sortColumn(column_number) {
    $personCardTable.trigger("sorton", [ [[column_number,0]] ]);
  }

  function isDataExists(rows) {
    var is_exists = false;
    rows.each(function (i, row) {
      if (row.innerText != "-") {
        is_exists =  true;
      }
    });
    return is_exists;
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

  $('.card_currency_filter').click(function (e) {
    filterTable();
  });


  var $cardBankFilterCheckboxes = $('.card_bank_filter');
  $cardBankFilterCheckboxes.click(function (e) {
    // Show/hide the toggle all button:
    // If *all* other boxes are also checked:
    var allAreChecked = true;
    $cardBankFilterCheckboxes.each(function (i, checkbox) {
      if (checkbox.checked) {
        return true;
      } else {
        allAreChecked = false;
        return false; // Return false to break out of the each loop early.
      }
    });
    $("#card_bank_filter_all").prop("checked", allAreChecked);

    filterTable();
  });


  $("#card_bank_filter_all").click(function () {
    var that = this;
    $cardBankFilterCheckboxes.each(function (i, cb) {
      cb.checked = that.checked;
    });
    filterTable();
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
