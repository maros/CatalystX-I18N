# ============================================================================
package CatalystX::I18N::TypeConstraints;
# ============================================================================

use Moose::Util::TypeConstraints;
use DateTime::TimeZone;
use DateTime::Locale;
use MooseX::Types::Path::Class;
#use Params::Coerce;

enum 'Lexicon' => qw(auto gettext msgcat tie);

subtype 'CatalystX::I18N::Type::Territory'
    => as 'Str'
    => where { m/^[A-Z]{2}$/ };

subtype 'CatalystX::I18N::Type::Locale'
    => as 'Str'
    => where { m/^[a-z]{2}(_[A-Z]{2})?$/ };

subtype 'CatalystX::I18N::Type::Language'
    => as 'Str'
    => where { m/^[a-z]{2}$/ };

subtype 'CatalystX::I18N::Type::Languages'
    => as 'ArrayRef[CatalystX::I18N::Type::Language]';

coerce  'CatalystX::I18N::Type::Languages'
    => from 'Str'
    => via { return [ $_ ] };

subtype 'CatalystX::I18N::Type::DirList'
    => as 'ArrayRef[Path::Class::Dir]';
    
coerce 'CatalystX::I18N::Type::DirList'
    => from 'Path::Class::Dir'
    => via { 
        [ $_ ]
    };

subtype 'CatalystX::I18N::Type::DateTimeTimezone' 
    => as class_type('DateTime::TimeZone');

subtype 'CatalystX::I18N::Type::DateTimeLocale' 
    => as class_type('DateTime::Locale::Base');

coerce 'CatalystX::I18N::Type::DateTimeTimezone'
    => from 'Str'
    => via { 
        DateTime::TimeZone->new( name => $_ ) 
    };
    
coerce 'CatalystX::I18N::Type::DateTimeLocale'
    => from 'Str'
    => via { 
        DateTime::Locale->load( $_ ) 
    };

subtype 'CatalystX::I18N::Type::L10NHandle'
    => as duck_type(qw(maketext));

1;