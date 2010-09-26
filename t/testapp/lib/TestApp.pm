package TestApp;

use strict;
use Catalyst qw/
    Session
    Session::Store::File 
    Session::State::Cookie
    
    +CatalystX::I18N::Role::Base
    +CatalystX::I18N::Role::DateTime
    +CatalystX::I18N::Role::Maketext
    +CatalystX::I18N::Role::GetLocale
/;
use CatalystX::RoleApplicator;

__PACKAGE__->apply_request_class_roles(qw/CatalystX::I18N::Role::Request/);
__PACKAGE__->apply_response_class_roles(qw/CatalystX::I18N::Role::Response/);

our $VERSION = '0.01';

TestApp->config( 
    name    => 'TestApp', 
    session => {
          
    },
    'Model::L10N' => {},
    I18N    => {
        default_locale          => 'de_AT',
        locales                 => {
            'de_AT'                 => {
                timezone                => 'Europe/Vienna',
                datetime_format_date    => 'dd.MM.yyyy',
                datetime_format_datetime=> 'dd.MM.yyyy uma HH:mm',
                positive_sign           => '+',
            },
            'de_DE'                 => {
                timezone                => 'Europe/Berlin',
            },
            'de_CH'                 => {
                timezone                => 'Europe/Zurich',
            },
            'fr_CH'                 => {
                timezone                => 'Europe/Zurich',
            },
        }
    },
);

TestApp->setup;

1;
