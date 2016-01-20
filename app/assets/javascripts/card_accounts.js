window.ready(function () {
  $("#new_card_account input[name='create_mode']").click(function () {
    if (this.value === "recommendation") {
      document.getElementById("card_account_status").style.display = "none";
    } else {
      document.getElementById("card_account_status").style.display = "";
    }
  });
});
