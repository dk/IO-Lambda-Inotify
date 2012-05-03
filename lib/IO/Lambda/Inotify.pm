package IO::Lambda::Inotify;

use strict;
use warnings;
use IO::Handle;
use IO::Lambda qw(:all :dev);
use base qw(Exporter);
our $VERSION = '1.00';
our @EXPORT = qw(inotify_server);

sub inotify
{
	my $inotify = shift;

	my $fh = IO::Handle-> new;
	$fh-> fdopen( $inotify-> fileno, 'r');
	$inotify-> blocking(0);

	lambda {
		context $fh;
		readable {
			$inotify-> poll;
			again;
		}
	}
}

sub inotify_server 
{
	my @k = @_;
	lambda {
		context map { inotify $_ } @k;
		&tails();
	};
}

1;

__DATA__

=pod

=head1 NAME

IO::Lambda::Inotify - bridge between IO::Lambda and Linux::Inotify2

=head1 SYNOPSIS

    use Linux::Inotify2;
    use IO::Lambda qw(:all);
    use IO::Lambda::Inotify;

    my $inotify = Linux::Inotify2-> new;
    $inotify-> watch( ... ); # as usual, see Linux::Inotify2 doc

    # this lambda runs forever until manually stopped
    my $server = inotify_server($inotify);
    $server-> start;

    # rest of IO-Lambda non-blocking code

=head1 DESCRIPTION

Bridge between Linux::Inotify2 and IO::Lambda tries to be absolutely non-invasive to
the non-blocking programming style advertized by Linux::Inotify2 . The only requirements
for the programmer is to register $inotify objects with inotify_server and let the resulting
lambda running forever, or stop it when the $inotify object is not needed anymore.

C<inotify_server> is exported by default, as it is the only function in the module, and 
can take more than one $inotify object in its arguments.

=head1 SEE ALSO

L<IO::Lambda>, L<Linux::Inotify2>

=head1 AUTHORS

Idea: Peter Gordon

Implementation: Dmitry Karasik, E<lt>dmitry@karasik.eu.orgE<gt>.

=cut
