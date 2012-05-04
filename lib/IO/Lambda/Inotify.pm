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

   use strict ;
   use IO::Lambda qw(:all);
   use Linux::Inotify2;
   use IO::Lambda::Inotify;
   
   sub timer {
       my $timeout = shift ;
       lambda {
           context $timeout ;
           timeout {
               print "RECEIVED A TIMEOUT\n" ;
           }
       }
   }
   
   # create a new object
   my $inotify = new Linux::Inotify2
      or die "unable to create new inotify object: $!";
   
   # add watchers
   $inotify->watch ("/tmp/xxx", IN_ACCESS, sub {
       my $e = shift;
       my $name = $e->fullname;
       print "$name was accessed\n" if $e->IN_ACCESS;
       print "$name is no longer mounted\n" if $e->IN_UNMOUNT;
       print "$name is gone\n" if $e->IN_IGNORED;
       print "events for $name have been lost\n" if $e->IN_Q_OVERFLOW;
       
       # cancel this watcher: remove no further events
       $e->w->cancel;
   });
   
   my $server = inotify_server($inotify);
   $server->start;
   timer(10)->wait ;

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
