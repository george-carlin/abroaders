$(document).ready(function () {
  $('#new_rec_request_btn').click(function (e) {
    e.preventDefault();
    $("#new_rec_request_btn_wrapper").hide();
    $("#new_rec_request_form").show();
  });

  $('#new_rec_request_form .cancel_btn').click(function (e) {
    e.preventDefault();
    $("#new_rec_request_btn_wrapper").show();
    $("#new_rec_request_form").hide();
  });
});
