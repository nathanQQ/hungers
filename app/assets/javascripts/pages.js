
jQuery(function($){
    var interval = 4;// Secs
    var images = [
        "https://s3-us-west-1.amazonaws.com/hungersme/lobster+noodle.jpg"
       ,"https://s3-us-west-1.amazonaws.com/hungersme/cheesecake.jpg"
       ,"https://s3-us-west-1.amazonaws.com/hungersme/mini-chocolate-raspberry-cheesecakes.jpg"
    ];

    var idx = 1; 
    var myInterval = setInterval(function() {
       if (idx >= images.length)  
       		idx = 0;
       $('.jumbotron').css({ "background-image":"url(" + images[idx]+ ")" });
       idx++;
    	}, interval*1000);
});
