// Don't name this file 'bloodhound' because then it conflicts with the
// actual bloodhound source code.

window.bloodhound = (function () {
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
  return bloodhound;
}());
