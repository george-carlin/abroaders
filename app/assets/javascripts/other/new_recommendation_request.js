$(document).ready(function () {
  // ---- CREDIT SCORE ---
  $('.confirm_credit_score_btn').click(function (e) {
    e.preventDefault();
    $(this).closest(".confirm_person_credit_score").html('Confirmed! <hr>');
  });

  $('.confirm_credit_score_update_btn').click(function (e) {
    e.preventDefault();
    var $cs = $(this).closest(".confirm_person_credit_score");
    $cs.find(".confirm_credit_score_current").hide();
    $cs.find("form").show();
  });

  $('.confirm_credit_score_cancel_btn').click(function (e) {
    e.preventDefault();
    var $cs = $(this).closest(".confirm_person_credit_score");
    $cs.find(".confirm_credit_score_current").show();
    $cs.find("form").hide();
  });

  // ---- PERSONAL SPENDING ---

  $('.confirm_personal_spending_btn').click(function (e) {
    e.preventDefault();
    $(this).closest(".confirm_personal_spending").html('Confirmed! <hr>');
  });

  $('.confirm_personal_spending_update_btn').click(function (e) {
    e.preventDefault();
    var $ps = $(this).closest(".confirm_personal_spending");
    $ps.find(".confirm_personal_spending_current").hide();
    $ps.find("form").show();
  });

  $('.confirm_personal_spending_cancel_btn').click(function (e) {
    e.preventDefault();
    var $ps = $(this).closest(".confirm_personal_spending");
    $ps.find(".confirm_personal_spending_current").show();
    $ps.find("form").hide();
  });
});
