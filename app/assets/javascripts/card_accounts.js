window.ready(function () {
  $("#new_card_account input[name='create_mode']").click(function () {
    var form_group = document.getElementById("card_account_status_form_group");
    if (this.value === "recommendation") {
      form_group.style.display = "none";
    } else {
      form_group.style.display = "";
    }
  });


  $(".card-survey-checkbox").click(function () {
    var $checkbox = $(this).find("input[type=checkbox]");
    $checkbox.prop("checked", !$checkbox.prop("checked"));;
  });

});
