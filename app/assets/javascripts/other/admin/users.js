$(document).ready(function () {
  // Note - these filter options fuck up the striped colors. This is a known
  // issue (and a very low priority one)
  var $stringFilterInput = $("#admin_accounts_table_filter");
  var $onboardedFilterRadios = $("input[name=admin_accounts_filter_onboarded]");

  var $rows = $("#admin_accounts_table_body > tr.account");

  function filterAccounts() {
    $rows.each(function (i, row) {
      var stringFilter = $stringFilterInput.val().toLowerCase().trim();
      var onboardedFilter = $onboardedFilterRadios.filter(":checked").val();

      var $row   = $(row),
          mpName = $row.data("main-passenger-name").toLowerCase(),
          coName = ($row.data("companion-name") || "").toLowerCase(),
          email  = $row.data("email").toLowerCase(),
          onboarded = $row.data("onboarded");

      var mpNameContainsFilterString = mpName.indexOf(stringFilter) > -1;
      var coNameContainsFilterString = coName.indexOf(stringFilter) > -1;
      var emailContainsFilterString  = email.indexOf(stringFilter) > -1;

      var isInFilteredOutOnboardingStage =
        (onboardedFilter === "onboarded" && !onboarded) ||
        (onboardedFilter === "not_onboarded" && onboarded);

      // The filter string and the 'onboarded' toggler work a little
      // differently. If the account's onboarded state doesn't match
      // the onboarding filter, it is *always* hidden. If the account
      // matches the filter string, it is always shown, *unless* it
      // doesn't also match the onboarding filter.

      $row.toggle(
        !isInFilteredOutOnboardingStage &&
          (
            mpNameContainsFilterString ||
            coNameContainsFilterString ||
            emailContainsFilterString
          )
      );
    });
  }

  $stringFilterInput.on("change keyup keydown keypress", filterAccounts);
  $onboardedFilterRadios.on("click", filterAccounts);

});
