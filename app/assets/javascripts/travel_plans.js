// TODO the JSON this returns is huge! Probably not a good idea to load
// everything into memory like this.
$.getJSON('/api/v1/airports.json', function(data) {
  var airportNames = data.data.map(function (a) {
    return { name: a.attributes.name + " (" + a.attributes.iata_code + ")" };
  })

  $(document).ready(function () {
    $("#travel_plan_destination_lookup").typeahead({ source: airportNames });
    $("#travel_plan_origin_lookup").typeahead({ source: airportNames });
  })
}, "json");

$(document).ready(function () {
  $('#travel_plan_daterange_select').datepicker({
    weekStart: 1,
    startDate: new Date(),
    todayHighlight: true,
  });
});
