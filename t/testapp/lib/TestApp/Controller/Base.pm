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
    
    my $locale = $c->get_locale();
    
    $c->detach('TestApp::View::Test',[
        {
            locale      => $locale,
        }
    ]);
}

sub test3 : Local Args(0) {
    my ($self,$c) = @_;
    
    $c->detach('TestApp::View::Test',[
        {
            session     => $c->get_locale_from_session() || undef,
            user        => $c->get_locale_from_user() || undef,
            browser     => $c->get_locale_from_browser() || undef,
        }
    ]);
}

sub test4 : Local Args(0) {
    my ($self,$c) = @_;
    
    my $locale = $c->get_locale();
    my $request = $c->request;
    
    $c->detach('TestApp::View::Test',[
        {
            locale          => $locale,
            locale_from_c   => $c->locale,
            territory       => $c->territory,
            language        => $c->language,
            datetime        => {
                date            => $c->now->dmy,
                locale          => $c->now->locale->name,
                time            => $c->now->hms,
                timezone        => $c->now->time_zone_long_name,
            },
            request         => {
                accept_language     => $request->accept_language,
                browser_language    => $request->browser_language,
                browser_territory   => $request->browser_territory,
                client_country      => $request->client_country,
                browser_detect      => ref($request->browser_detect),
            }
        }
    ]);
}
1;

