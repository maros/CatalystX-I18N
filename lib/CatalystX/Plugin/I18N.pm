# ============================================================================
package CatalystX::I18N::Plugin::I18N;
# ============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
 
use Moose;
use Moose::Util::TypeConstraints;

use POSIX qw(locale_h);

use DateTime;
use DateTime::Format::CLDR;
use DateTime::TimeZone;
use DateTime::Locale;

use Number::Format;

use IP::Country::Fast;

subtype 'Locale'
    => as 'Str'
    => where {
        m/^[a-z]{2}[_-][A-Z]{2}/
    };

subtype 'DateTimeTimezone' => as class_type('DateTime::TimeZone');

subtype 'DateTimeLocale' => as class_type('DateTime::Locale::Base');

subtype 'Locale'
    => as 'Str'
    => where {
        m/^[a-z]{2}[_-][A-Z]{2}/
    };

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

has 'timezone' => (
    is => 'rw', 
    isa => 'DateTimeTimezone',
    trigger => \&_set_timezone,
    coerce => 1,
);

has 'locale' => (
    is => 'rw', 
    isa => 'Locale',
    default => 'en_US.UTF-8',
    trigger => \&_set_locale,
);

has 'language' => (
    is => 'ro', 
    isa => 'Str'
);

has 'territory' => (
    is => 'ro', 
    isa => 'Str'
);

has 'datetime_locale' => (
    is => 'rw', 
    isa => 'DateTimeLocale',
    coerce => 1,
);

has 'datetime_format_date' => (
    is => 'rw', 
    isa => 'DateTime::Format::CLDR'
);

has 'datetime_format_datetime' => (
    is => 'rw', 
    isa => 'DateTime::Format::CLDR'
);

has 'numberformat' => (
    is => 'rw', 
    isa => 'Number::Format'
);

has 'l10nhandle' => (
    is => 'rw', 
    isa => 'Locale::Maketext::Lexicon'
);


 
sub now {
    my ($c) = @_;
    return DateTime->from_epoch(
        epoch     => time(),
        time_zone => $c->timezone,
        locale    => $c->datetime_locale
    );
}

sub today {
    my ($c) = @_;
    return $c->now->truncate( to => 'day' );
}

sub _set_datetime_format {
    my ($c,$params) = @_;
    
    $params ||= {};
    
    my $timezone =
        $params->{timezone} ||
        $c->timezone || 
        DateTime::TimeZone->new( name => 'UTC' );
        
    my $datetime_locale = 
        $params->{datetime_locale} ||
        $c->datetime_locale || 
        DateTime::Locale->load('en');
    
    $c->datetime_format_date(
        new DateTime::Format::CLDR(
            locale      => $datetime_locale,
            time_zone   => $timezone,
            pattern     => $datetime_locale->date_format_medium
        )
    );
    
    $c->datetime_format_datetime(
        new DateTime::Format::CLDR(
            locale      => $datetime_locale,
            time_zone   => $timezone,
            pattern     => $datetime_locale->date_format_medium.' '.$datetime_locale->time_format_short
        )
    );
}

sub _set_timezone {
    my ($c,$value) = @_;
    
    $c->_set_datetime_format(
        {
            timezone    => $value,
        }
    );
}

sub _set_locale {
    my ($c,$value) = @_;
    
    my ($language,$territory) =
        $c->check_locale($value);
        
    return
        unless ($language && $territory);   
    
    my $locale = $language.'_'.$territory;
    
    # Set language and territory
    $c->language($language);
    $c->territory($territory);
    
    # Store to session
    $c->session->{locale} = $locale
        if $c->can('session');
        
    # Set posix locale
    setlocale( LC_CTYPE, $locale.'.UTF-8' );
    my $lconv = POSIX::localeconv();
    
    # Set number format
    $c->numberformat(
        new Number::Format(
            -int_curr_symbol    => ($lconv->{int_curr_symbol} // 'EUR'),
            -currency_symbol    => ($lconv->{currency_symbol} // '€'),
            -mon_decimal_point  => ($lconv->{mon_decimal_point} // '.'),
            -mon_thousands_sep  => ($lconv->{mon_thousands_sep} // ','),
            -mon_grouping       => $lconv->{mon_grouping},
            -positive_sign      => ($lconv->{positive_sign} // ''),
            -negative_sign      => ($lconv->{negative_sign} // '-'),
            -int_frac_digits    => ($lconv->{int_frac_digits} // 2),
            -frac_digits        => ($lconv->{frac_digits} // 2),
            -p_cs_precedes      => ($lconv->{p_cs_precedes} // 1),
            -p_sep_by_space     => ($lconv->{p_sep_by_space} // 1),
            -n_cs_precedes      => ($lconv->{n_cs_precedes} // 1),
            -n_sep_by_space     => ($lconv->{n_sep_by_space} // 1),
            -p_sign_posn        => ($lconv->{p_sign_posn} // 1),
            -n_sign_posn        => ($lconv->{n_sign_posn} // 1),

            -thousands_sep      => ($lconv->{thousands_sep} // ','),
            -decimal_point      => ($lconv->{decimal_point} // '.'),
            -grouping           => $lconv->{grouping},
            
            -decimal_fill       => 0,
            -neg_format         => ($lconv->{negative_sign} // '-').'x',
            -decimal_digits     => ($lconv->{frac_digits} // 2),
        )
    );

    # Set datetime locale
    my $datetime_locale = DateTime::Locale->load( $locale );
    $c->datetime_locale($datetime_locale);
    
    # Set DateTime::Format::CLDR
    $c->_set_datetime_format(
        {
            datetime_locale => $datetime_locale,
        }
    );
}

sub check_locale {
    my ( $c, $value ) = @_;

    return 
        unless $value =~ /^(?<language>[a-z]{2})[_-](?<territory>[A-Z]{2})/;
        
    my $language = $+{language};
    my $territory = $+{territory};
    my $locale = $language.'_'.$territory;

    return 
        unless exists $c->config->{I18N}{locales}{$locale};

    retrun ($language,$territory);
}

__PACKAGE__->meta->make_immutable();


1;
