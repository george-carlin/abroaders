$(document).ready(function () {
  $("[data-toggle=tooltip]").tooltip();
  $("[data-toggle=tooltip]").click(function (e) {
    e.preventDefault();
  });
});
