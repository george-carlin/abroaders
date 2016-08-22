/* eslint no-param-reassign: 0 */

$(document).ready(function () {
  $(".new_card_account table").tablesorter({
    // The table can't be sorted by the first column:
    headers: { 0: { sorter: false } },
  });


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
      .siblings(".confirm_cancel_offer_wrapper")
        .show();
  });

  $(".cancel_recommend_offer_btn").click(function (e) {
    e.preventDefault();
    $(this)
      .parent()
        .hide()
        .siblings(".recommend_offer_btn")
            .show();
  });
});
