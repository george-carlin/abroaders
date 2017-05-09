$(document).ready(function () {
  $(".card_rec_toggle_date").click(function () {
    var $checkbox = $(this);
    $checkbox.closest(".date_select_form_group").find("select")
    .prop('disabled', !$(this).is(':checked'));
  });
});
