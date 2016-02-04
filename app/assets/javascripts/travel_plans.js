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
  showSpinner = function () {
    $(this).siblings(".loading-spinner").show();
  };


  $("#travel_plan_legs_attributes_0_from").typeahead({
    afterSelect: function (item) {
      $("#travel_plan_legs_attributes_0_from_id").val(item.id);
    },
    displayText: displayText,
    source: function (query, process) {
      // Hide the loading spinner when the search is complete.
      var wrapped = function (results) {
        $("#to-loading-spinner").hide();
        process(results);
      };
      return bloodhound.search(query, process, wrapped);
    },
  }).on("keyup keydown keypress", showSpinner);

  $("#travel_plan_legs_attributes_0_to").typeahead({
    afterSelect: function (item) {
      $("#travel_plan_legs_attributes_0_to_id").val(item.id);
    },
    displayText: displayText,
    source: function (query, process) {
      // Hide the loading spinner when the search is complete.
      var wrapped = function (results) {
        $("#to-loading-spinner").hide();
        process(results);
      };
      return bloodhound.search(query, process, wrapped);
    },
  }).on("keyup keydown keypress", showSpinner);
});

$(document).ready(function () {
  $('#travel_plan_daterange_select').datepicker({
    weekStart: 1,
    startDate: new Date(),
    todayHighlight: true,
  });
});
