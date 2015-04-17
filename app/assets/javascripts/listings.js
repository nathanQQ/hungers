jQuery(function($){

	Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));
	$('#new_listing').submit(function(event){
		if ($('input').length > 7) {
			var $form = $(this);
			$('input[type=submit]').attr('disabled',true);
			Stripe.bankAccount.createToken($form, listingStripeResponseHandler);
			return false;
		}
	});	
});

function listingStripeResponseHandler(status, response) {
	var $form = $('#new_listing');
	if(response.error){
		//$form.find('.payment-errors').text(response.error.message);
    	alert(response.error.message);
    	$('input[type=submit]').attr('disabled',false);
	} else {
	    // response contains id and card, which contains additional card details
	    var token = response.id;
	    // Insert the token into the form so it gets submitted to the server
	    $form.append($('<input type="hidden" name="stripeToken" />').val(token));
	    // and submit
	    $form.get(0).submit();		
	}
}