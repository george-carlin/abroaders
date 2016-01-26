$(document).ready(function () {
  $(".new_card_account table").tablesorter({
    // The table can't be sorted by the first column:
    headers: { 0: { sorter: false } }
  });

  $('.card_bp_filter').click(function (e) {
    var show  = this.checked,
        value = this.dataset.value;
    $("tr.admin_recommend_card").each(function (i, tr) {
      if (value == tr.dataset.bp) {
        tr.style.display = show ? "" : "none"
      }
    });
  });
});
