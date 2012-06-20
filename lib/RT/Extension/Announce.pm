use strict;
use warnings;
package RT::Extension::Announce;

our $VERSION = '0.01';

=head1 NAME

RT-Extension-Announce - Display announcements as a banner on RT pages.

=head1 INSTALLATION

=over

=item perl Makefile.PL

=item make

=item make install

May need root permissions

=item Edit your /opt/rt4/etc/RT_SiteConfig.pm

Add these lines:

    Set($RTAnnounceQueue, 'AnnounceQueueName');
    Set(@Plugins, qw(RT::Extension::Announce));

or add C<RT::Extension::Announce> to your existing C<@Plugins> line.

=item Clear your mason cache

    rm -rf /opt/rt4/var/mason_data/obj

=item Restart your webserver

=back

=head1 DESCRIPTION

The Announce extension gives you an easy way to insert announcements on RT pages
so all users can see the message. You may want to display a banner during maintenance or
an unscheduled outage to make sure the people fielding customer tickets know that
something is going on.

To post an announcement, create a ticket in the queue you identified in the
RTAnnounceQueue configuration. The extension displays the two most recent updates
on new or open tickets in that queue. The subject and most recent textual
message are displayed. As the incident or maintenance progresses, just post
the updates to the ticket and the announcement will be updated with the latest
information.

You should set up a designated queue for announcement messages so you can post
tickets only when you want an announcement displayed. You can set
permissions on the queue to control who can create new announcements
and who should see them.

Setting up a designated
queue also allows you to customize it in other ways. For example, you may not
want to send the typical 'ticket create' email messages, so you could change
or customize the scrips that run or create new templates. If you send
announcement messages to an email list,
you could create a list user in RT and add it as a CC to the announcement
queue. Then messages posted for announcement in RT will also be sent to the
notification list.

=head1 AUTHOR

Jim Brandt <jbrandt@bestpractical.com>

=head1 BUGS

All bugs should be reported via
L<http://rt.cpan.org/Public/Dist/Display.html?Name=RT-Extension-Announce>
or L<bug-RT-Extension-Announce@rt.cpan.org>.


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2012 by Best Practical Solutions, LLC

This is free software, licensed under:

  The GNU General Public License, Version 2, June 1991

=cut

1;
