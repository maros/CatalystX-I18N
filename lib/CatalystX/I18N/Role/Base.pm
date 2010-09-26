# ============================================================================
package CatalystX::I18N::Role::Base;
# ============================================================================

use Moose::Role;

use CatalystX::I18N::TypeConstraints;

use POSIX qw(locale_h);

use DateTime;
use DateTime::Format::CLDR;
use DateTime::TimeZone;
use DateTime::Locale;

use Number::Format;

has 'timezone' => (
    is => 'rw', 
    isa => 'CatalystX::I18N::Type::DateTimeTimezone',
);

has 'locale' => (
    is      => 'rw',
    isa     => 'CatalystX::I18N::Type::Locale',
    default => 'en_US',
    trigger => \&_set_locale,
    predicate   => 'has_locale'
);

has 'datetime_locale' => (
    is      => 'rw',
    isa     => 'CatalystX::I18N::Type::DateTimeLocale',
);

has 'datetime_format_date' => (
    is      => 'rw',
    isa     => 'DateTime::Format::CLDR'
);

has 'datetime_format_datetime' => (
    is      => 'rw',
    isa     => 'DateTime::Format::CLDR'
);

has 'numberformat' => (
    is      => 'rw',
    isa     => 'Number::Format'
);

has 'l10nhandle' => (
    is      => 'rw',
    #isa     => 'L10NHandle'
);

=head2 ACCESSORS

=head3 locale

Get/set the current locale. Changing the locale alters the following
accessors:

=over

=item * timezone

=item * language

=item * territory

=item * datetime_locale

=item * datetime_format_datetime

=item * datetime_format_date

=item * numberformat

=item * l10nhandle

=back

=head3 timezone

C<DateTime::TimeZone> object for the current locale

=head3 timezone

C<DateTime::TimeZone> object for the current locale

=head3 timezone


=head2 METHODS

=head3 territory

The current territory as an uppercase 3166-1 alpha-2 code. (eg. UK)

=head3 language

The current language as a lowercase alpha-2 code. (eg. en)

=head3 today
 
 my $dt = $c->today
 say $dt->dmy;
 
Returns the current timestamp as a C<DateTime> object with the current 
timezone and locale set.
 
=cut
 
sub now {
    my ($c) = @_;
    return DateTime->from_epoch(
        epoch     => time(),
        time_zone => $c->timezone || 'Floating',
        locale    => $c->datetime_locale || 'en',
    );
}

=head3 today
 
 my $dt = $c->today
 say $dt->dmy;
 
Returns a C<DateTime> with todays date, the current timezone and locale set.
 
=cut

sub today {
    my ($c) = @_;
    return $c->now->truncate( to => 'day' );
}

sub locale_config {
    my ($c) = @_;
    
    return $c->config->{$c->locale} || {};
}

=head3 geodcode
 
 my $lgt = $c->geodcode
 say $lgt->name;
 
Returns a C<Locale::Geocode::Territory> object for the current territory
 
=cut

sub geocode {
    my ($c) = @_;
    
    my $territory = $c->territory;
    
    return 
        unless $territory;
    
    Class::MOP::load_class('Locale::Geocode');
    
    my $lc = new Locale::Geocode;
    return $lc->lookup($territory);
} 

sub language {
    my ($self) = @_;
    
    return 
        unless $self->has_locale();
    
    return 
        unless $self->locale =~ /^(?<language>[a-z]{2})_(?<territory>[A-Z]{2})(\..+)/;
    
    return lc($+{language});
}

sub territory {
    my ($self) = @_;
    
    return 
        unless $self->has_locale();
    
    return 
        unless $self->locale =~ /^(?<language>[a-z]{2})_(?<territory>[A-Z]{2})(\..+)/;
    
    return lc($+{territory});
}

sub _set_locale {
    my ($c,$value) = @_;
    
    return 
        unless $value =~ /^(?<language>[a-z]{2})_(?<territory>[A-Z]{2})(\..+)?/;
        
    my $language = lc($+{language});
    my $territory = uc($+{territory});
    my $locale = $language.'_'.$territory;

    return 
        unless exists $c->config->{I18N}{locales}{$locale};
    
    my $config = $c->config->{I18N}{locales}{$locale};
    
    # Set posix locale
    setlocale( LC_CTYPE, $locale.'.UTF-8' );
    my $lconv = POSIX::localeconv();
    
    # Set number format
    my $numberformat = new Number::Format(
        -int_curr_symbol    => ($config->{int_curr_symbol} // $lconv->{int_curr_symbol} // 'EUR'),
        -currency_symbol    => ($config->{currency_symbol} // $lconv->{currency_symbol} // '€'),
        -mon_decimal_point  => ($config->{mon_decimal_point} // $lconv->{mon_decimal_point} // '.'),
        -mon_thousands_sep  => ($config->{mon_thousands_sep} // $lconv->{mon_thousands_sep} // ','),
        -mon_grouping       => ($config->{mon_grouping} // $lconv->{mon_grouping}),
        -positive_sign      => ($config->{positive_sign} // $lconv->{positive_sign} // ''),
        -negative_sign      => ($config->{negative_sign} // $lconv->{negative_sign} // '-'),
        -int_frac_digits    => ($config->{int_frac_digits} // $lconv->{int_frac_digits} // 2),
        -frac_digits        => ($config->{frac_digits} // $lconv->{frac_digits} // 2),
        -p_cs_precedes      => ($config->{p_cs_precedes} // $lconv->{p_cs_precedes} // 1),
        -p_sep_by_space     => ($config->{p_sep_by_space} // $lconv->{p_sep_by_space} // 1),
        -n_cs_precedes      => ($config->{n_cs_precedes} // $lconv->{n_cs_precedes} // 1),
        -n_sep_by_space     => ($config->{n_sep_by_space} // $lconv->{n_sep_by_space} // 1),
        -p_sign_posn        => ($config->{p_sign_posn} // $lconv->{p_sign_posn} // 1),
        -n_sign_posn        => ($config->{n_sign_posn} // $lconv->{n_sign_posn} // 1),

        -thousands_sep      => ($config->{thousands_sep} // $lconv->{thousands_sep} // ','),
        -decimal_point      => ($config->{decimal_point} // $lconv->{decimal_point} // '.'),
#        -grouping           => ($config->{grouping} // $lconv->{grouping}),
        
        -decimal_fill       => ($config->{decimal_fill} // 0),
        -neg_format         => ($config->{negative_sign} // $lconv->{negative_sign} // '-').'x',
        -decimal_digits     => ($config->{frac_digits} // $lconv->{frac_digits} // 2),
    );
    
    $c->numberformat($numberformat);

    # Set datetime locale
    my $datetime_locale = DateTime::Locale->load( $locale );
    $c->datetime_locale($datetime_locale);
    
    # Set timezone
    my $timezone = DateTime::TimeZone->new( name => $config->{timezone} || 'Floating' );
    $c->timezone($timezone);

    # Set datetime_format_date
    my $datetime_format_date =
        $config->{datetime_format_date} ||
        $datetime_locale->date_format_medium;
        
    # Set datetime_format_datetime
    my $datetime_format_datetime =
        $config->{datetime_format_datetime} ||
        $datetime_locale->date_format_medium.' '.$datetime_locale->time_format_short;
    
    $c->datetime_format_date(
        new DateTime::Format::CLDR(
            locale      => $datetime_locale,
            time_zone   => $timezone,
            pattern     => $datetime_format_date
        )
    );
    
    $c->datetime_format_datetime(
        new DateTime::Format::CLDR(
            locale      => $datetime_locale,
            time_zone   => $timezone,
            pattern     => $datetime_format_datetime
        )
    );
    
    # Set content language header
    $c->response->content_language($language)
        if $c->response->can('content_language');
    
    # Save locale in session
    $c->session->{i18n_locale} = $locale
        if ($c->can('session'));
    
    # Set L10N Handle
    my $l10nhandle = $c->model('L10N');
    
    # L10N Handle
    $c->l10nhandle(
        $l10nhandle
    );
}

1;
