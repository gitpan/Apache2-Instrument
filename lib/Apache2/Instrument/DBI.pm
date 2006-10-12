package Apache2::Instrument::DBI;
use strict;

our $VERSION = '0.01';

use base qw(Apache2::Instrument);

use Apache2::Const qw(OK);

use DBI::Profile;

sub connect {
    my $class = shift;
    unshift @_, $class if ref $class;
    my $drh    = shift;

    my @args   = map { defined $_ ? $_ : "" } @_;
    
    my $h = $drh->connect(@args);
    
    my $r = Apache2::RequestUtil->request;
    my $notes = __PACKAGE__->notes($r);
    
    $notes->{profile} ||= DBI::Profile->new();
    $h->{Profile} = $notes->{profile};
    $notes->{h} = $h;
    return $h;
}

sub before {
    my ($class, $r, $notes) = @_;
    
    # Turn on profiling by hijacking connect()
    $notes->{connect} = $DBI::connect_via;
    $DBI::connect_via = "${class}::connect";
    
    return OK;
}

sub after {
    my ($class, $r, $notes) = @_;
    # Remove our hijack and disable profiling
    $DBI::connect_via = $notes->{connect};
    $notes->{h}{Profile} = undef;

    return OK;
}

use YAML;
sub report {
    my ($class, $r, $notes) = @_;
    #Disable default print STDERR behaviour
    local $DBI::Profile::ON_DESTROY_DUMP = sub { };
    
    # Grab a pretty output
    my $format = $notes->{profile}->format;
    
    #kill the profiling object
    $notes->{profile} = undef;
    
    return { format => $format };
}

1;
