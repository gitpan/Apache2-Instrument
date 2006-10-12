package Apache2::Instrument::Time;
use strict;

our $VERSION = '0.01';

use base qw(Apache2::Instrument);

use Apache2::Const qw(OK);
use Time::HiRes qw(gettimeofday tv_interval);

sub before {
    my ($class, $r, $notes) = @_;
    
    $notes->{before} = [gettimeofday];
    
    return OK;
}

sub after {
    my ($class, $r, $notes) = @_;
    $notes->{after} = [gettimeofday];
    return OK;
}

sub report {
    my ($class, $r, $notes) = @_;
    
    my $e = tv_interval($notes->{before}, $notes->{after});
    return { interval => $e };
}
