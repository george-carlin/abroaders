$(document).ready(function () {

  function isValidMonthlySpend(value) {
    return (
      // Looks like a valid number:
      /^-?[0-9,]+(\.[0-9]+)?$/.test(value.trim()) &&
        // Strip any commas and validate is >= 0
        parseInt(value.replace(/,/g, ''), 10) >= 0
    )
  }

  $(".partner_account_person_0_first_name").text(
    $("#person_0_name_hidden_input").val()
  );


  // ------ SOLO ACCOUNTS  ------

  $("#solo_account_step_0_submit_btn").click(function (e) {
    e.preventDefault();
    $("#solo_account_step_0").hide();
    $("#solo_account_step_1").show();
  });

  $(".solo_account_eligible_to_apply").click(function (e) {
    if ($(this).val() === "true") {
      $("#solo_account_monthly_spending_form_group").show();
      $("#solo_account_not_eligible_help_text").hide();
    } else {
      $("#solo_account_monthly_spending_form_group").hide();
      $("#solo_account_not_eligible_help_text").show();
    }
  });


  $("#solo_account_submit_btn").click(function (e) {
    var monthlySpendVal = $("#solo_account_monthly_spending_usd").val();
    if (isValidMonthlySpend(monthlySpendVal)) {
      $("#solo_account_invalid_monthly_spending_alert").hide();
    } else {
      $("#solo_account_invalid_monthly_spending_alert").show();
      e.preventDefault();
    }
  });


  // ------ PARTNER ACCOUNTS  ------

  var partnerName;

  $("#partner_account_step_0_submit_btn").click(function (e) {
    e.preventDefault();

    partnerName = $("#partner_account_partner_first_name").val().trim();
    if (partnerName.length) {
      $("#partner_account_invalid_partner_name_alert").hide()
      $("#partner_account_step_0").hide()
      $("#partner_account_step_1").show()
      $(".partner_account_person_1_first_name").text(partnerName);
    } else {
      $("#partner_account_invalid_partner_name_alert").show()
    }
  });

  $(".partner_account_eligibility").click(function () {
    var val = $(this).val();
    if (val === "person_0") {
      $("#only_one_eligible_person_0_name").show()
      $("#only_one_eligible_person_1_name").hide()
      $("#partner_account_only_one_person_eligible_help_text").show()
      $("#partner_account_monthly_spending_form_group").show()
      $("#partner_account_not_eligible_help_text").hide()
    } else if (val === "person_1") {
      $("#only_one_eligible_person_0_name").hide()
      $("#only_one_eligible_person_1_name").show()
      $("#partner_account_only_one_person_eligible_help_text").show()
      $("#partner_account_monthly_spending_form_group").show()
      $("#partner_account_not_eligible_help_text").hide()
    } else if (val === "neither") {
      $("#partner_account_monthly_spending_form_group").hide()
      $("#partner_account_not_eligible_help_text").show()
    } else if (val === "both") {
      $("#partner_account_only_one_person_eligible_help_text").hide()
      $("#partner_account_monthly_spending_form_group").show()
      $("#partner_account_not_eligible_help_text").hide()
    }
  });


  $("#partner_account_submit_btn").click(function (e) {
    var $monthlySpend = $("#partner_account_monthly_spending_usd");
    var monthlySpendVal = $("#partner_account_monthly_spending_usd").val();

    if ($monthlySpend.is(":visible") && !isValidMonthlySpend(monthlySpendVal)) {
      $("#partner_account_invalid_monthly_spending_alert").show();
      e.preventDefault();
    } else {
      $("#partner_account_invalid_monthly_spending_alert").hide();
    }
  });

});
