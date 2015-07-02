jQuery(function($){

	Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));
	$('#new_order').submit(function(event){
		var $form = $(this);
			if ($('input').length > 6) {
				$('input[type=submit]').attr('disabled',true);
				if (!form_validation())
					return false;
				else
					Stripe.card.createToken($form, orderStripeResponseHandler);
			}
			else {
				$form.get(0).submit();
			}
			return false;
	});

	$('#quantity_update').click(function(event){
		var nr_order = $('#order_nr_order').val();		
		var url_append = "?quantity=" + nr_order;
		$('#quantity_update').attr("href", url_append);
	});

	$('#sales_month_update').click(function(event){
		var month = $('#sales_month').val();		
		var url_append = "?month=" + month;
		$('#sales_month_update').attr("href", url_append);
	});	

});

function form_validation() {
	var card_number = $('#card_number').val();
	var cvc = $('#card_code').val();
	var address = $('#billing_address1').val();
	var city = $('#city').val();
	var state = $('#state').val();
	var zip = $('#zip_code').val();
	if (card_number == "" ||
		cvc == "" ||
		address == "" ||
		city == "" ||
		state == "" ||
		zip == "") {
		alert("One or more required fields are empty. Please check and try again!");
		$('input[type=submit]').attr('disabled',false);
		return false;
	}
	else {
		return true;
	}
}

function orderStripeResponseHandler(status, response){
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