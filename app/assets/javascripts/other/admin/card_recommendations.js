/* eslint no-param-reassign: 0 */

$(document).ready(function () {
  function filterTable() {
    var checkedBPs, checkedBanks;

    checkedBPs = $(".card_bp_filter:checked").map(function (i, cb) {
      return cb.dataset.value;
    }).toArray();

    checkedBanks = $(".card_bank_filter:checked").map(function (i, cb) {
      return cb.dataset.value;
    }).toArray();

    $("tr.admin_recommend_card_product").each(function (i, tr) {
      var bankIsShown = checkedBanks.indexOf(tr.dataset.bank) > -1,
          bpIsShown = checkedBPs.indexOf(tr.dataset.bp) > -1,
          $cardTr = $(tr);

      // Show/hide both the TR which contains information about the card, and
      // the TR which contains the nested table with the information about the
      // the card's offers.
      $cardTr
        .toggle(bankIsShown && bpIsShown)
        .next()
          .toggle(bankIsShown && bpIsShown);
    });

    // Show/hide the person's existing card accounts too. Note that we only
    // filter their card accounts, not their card recommendations; this is a
    // deliberate choice.
    $("#admin_person_card_accounts_table tbody tr").each(function (i, tr) {
      var bankIsShown = checkedBanks.indexOf(tr.dataset.bank) > -1;
      var bpIsShown   = checkedBPs.indexOf(tr.dataset.bp) > -1;

      $(tr).toggle(bankIsShown && bpIsShown);
    });
  }

  $('.card_bp_filter').click(function (e) {
    filterTable();
  });

  function toggleOne(checkboxes, toggleElem) {
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
    toggleElem.prop("checked", allAreChecked);

    filterTable();
  }

  function toggleAll(toggleElem, checkboxes) {
    checkboxes.each(function (i, cb) {
      cb.checked = toggleElem.checked;
    });
    filterTable();
  }

  var $cardBankFilterCheckboxes = $('.card_bank_filter');
  $cardBankFilterCheckboxes.click(function () {
    toggleOne($cardBankFilterCheckboxes, $("#card_bank_filter_all"));
  });

  var $cardCurrencyFilterCheckboxes = $('.card_currency_filter');
  $cardCurrencyFilterCheckboxes.click(function () {
    var toggleAllCheckbox = $(this).closest(".panel-body").find(".toggle-all-currency-checkbox");
    toggleOne($cardCurrencyFilterCheckboxes, toggleAllCheckbox);
  });

  $("#card_bank_filter_all").click(function () {
    toggleAll(this, $cardBankFilterCheckboxes);
  });

  $(".toggle-all-currency-checkbox").click(function () {
    var checkboxes = $(this).closest(".panel-body").find(".card_currency_filter");
    toggleAll(this, checkboxes);
  });
});
