package Apache2::Instrument;
use strict;

our $VERSION = '0.01';

use Apache2::Const qw(OK);
use Apache2::RequestUtil ();
use Apache2::RequestRec ();

sub notes {
    my ($class, $r, $v) = @_;
    if (defined $v) {
        return $r->pnotes($class, $v);
    }
    else {
        return $r->pnotes($class) || {};
    }
}

sub handler : method {
    my ($class, $r) = @_;
    
    $r->push_handlers('CleanupHandler' => "${class}->cleanup" );
    
    my $note = $r->pnotes($class) || {};
    
    $class->before($r, $note);
    
    $r->pnotes($class, $note);
    
return OK;
}

sub cleanup : method {
    my ($class, $r) = @_;
    
    my $note = $r->pnotes($class) || {};
    
    $class->after($r, $note);
    
    my $req = $r->the_request;
    my $report = $class->report($r, $note);
    my $dump = Dumper($report); use Data::Dumper;
    
    warn "$class: $req: $dump\n";

return OK;
}

1;
