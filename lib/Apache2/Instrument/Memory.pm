package Apache2::Instrument::Memory;
use strict;

our $VERSION = '0.01';

use base qw(Apache2::Instrument);

use GTop;
use Apache2::Const qw(OK);
use Time::HiRes qw(gettimeofday tv_interval);

my @attrs = qw(size vsize resident share rss);
sub before {
    my ($class, $r, $notes) = @_;
    
    $notes->{gtop} = GTop->new;
    $notes->{before} = $notes->{gtop}->proc_mem($$);
    
    return OK;
}

sub after {
    my ($class, $r, $notes) = @_;
    $notes->{after} = $notes->{gtop}->proc_mem($$);
    return OK;
}


sub report {
    my ($class, $r, $notes) = @_;
   
    my %res;
    foreach my $a (@attrs) {
        my $diff = $notes->{after}->$a() - $notes->{before}->$a();
        my $size = GTop::size_string($diff);
        $size =~ s/^\s+//;
        my $sign;
        $sign = '+' if ($diff > 0);
        $sign = '-' if ($diff < 0);
        $res{$a} = "$sign$size";
    }
    
    return \%res;
}
