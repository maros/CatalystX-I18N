#!perl
use strict;
use warnings;

use Test::Most tests=>7;
#use Test::NoWarnings; 
# Cannot run with NoWarnings since we get a warning from HTTP::BrowserDetect
# wen running under make test

use lib qw(t/testapp/lib);

use Catalyst::Test 'TestApp';

{
    my($res, $c) = ctx_request('/base/test6');
    my $request = $c->request;
    $request->header('Accept-Language','zh, fr_CH; q=0.8, fr; q=0.6');
    is($c->get_locale_from_browser,'fr_CH','Locale from accept-language');
}

{
    my($res, $c) = ctx_request('/base/test6');
    my $request = $c->request;
    $request->header('Accept-Language','zh, FR; q=0.8, fr_CH; q=0.6');
    is($c->get_locale_from_browser,'fr','Locale from accept-language');
}

{
    my($res, $c) = ctx_request('/base/test6');
    my $request = $c->request;
    $request->header('Accept-Language','zh, de-at; q=0.8, de; q=0.6');
    is($c->get_locale_from_browser,'de_AT','Locale from accept-language');
}

{
    my($res, $c) = ctx_request('/base/test6');
    my $request = $c->request;
    $request->header('Accept-Language','zh, de; q=0.8, de_at; q=0.6');
    is($c->get_locale_from_browser,'de_AT','Locale from accept-language');
}

{
    my($res, $c) = ctx_request('/base/test6');
    my $request = $c->request;
    $request->header('Accept-Language','zh, sk, fr-ca');
    $request->header('User-Agent',"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; de; rv:1.9.2) Gecko/20100115 Firefox/3.6");
    is($c->get_locale_from_browser,'fr','Locale from accept-language');
}

{
    my($res, $c) = ctx_request('/base/test6');
    my $request = $c->request;
    $request->header('Accept-Language','zh, sk, cz');
    $request->header('User-Agent',"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; fr; rv:1.9.2) Gecko/20100115 Firefox/3.6");
    is($c->get_locale_from_browser,'fr','Locale from browser');
}

{
    my($res, $c) = ctx_request('/base/test6');
    my $request = $c->request;
    $request->header('Accept-Language','zh, sk, cz');
    $request->address('84.20.181.0');
    is($c->get_locale_from_browser,'de_AT','Locale from IP');
}