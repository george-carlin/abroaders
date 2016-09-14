$(document).ready(function () {
  function appendTypeahead(element) {
    element.find('.typeahead').typeahead({
      hint: true,
      highlight: true,
      minLength: 1
    },
    {
      name: 'airports',
      display: 'name',
      source: airports
    }).bind('typeahead:select', function (e, suggestion) {
      $(this).closest('.typeahead-container').find('.home-airport-id').val(suggestion.id);
    }).bind('typeahead:autocomplete', function (e, suggestion) {
      $(this).closest('.typeahead-container').find('.home-airport-id').val(suggestion.id);
    });
  }

  function checkAirportsCount() {
    var $addButton = $surveyForm.find('.btn-add');

    if ($inputsContainer.find('.entry').length == 5) {
      $addButton.attr('disabled', true)
    }
    else {
      $addButton.attr('disabled', false)
    }
  }

  function formIsValid(form) {
    var isValid = true;
    form.find('.home-airport-id').each(function (i, element) {
      var $container = $(element).closest('.typeahead-container');
      $container.removeClass('has-error');
      if ($(element).val() == '') {
        $container.addClass('has-error');
        isValid = false;
      }
    });
    return isValid;
  }

  var airports = new Bloodhound({
    datumTokenizer: function (d) {
      return Bloodhound.tokenizers.whitespace(d.tokens.join(' '));
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    prefetch: "/airports.json"
  });

  var $surveyForm = $('.home-airport-survey-form'),
      $inputsContainer = $surveyForm.find('.airports-inputs'),
      $firstEntry = $inputsContainer.find('.entry:first');

  appendTypeahead($firstEntry);

  $surveyForm.on('click', '.btn-add', function () {
    var newEntry = $($firstEntry.clone()).appendTo($inputsContainer),
        placeholder = $firstEntry.find('#typeahead').attr('placeholder');

    newEntry.find('input').val('');
    newEntry.find('.twitter-typeahead').remove();
    newEntry.find('.btn-remove').removeClass('hide');
    newEntry.find('.typeahead-container').append('<input class="form-control typeahead" required="true" placeholder="' + placeholder +'">');
    appendTypeahead(newEntry);
    checkAirportsCount();
  }).on('click', '.btn-remove', function () {
    $(this).closest('.entry').remove();
    checkAirportsCount();
    return false;
  }).on('submit', function () {
    return formIsValid($surveyForm);
  });
});
