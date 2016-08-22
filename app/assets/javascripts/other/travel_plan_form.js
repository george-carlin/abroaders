$(document).ready(function () {
  $('#travel_plan_earliest_departure').datepicker({
    startDate: "new Date()",
    startView: 1,
    maxViewMode: 0,
    autoclose: true,
    todayHighlight: true,
  });


  /*
   * This is based on (i.e. copied from then stripped of all unecessary
   * options) the 'jquery-simply-countable' plugin:
   * by Aaron Russell:*http://github.com/aaronrussell/jquery-simply-countable/
   */
  var $countable = $("#travel_plan_further_information");
  if ($countable.length) {
    var maxCount   = 500,
        $counter   = $("#travel_plan_further_information_counter");

    var countCheck = function () {
      var count    = maxCount - $countable.val().length;
      var revCount = count - (count * 2) + maxCount;

      /* If they've reached the maximum, restrict further characters */
      if (count <= 0) {
        var content = $countable.val();
        $countable.val(content.substring(0, maxCount)).trigger('change');
        count = 0, revCount = maxCount;
      }

      var prefix = '';
      if (',') {
        count = count.toString();
        // Handle large negative numbers
        if (count.match(/^-/)) {
          count  = count.substr(1);
          prefix = '-';
        }

        for (var i = count.length - 3; i > 0; i -= 3) {
          count = count.substr(0, i) + ',' + count.substr(i);
        }
      }

      $counter.text(prefix + count);
    };

    countCheck();

    $countable.on('keyup blur paste', function (e) {
      switch (e.type) {
        case 'keyup':
          // Skip navigational key presses
          if ($.inArray(e.which, [33, 34, 35, 36, 37, 38, 39, 40]) < 0) { countCheck(); }
          break;
        case 'paste':
          // Wait a few miliseconds if a paste event
          setTimeout(countCheck, (e.type === 'paste' ? 5 : 0));
          break;
        default:
          countCheck();
          break;
      }
    });
  }
});
