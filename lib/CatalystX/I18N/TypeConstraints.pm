# ============================================================================
package CatalystX::I18N::TypeConstraints;
# ============================================================================

use Moose::Util::TypeConstraints;
use MooseX::Types::Path::Class;
use DateTime::TimeZone;
use DateTime::Locale;
use Params::Coerce;

enum 'Lexicon' => qw(auto gettext msgcat tie);

subtype 'Territory'
    => as 'Str'
    => where { m/^[A-Z]{2}$/ };

subtype 'Locale'
    => as 'Str'
    => where { m/^[a-z]{2}_[A-Z]{2}$/ };

subtype 'Language'
    => as 'Str'
    => where { m/^[a-z]{2}$/ };

subtype 'Languages'
    => as 'ArrayRef[Language]';

coerce  'Languages'
    => from 'Str'
    => via { return [ $_ ] };


subtype 'DateTimeTimezone' 
    => as class_type('DateTime::TimeZone');

subtype 'DateTimeLocale' 
    => as class_type('DateTime::Locale::Base');

coerce 'DateTimeTimezone'
    => from 'Str'
    => via { 
        DateTime::TimeZone->new( name => $_ ) 
    };
    
coerce 'DateTimeLocale'
    => from 'Str'
    => via { 
        DateTime::Locale->load( $_ ) 
    };

subtype 'L10NHandle'
    => as duck_type(qw(maketext));

1;