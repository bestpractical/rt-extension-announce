use strict;
use warnings;
package RT::Extension::Announce;

our $VERSION = '0.06';

RT->AddJavaScript('announce.js');
RT->AddStyleSheets('announce.css');

sub GetAnnouncements {
    my $current_user = shift;

    my $AnnounceQueue = RT->Config->Get('RTAnnounceQueue') || 'RTAnnounce';
    my $Queue = RT::Queue->new( RT->SystemUser );
    $Queue->Load($AnnounceQueue);
    unless ( $Queue->Id ) {
        $RT::Logger->error(
'RTAnnounce queue not found for Announce extension. Did you run make initdb?'
        );
        return;
    }

    my @tickets;

    # Get announce tickets.
    my $tickets = RT::Tickets->new( RT->SystemUser );
    $tickets->OrderBy( FIELD => 'LastUpdated', ORDER => 'DESC' );
    my @statuses = $Queue->ActiveStatusArray();
    @statuses = map { s/(['\\])/\\$1/g; "Status = '$_'" } @statuses;
    my $status_query = join( ' OR ', @statuses );
    $tickets->FromSQL("Queue = '$AnnounceQueue' AND ( $status_query )");
    return if $tickets->Count == 0;

    my $who = $current_user->Name;

    # Get groups for each ticket
    while ( my $ticket = $tickets->Next ) {
        my $tid    = $ticket->id;
        my $groups = $ticket->CustomFieldValues('Announcement Groups');

        my @groups;
        while ( my $group = $groups->Next ) {
            push @groups, $group->Content;
        }

        unless (@groups) {

            # No groups defined, everyone sees announcement
            RT->Logger->debug(
                "Showing announcement #$tid to $who: not limited to any groups"
            );
            push @tickets, $ticket;
            next;
        }

        foreach my $group_name (@groups) {
            my $group_obj = RT::Group->new( RT->SystemUser );
            $group_obj->LoadUserDefinedGroup($group_name);

            unless ( $group_obj->Id ) {
                $RT::Logger->error(
"Cannot find group '$group_name' for announcement #$tid (for $who)"
                );
                next;
            }

            if ( $group_obj->HasMemberRecursively( $current_user->PrincipalObj )
              )
            {
                # User can see this announcement.
                RT->Logger->debug(
"Showing announcement #$tid to $who: member of '$group_name'"
                );
                push @tickets, $ticket;
            }
            else {
                $RT::Logger->debug(
                        "Not showing announcement ticket #$tid to user $who "
                      . "because they are not in group $group_name" );
            }
        }
    }
    return @tickets;
}


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

    Set(@Plugins, qw(RT::Extension::Announce));
    Set(@CustomFieldValuesSources, (qw(RT::CustomFieldValues::AnnounceGroups)));

or add C<RT::Extension::Announce> to your existing C<@Plugins> line.

=item make initdb

Run this in the install directory where you ran the previous make commands.

=item Clear your mason cache

    rm -rf /opt/rt4/var/mason_data/obj

=item Restart your webserver

=back

=head1 DESCRIPTION

The Announce extension gives you an easy way to insert announcements on the RT homepage
so all users can see the message. You may want to display a banner during maintenance or
an unscheduled outage to make sure the people fielding customer tickets know that
something is going on.

=head1 DETAILS

When you install the extension, a new queue is created called RTAnnounce.
To post an announcement, create a ticket in that queue.
The extension displays on the RT homepage the subject and most recent correspondence
on active tickets in the RTAnnounce queue. As the incident or maintenance progresses,
just reply to the ticket and the announcement will be updated with the latest
information.

When multiple announcements are active, they are ordered by
the last update time with the announcement with the most recent
update coming first.

When the incident is over, resolve the ticket and the
announcement will be removed.

Comments on announce tickets are not shown in the announcement. However,
comments are visible on the ticket for users who have permission to view
the full ticket. If you have multiple announcements, a new comment updates
the last updated time and will move the announcement to the top of the list.

=head1 ANNOUNCEMENT GROUPS

The RTAnnounce queue has a custom field called 'Announcement Groups' which
you can use to manage who will see an announcement. If you set no value, all
users will see the announcement. If you set one or more RT groups, only memebers
of those groups will see it.

=head1 PERMISSIONS

By default, the announements are static text. If you give
users the ShowTicket right on the RTAnnounce queue, the announcements
will have links to the source tickets. This will allow users to see the
history of an announcement or see longer messages that might be
truncated on the homepage.

The RTAnnounce queue is a regular queue, so you can control access to creating
announcements the same way you manage permissions on other queues.

In addition to setting permissions, you may not
want to send the typical 'ticket create' email messages, so you could change
or customize the scrips that run or create new templates. If you send
announcement messages to an email list,
you could create a list user in RT and add it as a CC to the announcement
queue. Then messages posted for announcement in RT will also be sent to the
notification list.

=head1 CONFIGURATION

You can change the name of the queue used for announcements. First edit the
RTAnnounce queue in RT and change its name to your new name. Add a line
to your RT_SiteConfig.pm to set that new value:

    Set($RTAnnounceQueue, 'Custom Announce Name');

Then clear your mason cache and restart your server.

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
