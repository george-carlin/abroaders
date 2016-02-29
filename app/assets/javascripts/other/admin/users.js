$(document).ready(function () {

  var $rows = $("#admin_users_table_body > tr.user");

  $("#admin_users_table_filter").on(
    "change keyup keydown keypress",
    function filterUsers() {
      var filterString = this.value.toLowerCase().trim();
      $rows.each(function (i, row) {
        var name  = row.dataset.fullName.toLowerCase(),
            email = row.dataset.email.toLowerCase(),
            $row = $(row),
            // 'includes' doesn't work with the current version of Poltergeist/
            // PhantomJS:
            // show = name.includes(filterString) || email.includes(filterString),
            show = name.indexOf(filterString) > -1 ||
                    email.indexOf(filterString) > -1;

        $row.toggle(show);
      });
    }
  );


});
