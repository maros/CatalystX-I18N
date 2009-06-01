package TestApp;

use strict;
use Catalyst qw/
    Session
    Session::Store::File 
    Session::State::Cookie
    
    +CatalystX::Role::I18N
    +CatalystX::Role::Maketext
/;
use Catalyst::Utils;

our $VERSION = '0.01';

TestApp->config( 
    name    => 'TestApp', 
    root    => '/some/dir',
    
    session => {
          
    },
    
    I18N    => {
        default_locale          => 'de_AT',
        locales                 => {
            'de_AT'                 => {
                timezone                => 'Europe/Vienna',
                datetime_format_date    => '',
                datetime_format_datetime=> ''
            },
            'de_DE'                 => {
                timezone                => 'Europe/Berlin',
            },
        }
    },
);

TestApp->setup;

1;
