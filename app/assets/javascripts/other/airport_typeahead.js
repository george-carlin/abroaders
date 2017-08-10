/* global Bloodhound b:true */
/* global diacritics b:true */
// Note: if the typeahead isn't working for you locally (in that you're
// not seeing any results when you type in an airport, even though you do
// have airports in the DB), it may be because typeahead.js has cached
// an old version of your local `airports` table in your browser's local
// storage. Running this line in the browser console solved the issue for me:
//
//    localStorage.removeItem("__/airports/typeahead.json__data")
//

function airportBloodhound() {
  return new Bloodhound({
    datumTokenizer: function (d) {
      return Bloodhound.tokenizers.whitespace(d.tokens.join(' '));
    },
    queryTokenizer: function (q) {
      return Bloodhound.tokenizers.whitespace(diacritics.remove(q));
    },
    prefetch: "/airports/typeahead.json",
  });
}

function airportTypeahead($elem) {
  return $elem.typeahead(
    {
      hint: true,
      highlight: true,
      minLength: 1, // The minimum character length needed before suggestions start getting rendered
    },
    {
      name: 'airports',
      display: 'name',
      limit: 5, // The max number of suggestions to be displayed. Defaults to 5.
      source: airportBloodhound(),
    });
}
