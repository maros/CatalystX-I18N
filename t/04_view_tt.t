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
    is($lines[0],'1K','Format 1 ok');
    is($lines[1],'12','Format 2 ok');
    is($lines[2],'-12,2','Format 3 ok');
    is($lines[3],'++EUR 22,00','Format 4 ok');
    is($lines[4],'-EUR 23,00','Format 5 ok');
    is($lines[5],'++EUR 233.634,23','Format 6 ok');
    is($lines[6],'-12,2','Format 7 ok');
    is($lines[7],'-12,200','Format 8 ok');
    is($lines[8],'string4 de_AT 4 hasen','Format 9 ok');
    is($lines[9],'string4 de_AT 1 hase','Format 10 ok');
    is($lines[10],'Afghanistan,Ägypten,Albanien,Algerien,Andorra,Äquatorialguinea,Äthiopien,Bahamas,Zypern','Collate 1 ok');
    is($lines[11],'Afghanistan,Albanien,Algerien,Andorra,Bahamas,Zypern,Ägypten,Äquatorialguinea,Äthiopien','Collate 2 ok');
}
