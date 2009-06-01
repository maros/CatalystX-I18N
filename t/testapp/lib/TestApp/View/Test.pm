package TestApp::View::Test;

use strict;
use warnings;

use parent 'Catalyst::View';

sub process {
    my ( $self, $c ) = @_;

    my $output = '';
    foreach my $keys (keys %{$c->stash}) {
        $output .= $key.':'.$c->stash->{$key}."\n";
    }

    $c->response->content_type('text/plain; charset=utf-8');
    $c->response->body($output);
    
    return;
}

1;