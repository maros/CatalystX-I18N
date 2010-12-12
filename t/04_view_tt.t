#!perl
use strict;
use warnings;

use Test::Most tests=>12+1;
use Test::NoWarnings; 

use lib qw(t/testapp/lib);

use Catalyst::Test 'TestApp';

{
    my($response) = get('/base/test7');
    my @lines = grep { s/<div>(.+)<\/div>/$1/ }split(/\n/,$response);
    is($lines[0],'1K');
    is($lines[1],'12');
    is($lines[2],'-12,2');
    is($lines[3],'++EUR 22,00');
    is($lines[4],'-EUR 23,00');
    is($lines[5],'++EUR 233.634,23');
    is($lines[6],'-12,2');
    is($lines[7],'-12,200');
    is($lines[8],'string4 de_AT 4 hasen');
    is($lines[9],'string4 de_AT 1 hase');
    is($lines[10],'Afghanistan,Ägypten,Albanien,Algerien,Andorra,Äquatorialguinea,Äthiopien,Bahamas,Zypern');
    is($lines[11],'Afghanistan,Albanien,Algerien,Andorra,Bahamas,Zypern,Ägypten,Äquatorialguinea,Äthiopien');
}
