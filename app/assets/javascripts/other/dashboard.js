$(document).ready(function () {
  $("#unresolved_recommendations_notification_modal").modal();

  $('[data-countdown]').each(function () {
    var $this = $(this), finalDate = $(this).data('countdown');
    $this.countdown(finalDate, function (event) {
      $this.html(event.strftime('%D days, %H hours, %M minutes, %S seconds'));
    });
  });
});
