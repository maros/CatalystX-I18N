#!perl
use strict;
use warnings;

use Test::Most tests=>44+1;
use Test::NoWarnings;

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
    is($response->{number_format},'++EUR  27,03','Browser language');
}

# Test 5a
{
    my $response = request($mech,'/base/test5/de_AT');
    is($response->{locale},'de_AT','Locale');
    is($response->{translation}{1},'string1 de_AT','String 1 for de_AT ok');
    is($response->{translation}{4},'string4 de_AT 4 hasen','String 4 for de_AT ok');
    is($response->{translation}{5},'string5 de','String 5 for de_AT ok');
    is($response->{translation}{6},'string6','String 6 for de_AT ok');
}

# Test 5b
{
    my $response = request($mech,'/base/test5/de_CH');
    is($response->{locale},'de_CH','Locale');
    is($response->{translation}{1},'string1 de','String 1 for de_CH ok');
    is($response->{translation}{4},'string4 de 4 hasen','String 4 for de_CH ok');
    is($response->{translation}{5},'string5 de','String 5 for de_CH ok');
    is($response->{translation}{6},'string6','String 6 for de_CH ok');
}

# Test 5c
{
    my $response = request($mech,'/base/test5/fr_CH');
    is($response->{locale},'fr_CH','Locale');
    is($response->{translation}{1},'string1 fr_CH','String 1 for fr_CH ok');
    is($response->{translation}{4},'string4 fr_CH 4 lapins','String 4 for fr_CH ok');
    is($response->{translation}{5},'string5','String 5 for fr_CH ok');
    is($response->{translation}{6},'string6','String 6 for fr_CH ok');
}

# Test 6
{
    my $response = request($mech,'/base/test6');
    cmp_deeply($response,{
       'de_AT' => {
         'timezone' => 'Europe/Vienna'
       },
       'de_CH' => {
         'timezone' => 'Europe/Zurich'
       },
       'de_DE' => {
         'timezone' => 'Europe/Berlin'
       },
       'fr_CH' => {
         'timezone' => 'Europe/Zurich'
       }
    },'Multiple locales ok');
}