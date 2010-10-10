package TestApp;

use strict;
use warnings;
use Catalyst qw/
    Session
    Session::Store::File 
    Session::State::Cookie
    
    +CatalystX::I18N::Role::All
/;
#    +CatalystX::I18N::Role::Base
#    +CatalystX::I18N::Role::DateTime
#    +CatalystX::I18N::Role::Maketext
#    +CatalystX::I18N::Role::GetLocale
#    +CatalystX::I18N::Role::NumberFormat
#use CatalystX::RoleApplicator;

#__PACKAGE__->apply_request_class_roles(qw/CatalystX::I18N::TraitFor::Request/);
#__PACKAGE__->apply_response_class_roles(qw/CatalystX::I18N::TraitFor::Response/);

our $VERSION = '0.01';

TestApp->config( 
    name    => 'TestApp', 
    session => {
          
    },
    'Model::L10N' => {},
    I18N    => {
        default_locale          => 'de_AT',
        locales                 => {
            'de'                    => {
                inactive                => 1,
                format_date             => 'dd.MM.yyyy',
                format_datetime         => 'dd.MM.yyyy HH:mm',
                positive_sign           => '++',
            },
            'fr'                    => {
                format_date             => 'd MMM y',
                format_datetime         => 'd MMM y a HH:mm',
            },
            'de_AT'                 => {
                timezone                => 'Europe/Vienna',
                inherits                => 'de',
                format_datetime         => 'dd.MM.yyyy uma HH:mm',
                mon_decimal_point       => ',',
            },
            'de_DE'                 => {
                inherits                => 'de',
                timezone                => 'Europe/Berlin',
            },
            'de_CH'                 => {
                inherits                => 'de',
                timezone                => 'Europe/Zurich',
            },
            'fr_CH'                 => {
                inherits                => 'fr',
                timezone                => 'Europe/Zurich',
            },
        }
    },
);

TestApp->setup;

1;
