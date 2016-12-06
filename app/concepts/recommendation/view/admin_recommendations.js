$(document).ready(function () {
  $(".recommend_offer_btn").click(function (e) {
    e.preventDefault();
    $(this)
      .hide()
      .siblings(".new_recommendation")
        .show();
  });

  $(".cancel_recommend_offer_btn").click(function (e) {
    e.preventDefault();
    $(this)
      .closest(".new_recommendation")
        .hide()
        .siblings(".recommend_offer_btn")
          .show();
  });
});
