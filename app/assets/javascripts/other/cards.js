$(document).ready(function () {
  function toggleStage1Btns(accountId, show) {
    var css = show ? "" : "none";

    document.getElementById(
      "card_" + accountId + "_find_card_btn"
    ).style.display = css;
    document.getElementById(
      "card_" + accountId + "_applied_btn"
    ).style.display = css;
    document.getElementById(
      "card_" + accountId + "_decline_btn"
    ).style.display = css;
  }


  function toggleStage2Btns(accountId, show) {
    var css = show ? "" : "none";

    document.getElementById(
      "card_" + accountId + "_application_result_btns"
    ).style.display = css;
  }


  // When the user clicks the 'I have applied' button:
  $(".card-account-have-applied-btn").click(function () {
    var accountId  = this.dataset.cardAccountId;

    // Hide the current buttons:
    toggleStage1Btns(accountId, false);
    toggleStage2Btns(accountId, true);
  });


  $(".card-account-applied-back-btn").click(function () {
    var accountId  = this.dataset.cardAccountId;

    // Hide the current buttons:
    toggleStage1Btns(accountId, true);
    toggleStage2Btns(accountId, false);
  });


  $(".card-account-pending-btn").click(function () {
    var accountId  = this.dataset.cardAccountId;

    toggleStage2Btns(accountId, false);

    document.getElementById(
      "card_" + accountId + "_pending_notification"
    ).style.display = "";
  });
});
