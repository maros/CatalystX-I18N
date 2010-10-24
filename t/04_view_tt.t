#!perl
use strict;
use warnings;

use Test::Most tests=>8+1;
use Test::NoWarnings; 

use lib qw(t/testapp/lib);

use Catalyst::Test 'TestApp';

{
    my($response) = get('/base/test7');
    my @lines = split(/\n/,$response);
    is($lines[0],'<div>1K</div>');
    is($lines[1],'<div>12</div>');
    is($lines[2],'<div>-12,2</div>');
    is($lines[3],'<div>++EUR 22,00</div>');
    is($lines[4],'<div>-EUR 23,00</div>');
    is($lines[5],'<div>++EUR 233.634,23</div>');
    is($lines[6],'<div>-12,2</div>');
    is($lines[7],'<div>-12,200</div>');
}
