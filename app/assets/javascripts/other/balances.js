var BalancesIndex = {
  showWhenEditing: ".edit_balance, .balance_value_editing",
  hideWhenEditing: ".edit_balance_btn, .balance_value, .destroy_balance_btn",
  errorMessage:    ".editing_balance_error_msg",

  hideEditBalanceForm: function (id) {
    var $balance = $("#balance_" + id);

    $balance.find(this.hideWhenEditing).show();
    $balance.find(this.showWhenEditing).hide();
    $balance.find(this.errorMessage).hide();
  },

  saveNewBalance: function (id, value) {
    $("#balance_" + id + " .balance_value").text(value);
    this.hideEditBalanceForm(id);
  },

  showEditBalanceForm: function (id) {
    var $balance = $("#balance_" + id);

    $balance.find(this.hideWhenEditing).hide();
    $balance.find(this.showWhenEditing).show();
  },

  showErrorMessage: function (id) {
    $("#balance_" + id).find(this.errorMessage).show();
  },
};

$(document).ready(function () {
  var $personBalances = $(".person_balances");

  // Start editing
  $personBalances.on("click", ".edit_balance_btn", function (e) {
    e.preventDefault();
    BalancesIndex.showEditBalanceForm(e.target.dataset.balanceId);
  });

  $personBalances.on("click", ".cancel_edit_balance_btn", function (e) {
    e.preventDefault();
    BalancesIndex.hideEditBalanceForm(e.target.dataset.balanceId);
  });

  $personBalances.on("ajax:beforeSend", ".edit_balance", function (e) {
    // Show spinner and disable buttons
    var $balance = $(this).closest('.editable_balance');
    $balance.find(".LoadingSpinner").show();
    $balance.find("button").prop("disabled", true);
  });

  $personBalances.on("ajax:complete", ".edit_balance", function (e) {
    // Hide spinner
    var $balance = $(this).closest('.editable_balance');
    $balance.find(".LoadingSpinner").hide();
    $balance.find("button").prop("disabled", false);
  });
});

window.BalancesIndex = BalancesIndex;
