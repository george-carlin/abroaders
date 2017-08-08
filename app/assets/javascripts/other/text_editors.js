$(document).ready(function () {
  $("textarea#offer_user_notes, textarea#offer_notes, textarea#admin_bio").summernote({
    height: 150,
    toolbar: [
      ['style', ['bold', 'italic', 'underline', 'clear']],
      ['font', ['strikethrough', 'superscript', 'subscript']],
      ['fontsize', ['fontsize']],
      ['para', ['ul', 'ol', 'paragraph']],
    ],
  });
});
