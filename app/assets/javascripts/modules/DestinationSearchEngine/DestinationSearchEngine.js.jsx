const Bloodhound = require("bloodhound-js");

const DestinationSearchEngine = new Bloodhound({
  datumTokenizer: function (d) {
    console.log(d);
    return Bloodhound.tokenizers.whitespace(d.value);
  },
  queryTokenizer: Bloodhound.tokenizers.whitespace,

  // sends ajax request to remote url where %QUERY is user input
  remote: {
    url: '/api/v1/destinations/typeahead?query=%QUERY',
    wildcard: "%QUERY",
  },
  // Note: if you change the 'maxItemsToShow' prop in Typeahead.js.jsx, you'll
  // probably need to change this line too:
  limit: 8,
});

module.exports = DestinationSearchEngine;
