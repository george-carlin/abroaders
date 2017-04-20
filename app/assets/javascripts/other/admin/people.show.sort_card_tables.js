$(document).ready(function () {
  $("#admin_person_card_accounts_table").tablesorter({
    headers: {
      0: { sorter: false }, // ID
      1: { sorter: false }, // Name
      2: { sorter: true  }, // Opened
      3: { sorter: true  }, // Closed
    },
    sortList : [[2, 1], [3, 1]],
  });

  $("#admin_person_card_recommendations_table").tablesorter({
    headers: {
      0: { sorter: false }, // ID
      1: { sorter: false }, // Name
      2: { sorter: false }, // Status
      3: { sorter: true }, // Rec'ed
      4: { sorter: true }, // Seen
      5: { sorter: true }, // Clicked
      6: { sorter: true }, // Applied
      7: { sorter: true }, // Declined
    },
    sortList : [[3, 1], [6, 1]],
  });
});
