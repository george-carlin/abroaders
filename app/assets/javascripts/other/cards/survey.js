$(document).ready(function () {

  // Allow the user to check/uncheck the box by clicking anywhere within the
  // picture/description of the card:
  $(".card-survey-checkbox").click(function (e) {
    var $this = $(this);
    var $checkbox = $this.find("input[type=checkbox]");
    var checked = $checkbox.prop("checked")
    // If the user has clicked on the checkbox or it's label, then the checkbox
    // will be toggled on/off as per normal HTML behaviour. But if they've
    // clicked elsewhere in the div, toggle the checkbox for them too:
    var nodeName = e.target.nodeName;
    if (!(nodeName === "INPUT" || nodeName === "LABEL")) {
      checked = !checked;
      $checkbox.prop("checked", checked);
    }

    $(this).toggleClass("selected", checked);
  });

});
