#!perl
use strict;
use warnings;

use Test::Most tests=>19;

use lib qw(t/);
use testlib;


my $mech = init();
$mech->{catalyst_debug} = 1;

# Test 1
{
    my $response = request($mech,'/base/test1');
    is($response->{locale},'en_US','Default locale');
    is($response->{locale},'en_US','Default locale');
}

# Test 2
{
    my $response = request($mech,'/base/test2');
    is($response->{locale},'de_AT','Session locale');
}

# Test 3
{
    $mech->add_header( 'user-agent' => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; fr; rv:1.9.2) Gecko/20100115 Firefox/3.6" );
    my $response = request($mech,'/base/test3');
    is($response->{browser},'fr_CH','Browser locale');
    is($response->{session},'de_AT','Session locale');
    is($response->{user},undef,'User locale');
}

# Test 4
{
    $mech->add_header( 'user-agent' => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; fr; rv:1.9.2) Gecko/20100115 Firefox/3.6" );
    my $response = request($mech,'/base/test4');
    is($response->{datetime}{locale},'German Austria','DateTime locale');
    is($response->{datetime}{timezone},'Europe/Vienna','DateTime timezone');
    is($response->{locale},'de_AT','Locale');
    is($response->{locale_from_c},'de_AT','Locale from $c');
    is($response->{request}{browser_language},'fr','Browser language');
}