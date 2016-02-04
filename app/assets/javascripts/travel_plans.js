$(document).ready(function () {
  var bloodhound = new Bloodhound({
    datumTokenizer: function (d) {
      return Bloodhound.tokenizers.whitespace(d.value);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace,

    // sends ajax request to remote url where %QUERY is user input
    remote: {
      url: '/api/v1/destinations/typeahead?query=%QUERY',
      wildcard: "%QUERY",
    },
    limit: 10
  });
  bloodhound.initialize();

  var displayText = function (item) {
    return item.name + " (" + item.code + ")";
  },
  source = function (query, process) {
    return bloodhound.search(query, process, process);
  };


  $("#travel_plan_legs_attributes_0_from").typeahead({
    afterSelect: function (item) {
      $("#travel_plan_legs_attributes_0_from_id").val(item.id);
    },
    displayText: displayText,
    source: source,
  });

  $("#travel_plan_legs_attributes_0_to").typeahead({
    afterSelect: function (item) {
      $("#travel_plan_legs_attributes_0_to_id").val(item.id);
    },
    displayText: displayText,
    source: source,
  });
});

$(document).ready(function () {
  $('#travel_plan_daterange_select').datepicker({
    weekStart: 1,
    startDate: new Date(),
    todayHighlight: true,
  });
});
