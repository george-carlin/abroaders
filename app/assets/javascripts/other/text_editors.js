$(document).ready(function () {
  var textareas = "textarea#offer_user_notes, textarea#offer_notes," +
                  "textarea#admin_bio, textarea#recommendation_note";
  $(textareas).summernote({
    height: 150,
    toolbar: [
      ['style', ['bold', 'italic', 'underline', 'clear']],
      ['font', ['strikethrough', 'superscript', 'subscript']],
      ['fontsize', ['fontsize']],
      ['link', ['link']],
      ['para', ['ul', 'ol', 'paragraph']],
    ],
  });
});
