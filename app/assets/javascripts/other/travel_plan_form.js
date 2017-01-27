/* global airportTypeahead b:true */

$(document).ready(function () {
  if (!$(".travel-plan-form").length) {
    return;
  }

  $('.travel-plan-datepicker').datepicker({
    autoclose: true,
    format: 'mm/dd/yyyy',
    maxViewMode: 0,
    startDate: "new Date()", // today
    startView: 1,
    todayHighlight: true,
  }).each(function () {
    // When the travel plan is being edited, by default the inputs will show
    // the existing values in the format YYYY-MM-DD. Fixing this is
    // fundamentally display logic, so I feel it makes sense to correct it on
    // the front-end rather than doing something which involves editing the
    // form object (which was how we were doing it before.) This solution still
    // isn't great though:
    var $input = $(this);
    if ($input.val().trim()) {
      var parts = $input.val().trim().split('-');
      $input.datepicker('update', new Date(parts[0], parts[1] - 1, parts[2]));
    }
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

      /* If they've reached the maximum, restrict further characters */
      if (count <= 0) {
        var content = $countable.val();
        $countable.val(content.substring(0, maxCount)).trigger('change');
        count = 0;
      }

      var prefix = '';
      count = count.toString();
      // Handle large negative numbers
      if (count.match(/^-/)) {
        count  = count.substr(1);
        prefix = '-';
      }

      for (var i = count.length - 3; i > 0; i -= 3) {
        count = count.substr(0, i) + ',' + count.substr(i);
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

  var $singleRadio = $('#travel_plan_type_single');
  var $returnRadio = $('#travel_plan_type_return');
  var travelTypeRadioClick = function (e) {
    var $returnOnField = $('#travel_plan_return_on');

    if ($singleRadio.prop('checked')) {
      $returnOnField.prop('disabled', true);
      $returnOnField.val('');
    } else if ($returnRadio.prop('checked')) {
      $returnOnField.prop('disabled', false);
    }
  };
  $singleRadio.on('click', travelTypeRadioClick);
  $returnRadio.on('click', travelTypeRadioClick);

  airportTypeahead($('.typeahead')).on('typeahead:select', function (e, suggestion) {
    $(this).change();
  });
});
