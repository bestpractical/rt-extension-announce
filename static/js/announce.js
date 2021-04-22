
jQuery(document).ready(function() {
    jQuery('#more_announcements').hide();
    var hide = true;
    jQuery('#toggle_announcements').click( function() {
        if ( hide == true ) {
            jQuery('#more_announcements').show();
            jQuery('#toggle_announcements').text(jQuery('#toggle_announcements').data('text-less'));
            hide = false;
        }
        else if ( hide == false ) {
            jQuery('#more_announcements').hide();
            jQuery('#toggle_announcements').text(jQuery('#toggle_announcements').data('text-more'));
            hide = true;
        }
    });
});
