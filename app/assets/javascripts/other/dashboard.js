$(document).ready(function () {
  $("#unresolved_recommendations_notification_modal").modal()

});



 jQuery(document).ready(function($) {
    $("#countdown")
        .countdown("2019/01/01", function(event) {
            $(this).text(
                event.strftime('%D days %H:%M:%S')
            );
        });
})