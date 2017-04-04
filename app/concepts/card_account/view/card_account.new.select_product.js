// console.log('fuck off');
$(document).ready(function () {
  $('#new_card_bank_id').change(function () {
    var bankId = $(this).val();
    $(".bank_card_products").hide();
    $("#bank_" + bankId + "_card_products").show();
  });
});
