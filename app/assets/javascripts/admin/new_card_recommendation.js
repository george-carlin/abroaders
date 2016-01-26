$(document).ready(function () {
  $(".new_card_account table").tablesorter({
    // The table can't be sorted by the first column:
    headers: { 0: { sorter: false } }
  });

  $('.card_bp_filter').click(function (e) {
    var hide  = !this.checked,
        value = this.dataset.value;
    $("tr.admin_recommend_card").each(function (i, tr) {
      var $tr = $(tr);

      if (value == tr.dataset.bp) {
        if (hide) {
          // Add a dummy element after this one so that the Bootstrap
          // .table-striped classes don't get messed up. See
          // http://stackoverflow.com/a/20580140/1603071
          $tr.after('<tr></tr>').hide();
        } else {
          // Remove the dummy <tr> added above.
          $tr.show().next().remove();
        }
      }
    });
  });
});
