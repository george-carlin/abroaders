$(document).ready(function () {
  $(".new_card_account table").tablesorter({
    // The table can't be sorted by the first column:
    headers: { 0: { sorter: false } }
  });


  function filterTable() {
    var checkedBPs, checkedBanks, checkedCurrencies;

    checkedBPs = $(".card_bp_filter:checked").map(function (i, cb) {
      return cb.dataset.value;
    }).toArray(),

    checkedBanks = $(".card_bank_filter:checked").map(function (i, cb) {
      return cb.dataset.value;
    }).toArray();


    var selector = ".card_currency_filter:checked"
    checkedCurrencies = $(selector).map(function (i, cb) {
      return cb.dataset.value;
    }).toArray();

    $("tr.admin_recommend_card").each(function (i, tr) {
      var bankIsShown = checkedBanks.indexOf(tr.dataset.bank) > -1;
          bpIsShown   = checkedBPs.indexOf(tr.dataset.bp) > -1;
          currIsShown = checkedCurrencies.indexOf(tr.dataset.currency) > -1;
          $tr = $(tr);

      if (bankIsShown && bpIsShown && currIsShown) {
        // Check whether or not the TR is already visible/hidden
        // before calling show/hide, so the 'dummy' <tr>s get added/removed
        // in the right places.
        if (!$tr.is(":visible")) {
          // Remove the dummy <tr> added below.
          $tr.show().next().remove();
        }
      } else {
        if ($tr.is(":visible")) {
          // Add a dummy element after this one so that the Bootstrap
          // .table-striped classes don't get messed up. See
          // http://stackoverflow.com/a/20580140/1603071
          // $tr.hide();
          $tr.after('<tr></tr>').hide();
        }
      }
    });
  };


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
    debugger;
    $cardBankFilterCheckboxes.each(function (i, cb) {
      cb.checked = that.checked;
    });
    filterTable();
  });


});
