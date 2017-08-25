$(document).ready(function () {
  $('.award_wallet_owner_person_id').change(function () {
    $(this).closest('form').submit();
  });

  $('.owner_update_person_form').on("ajax:beforeSend", function (e) {
    // Show spinner, disable select
    var $this = $(this);
    $this.prop('disabled', true);
    $this.closest('.award_wallet_owner')
      .find(".LoadingSpinner")
        .css({ display: 'inline-block' }); // don't use show(), as that uses 'block'
  }).on("ajax:complete", function (e) {
    // Hide spinner, reenable select
    var $this = $(this);
    var $owner = $this.closest('.award_wallet_owner');
    var $success = $owner.find('.award_wallet_settings_person_saved');
    $this.prop('disabled', false);
    $owner.find(".LoadingSpinner").hide();
    $success.css('visibility', 'visible');

    window.setTimeout(function () {
      $success.css('visibility', 'hidden');
    }, 2000);
  });
});
