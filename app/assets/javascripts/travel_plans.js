// TODO the JSON this returns is huge! Probably not a good idea to load
// everything into memory like this.
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

  $(".destination-typeahead").typeahead({
    displayText: function (item) { 
      return item.name + " (" + item.code + ")";
    },
    source: function (query, process) {
      return bloodhound.search(query, process, process);
    },
  });
});

$(document).ready(function () {
  $('#travel_plan_daterange_select').datepicker({
    weekStart: 1,
    startDate: new Date(),
    todayHighlight: true,
  });
});
