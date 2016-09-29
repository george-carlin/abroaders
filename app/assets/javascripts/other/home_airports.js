$(document).ready(function () {
  if ($(".home-airports-survey").length) {
  function getSelectedAirportCount() {
    return ($('.hidden-airports-ids').length)
  }

  function airportAlreadyAdded(suggestion) {
    return ($('.hidden-airports-ids[value="' + suggestion.id + '"]').length != 0)
  }

  function manageAlert(element, message) {
    if (message.length == "") {
      element.hide();
      element.html('');
    }
    else {
      element.show();
      element.html(message);
    }
  }

  function changeSubmitState() {
    var disabled = (getSelectedAirportCount() == 0);
    $('.submit-airports-survey').attr('disabled', disabled);
  }

  var airports = new Bloodhound({
    datumTokenizer: function (d) {
      return Bloodhound.tokenizers.whitespace(d.tokens.join(' '));
    },
    queryTokenizer: function (q) {
      return Bloodhound.tokenizers.whitespace(diacritics.remove(q));
    },
    prefetch: "/airports.json"
  });

  var $saved_area = $('.saved-area .home-airports'),
      $airports_form = $('.home-airport-survey-form'),
      $alert_info = $airports_form.find('.info-message'),
      $alert_danger = $airports_form.find('.error-message');

  $('.typeahead').typeahead({
        hint: true,
        highlight: true,
        minLength: 1 // The minimum character length needed before suggestions start getting rendered. Defaults to 1.
      },
      {
        name: 'airports',
        display: 'name',
        limit: 5, // The max number of suggestions to be displayed. Defaults to 5.
        source: airports
      }).bind('typeahead:select', function (e, suggestion) {
    $(this).typeahead('val', '');
    manageAlert($alert_info, "");
    manageAlert($alert_danger, "");

    if (airportAlreadyAdded(suggestion)) {
      manageAlert($alert_info, "You have already added this airport.");
    }
    else {
      var airport_div = document.createElement('div');

      if (getSelectedAirportCount() < 5) {
        airport_div.className = 'airport-selected';
        $(airport_div).append('<input class="hidden-airports-ids" type="hidden" name="home_airports_survey[airport_ids][]" value="' + suggestion.id + '">');
        $(airport_div).append('<p><i class="fa fa-check" aria-hidden="true"></i>' + suggestion.name + '<i class="fa fa-times" aria-hidden="true"></i></p>');
        $saved_area.append(airport_div);
      }
      else {
        manageAlert($alert_danger, "You can't add more than five airports");
      }

      changeSubmitState();
    }
  });

  $saved_area.on('click', '.airport-selected .fa-times', function () {
    if (confirm("Are you sure?")) {
      $(this).closest('.airport-selected').remove();
      changeSubmitState();
    }
  });

  $airports_form.on('submit', function () {
    if ($('.hidden-airports-ids').length != 0) {
      manageAlert($alert_danger, "");
      return true;
    }
    else {
      manageAlert($alert_danger, "You must select at least one airport.");
      return false;
    }
  });
  }
});
