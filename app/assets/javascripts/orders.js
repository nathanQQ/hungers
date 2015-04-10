jQuery(function($){

	Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));
	$('#new_order').submit(function(event){
		var $form = $(this);
			if ($('input').length > 4) {
				$('input[type=submit]').attr('disabled',true);
				Stripe.card.createToken($form, stripeResponseHandler);
			}
			else {
				$form.get(0).submit();
			}
			return false;
	});	
});

function stripeResponseHandler(status, response){
	var $form = $('#new_order');
	if(response.error){
		//$form.find('.payment-errors').text(response.error.message);
    	alert(response.error.message);
    	$('input[type=submit]').attr('disabled',false);
	} else {
	    // response contains id and card, which contains additional card details
	    var token = response.id;
	    var is_remember_cc = $('#rmcc').is(':checked');
	    // Insert the token into the form so it gets submitted to the server
	    $form.append($('<input type="hidden" name="stripeToken" />').val(token));
	    $form.append($('<input type="hidden" name="rmcc" />').val(is_remember_cc));
	    // and submit
	    $form.get(0).submit();		
	}
}