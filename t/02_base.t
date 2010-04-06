use strict;
use warnings;

use Test::Most tests=>10;
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
    explain $response;
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