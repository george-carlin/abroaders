window.BalancesIndex = {
  showWhenEditing: ".editing_balance_btn_group, .balance_value_editing",
  hideWhenEditing: ".edit_balance_btn, .balance_value",
  errorMessage:    ".editing_balance_error_msg",

  hideEditBalanceForm: function (id) {
    var $balance = $("#balance_" + id);

    $balance.find(BalancesIndex.hideWhenEditing).show();
    $balance.find(BalancesIndex.showWhenEditing).hide();
    $balance.find(BalancesIndex.errorMessage).hide();
  },

  saveNewBalance: function (id, value) {
    $("#balance_" + id + " .balance_value").text(value);
    BalancesIndex.hideEditBalanceForm(id);
  },

  showEditBalanceForm: function (id) {
    var $balance = $("#balance_" + id);

    $balance.find(BalancesIndex.hideWhenEditing).hide();
    $balance.find(BalancesIndex.showWhenEditing).show();
  },

  showErrorMessage: function (id) {
    $("#balance_" + id).find(BalancesIndex.errorMessage).show();
  },
}

$(document).ready(function () {

  $personBalances = $(".person_balances");

  // Start editing
  $personBalances.on("click", ".edit_balance_btn", function (e) {
    e.preventDefault();
    BalancesIndex.showEditBalanceForm(e.target.dataset.balanceId)
  });

  $personBalances.on("click", ".cancel_edit_balance_btn", function (e) {
    e.preventDefault();
    BalancesIndex.hideEditBalanceForm(e.target.dataset.balanceId)
  });

  $personBalances.on("ajax:beforeSend", ".edit_balance", function (e) {
    // Show spinner and disable buttons
    var $this = $(this);
    $this.find(".LoadingSpinner").show();
    $this.find("button").prop("disabled", true);
  });

  $personBalances.on("ajax:complete", ".edit_balance", function (e) {
    // Hide spinner
    var $this = $(this);
    $this.find(".LoadingSpinner").hide();
    $this.find("button").prop("disabled", false);
  });
});
