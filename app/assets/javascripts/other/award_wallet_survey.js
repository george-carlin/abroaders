$(document).ready(function () {
  $('#aw-survey-yes-btn').click(function () {
    $('#aw-survey-initial').hide();
    $('#aw-survey-yes').show();
  });

  $('#aw-survey-no-btn').click(function () {
    $('#aw-survey-initial').hide();
    $('#aw-survey-no').show();
  });

  $('.aw-survey-back').click(function () {
    $('#aw-survey-initial').show();
    $('#aw-survey-yes').hide();
    $('#aw-survey-no').hide();
  });
});
