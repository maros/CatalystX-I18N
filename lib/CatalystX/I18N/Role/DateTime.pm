# ============================================================================
package CatalystX::I18N::Role::DateTime;
# ============================================================================

use Moose::Role;

use CatalystX::I18N::TypeConstraints;

use DateTime;
use DateTime::Format::CLDR;
use DateTime::TimeZone;
use DateTime::Locale;

has 'timezone' => (
    is => 'rw', 
    isa => 'CatalystX::I18N::Type::DateTimeTimezone',
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
        time_zone => $c->timezone || 'floating',
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

after 'set_locale' => sub {
    my ($c,$locale) = @_;
    
    $locale ||= $c->locale;
    
    my $config = $c->config->{I18N}{locales}{$locale};
    
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
};

1;