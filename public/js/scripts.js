//preloader	
$(window).load(function() {
 $('#status, #pre-logo').fadeOut(); 
	$('#load1, #load' ) .delay(350).fadeOut('slow'); 
});

$(document).ready(function(){	
//navbar toggle
$(".navbar-toggle").on("click", function () {
	$(this).toggleClass("active");
});

//menu
jQuery('ul.nav li.dropdown').hover(function() {
  jQuery(this).find('.dropdown-menu').stop(true, true).delay(200).fadeIn();
}, function() {
  jQuery(this).find('.dropdown-menu').stop(true, true).delay(200).fadeOut();
});
		
/*****************************************************************************
	CONTACT FORM - you can change your notification message here
*****************************************************************************/
	$("#ajax-contact-form").submit(function() {
				var str = $(this).serialize();		
				$.ajax({
					type: "POST",
					url: "contact_form/contact_process.php",
					data: str,
					success: function(msg) {
						// Message Sent - Show the 'Thank You' message and hide the form
						if(msg == 'OK') {
							result = '<div class="notification_ok">Your message has been sent. Thank you!</div>';
							$("#fields").hide();
						} else {
							result = msg;
						}
						$('#note').html(result);
					}
				});
				return false;
			});	

//tooltip 
$("[rel=tooltip]").tooltip();
$("[data-rel=tooltip]").tooltip();

//carousel
 $('.carousel').carousel({ interval: 3000 }) 

//accordion
function toggleChevron(e) {
			$(e.target)
			.prev('.panel-heading')
			.find("i.indicator")
			.toggleClass('fa fa-chevron-down fa fa-chevron-up');
			}
				$('#accordion').on('hidden.bs.collapse', toggleChevron);
				$('#accordion').on('shown.bs.collapse', toggleChevron);

//scroll
$(".scroll").click(function(event){		
	event.preventDefault();
		$('html,body').animate({scrollTop:$(this.hash).offset().top -95}, 1000, 'easeInSine');
		});
		jQuery.extend( jQuery.easing,
		{easeInSine: function (x, t, b, c, d) { return -c * Math.cos(t/d * (Math.PI/2)) + c + b; }
});

//back to top
	$(window).scroll(function() {
		if ($(this).scrollTop() > 200) {
			$('.go-top').fadeIn(200);
				} else {
					$('.go-top').fadeOut(200);
				}
			});
			// Animate scroll to top
			$('.go-top').click(function(event) {
				event.preventDefault();
				$('html, body').animate({scrollTop: 0}, 1000);
			});	
		});
		


