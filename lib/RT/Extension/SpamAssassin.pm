package RT::Extension::SpamAssassin;
use strict;
use warnings;

our $VERSION = '0.01';
use Mail::SpamAssassin;
my $options = RT->Config->Get('SpamAssassinOptions');
# Mail::SpamAssassin wants a hashref
my $spamtest = Mail::SpamAssassin->new( $options ? $options : () );

sub GetCurrentUser {
    my %args = (
        Message     => undef,
        CurrentUser => undef,
        AuthLevel   => undef,
        @_
    );
    my $status = $spamtest->check( $args{'Message'} );
    return ( $args{'CurrentUser'}, $args{'AuthLevel'} )
      unless $status->is_spam();

    eval { $status->rewrite_mail() };
    if ( $status->get_hits > $status->get_required_hits() * 1.5 ) {

        # Spammy indeed
        return ( $args{'CurrentUser'}, -1 );
    }
    return ( $args{'CurrentUser'}, $args{'AuthLevel'} );

}

1;

__END__

=head1 NAME

RT::Extension::SpamAssassin - Spam filter for RT

=head1 SYNOPSIS

    # in RT config
    Set(@Plugins, 'RT::Extension::SpamAssassin', ...other plugins...);
    Set(@MailPlugins, 'RT::Extension::SpamAssassin', ...other filters...);

    # options here will be transfered to Mail::SpamAssassin's new method 
    # as a hashref.
    Set(%SpamAssassinOptions, debug => ..., userprefs_filename => ...);

=head1 DESCRIPTION

It was RT::Interface::Email::Filter::SpamAssassin in RT core, when we
removed it from core since 3.9, this plugin was born.

This plugin checks to see if an incoming mail is spam (using
C<spamassassin>) and if so, rewrites its headers. If the mail is very
definitely spam - 1.5x more hits than required - then it is dropped on
the floor; otherwise, it is passed on as normal.

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>

=head1 LICENCE AND COPYRIGHT

RT-Extension-SpamAssassin is Copyright 2010 Best Practical Solutions, LLC.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

