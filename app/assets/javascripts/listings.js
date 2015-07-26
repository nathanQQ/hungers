jQuery(function($){

	Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));
	$('#new_listing').submit(function(event){		
		$('input[type=submit]').attr('disabled',true);
		$.getJSON("/listing_sold_date_updated", listingCreateResponseHandler);
		return false;
	});

	$(".edit_listing").submit(function(event){
		$('input[type=submit]').attr('disabled',true);
		$.getJSON("/listing_sold_date_updated",listingUpdateResponseHandler);
		return false;
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

function listingCreateResponseHandler(data) {
	var new_sold_date = $("#listing_sold_date").val();
	var $form = $('#new_listing');
	var tmp = 0;
	var is_duplicate = false;
	
	for (; tmp < data.length; tmp++) {
		if (data[tmp].sold_date == new_sold_date) {					
			is_duplicate = true;
			alert("You already have a listing for sale on the selected date. Please pick up another day!");	
			$('input[type=submit]').attr('disabled',false);
			break;
		} 
	}
	if (is_duplicate) {
		return false;
	}
	else if ($('input').length > 7) {
		Stripe.bankAccount.createToken($form, listingStripeResponseHandler);
		return false;	
	}
	else {
		$form.get(0).submit();
	}
}

function listingUpdateResponseHandler(data) {
	var new_sold_date = $("#listing_sold_date").val();
	var $form = $('.edit_listing');
	var listing_id = $form.attr('id').split('_')[2];
	var tmp = 0;
	var is_duplicate = false;

	for (; tmp < data.length; tmp++) {
		if (data[tmp].id == listing_id) {
			continue;
		}
		if (data[tmp].sold_date == new_sold_date) {					
			is_duplicate = true;
			alert("You already have a listing for sale on the selected date. Please pick up another day!");	
			$('input[type=submit]').attr('disabled',false);
			break;
		} 
	}
	if (is_duplicate) {
		return false;
	}
	else {
		$form.get(0).submit();
	}
}