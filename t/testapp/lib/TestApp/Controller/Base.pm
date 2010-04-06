package TestApp::Controller::Base;

use strict;
use warnings;

use parent qw/Catalyst::Controller/;

sub test1 : Local Args(0) {
    my ($self,$c) = @_;
    
    $c->detach('TestApp::View::Test',[
        {
            locale  => $c->locale,
        }
    ]);
}

sub test2 : Local Args(0) {
    my ($self,$c) = @_;
    
    my $locale = $c->forward('/getlocale/get_locale');
    
    $c->detach('TestApp::View::Test',[
        {
            locale      => $locale,
        }
    ]);
}

sub test3 : Local Args(0) {
    my ($self,$c) = @_;
    
    my $session = $c->forward('/getlocale/get_locale_from_session') || undef;
    my $user = $c->forward('/getlocale/get_locale_from_user') || undef;
    my $browser = $c->forward('/getlocale/get_locale_from_browser') || undef;
    
    $c->detach('TestApp::View::Test',[
        {
            session     => $session,
            user        => $user,
            browser     => $browser,
        }
    ]);
}

1;
