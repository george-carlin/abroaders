/* eslint no-param-reassign: 0 */

$(document).ready(function () {
  // Hide and show the person's card accounts, and the recommendable offers,
  // when the admin changes the filter options.
  //
  // This is split into two parts. First, when the admin changes a filter
  // option (e.g. checks/unchecks a checkbox), the JS will update the *other*
  // fields in the filter options form accordingly - e.g. by turning on the
  // 'toggle all' checkbox if they manually check every other box individually.
  //
  // Once the form fields have been updated, the function
  // updateFilteredElements is called, which shows/hides the card accounts and
  // offers based on the current state of the form fields.
  //
  // This separates the display logic for the form from the display logic for
  // the cards/offers, with only a minimal coupling between these two concerns.

  function updateFilteredElements() {
    var checkedBPs, checkedBanks, maxSpend;

    checkedBPs = $(".card_bp_filter:checked").map(function (i, cb) {
      return cb.dataset.value;
    }).toArray();

    checkedBanks = $(".card_bank_filter:checked").map(function (i, cb) {
      return cb.dataset.value;
    }).toArray();

    maxSpend = parseInt($('#card_spend_filter').val(), 10);

    $('tr.admin_recommend_offer').each(function (i, offerTr) {
      var spend = parseInt(offerTr.dataset.offerSpend, 10);
      // if the max spend input is blank then we don't want to filter out any
      // offers by their spend. We'll know the input was blank if parseInt
      // returned an NaN.
      var visible = isNaN(maxSpend) ? true : spend <= maxSpend;
      $(this)
        .toggle(visible)
        // See below for notes on what this data attr is for:
        .data('visible', visible);
    });

    $("tr.admin_recommend_card_product").each(function (i, tr) {
      var $this = $(this);

      // If all the product's offers have been hidden by the max spend filter,
      // we can hide the product entirely, and we don't need to check its bank
      // and BP. However, checking whether each offer is ':visible' won't work
      // because if the *product* was hidden by a previous filter, all offers
      // will be hidden even if they weren't hidden by the max spend filter.
      //
      // To get around this, the max spend filter sets a data attribute on each
      // offer's TR, and we check for that data attribute here rather than
      // looking at the TR's 'real' visibility in the DOM.
      var $offers = $this.next().find('.admin_recommend_offer');
      var anyOffersAreVisible = _.any($offers, function (offer) {
        // we have to use jQuery's 'data' method rather than just calling
        // .dataset on the plain DOM element, because data attributes set
        // by jQuery can only be read by jQuery
        return $(offer).data('visible');
      });

      if (anyOffersAreVisible) {
        // show the product (in case it was hidden by a previous filter update)
        $this.show();
        $this.next().show();
      } else {
        $this.hide();
        // hide the TR that contains the offers. It's adjacent to the product's
        // TR, not contained within it:
        $this.next().hide();
        // No need to check the product's bank or BP; skip to next row:
        return true;
      }

      var bankIsShown = checkedBanks.indexOf(tr.dataset.bank) > -1;
      var bpIsShown = checkedBPs.indexOf(tr.dataset.bp) > -1;
      var $cardTr = $(tr);

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


  // the checkboxes for each bank
  var $bankFilterCBs = $('.card_bank_filter');
  var $toggleAllBanksCB = $("#card_bank_filter_all");
  $bankFilterCBs.click(function () {
    // Show the toggle all button iff *all* banks are checked:
    var all = $bankFilterCBs.length === $bankFilterCBs.filter(':checked').length;
    $toggleAllBanksCB.prop("checked", all);
    updateFilteredElements();
  });

  $toggleAllBanksCB.click(function () {
    var toggleAllCB = this;
    $bankFilterCBs.each(function (i, cb) {
      cb.checked = toggleAllCB.checked;
    });
    updateFilteredElements();
  });

  $('.card_bp_filter').click(function (e) {
    updateFilteredElements();
  });

  $('.card_bank_only_filter').click(function (e) {
    var bankId = this.dataset.value;
    $toggleAllBanksCB.prop('checked', false);
    $bankFilterCBs.prop('checked', false);
    $("#card_bank_filter_" + bankId).prop('checked', true);
    updateFilteredElements();
  });

  var $cardSpendFilter = $('#card_spend_filter');
  $cardSpendFilter.on('input', updateFilteredElements);
});
