$(document).ready(function () {
  $('#new_rec_request_link').click(function (e) {
    var $this = $(this);
    if ($this.data('form')) {
      $this.hide();
      e.preventDefault();
      $("#new_rec_request_form").show();
    }
  });

  $('#new_rec_request_form .cancel_btn').click(function (e) {
    e.preventDefault();
    $("#new_rec_request_link").show();
    $("#new_rec_request_form").hide();
  });
});
