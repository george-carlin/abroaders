$(document).ready(function () {
  $('.region-image').click(function () {
    var $cb = $(this).closest('.region-box').find('input[type=checkbox]');
    $cb.prop('checked', !$cb.prop('checked'));
  });
});
