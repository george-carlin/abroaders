/* global formTypeahead b:true */

$(document).ready(function () {
  function getSelectedAirportCount() {
    return ($('.hidden-airports-ids').length);
  }

  function airportAlreadyAdded(suggestion) {
    return ($('.hidden-airports-ids[value="' + suggestion.id + '"]').length !== 0);
  }

  function manageAlert(element, message) {
    if (message.length === 0) {
      element.hide();
      element.html('');
    } else {
      element.show();
      element.html(message);
    }
  }

  function changeSubmitState() {
    var disabled = (getSelectedAirportCount() === 0);
    $('.submit-airports-survey').attr('disabled', disabled);
  }

  if ($(".home-airports-survey").length > 0) {
    var $savedArea = $('.saved-area .home-airports'),
        $airportsForm = $('.home-airport-survey-form'),
        $alertInfo = $airportsForm.find('.info-message'),
        $alertDanger = $airportsForm.find('.error-message');

    formTypeahead($('.typeahead')).bind('typeahead:select', function (e, suggestion) {
      $(this).closest('.twitter-typeahead').next('.airport-id').val(suggestion.id);
    }).bind('typeahead:select', function (e, suggestion) {
      $(this).typeahead('val', '');
      manageAlert($alertInfo, "");
      manageAlert($alertDanger, "");

      if (airportAlreadyAdded(suggestion)) {
        manageAlert($alertInfo, "You have already added this airport.");
      } else {
        var airportDiv = document.createElement('div');

        if (getSelectedAirportCount() < 5) {
          airportDiv.className = 'airport-selected';
          $(airportDiv).append('' +
              '<input class="hidden-airports-ids" ' +
                'type="hidden" ' +
                'name="home_airports_survey[airport_ids][]" ' +
                'value="' + suggestion.id + '">'
          );
          $(airportDiv).append('<p>' +
              '<i class="fa fa-check" aria-hidden="true"></i>' +
              suggestion.name +
              '<i class="fa fa-times" aria-hidden="true"></i></p>');
          $savedArea.append(airportDiv);
        } else {
          manageAlert($alertDanger, "You can't add more than five airports");
        }

        changeSubmitState();
      }
    });

    $savedArea.on('click', '.airport-selected .fa-times', function () {
      $(this).closest('.airport-selected').remove();
      changeSubmitState();
    });

    $airportsForm.on('submit', function () {
      if ($('.hidden-airports-ids').length !== 0) {
        manageAlert($alertDanger, "");
        return true;
      } else {
        manageAlert($alertDanger, "You must select at least one airport.");
        return false;
      }
    });
  }
});
