# ============================================================================
package CatalystX::I18N::Role::NumberFormat;
# ============================================================================

use Moose::Role;

use CatalystX::I18N::TypeConstraints;

use Number::Format;

has 'i18n_numberformat' => (
    is          => 'rw',
    isa         => 'Number::Format',
    lazy_build  => 1,
    builder     => '_build_i18n_numberformat',
    clearer     => '_clear_i18n_numberformat',
);

sub _build_i18n_numberformat {
    my ($c) = @_;
    
    carp('No locale set')
        unless $c->has_locale;
    
    my $locale = $c->locale;
    my $config = $c->i18n_config;
    
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
    
    return $numberformat;
}

after 'set_locale' => sub {
    my ($c,$locale) = @_;
    $c->_clear_i18n_numberformat();
};

no Moose::Role;
1;

=head1 NAME

CatalystX::I18N::Role::NumberFormat - Support for I18N number formating

=head1 SYNOPSIS

 package MyApp::Catalyst;
 
 use Catalyst qw/MyPlugins 
    CatalystX::I18N::Role::Base
    CatalystX::I18N::Role::NumberFormat/;
 
 
 package MyApp::Catalyst::Controller::Main;
 use strict;
 use warnings;
 use parent qw/Catalyst::Controller/;
 
 sub action : Local {
     my ($self,$c) = @_;
     
     $c->stash->{total} = $c->i18n_numberformat->format_price(102.34);
 }
=head1 DESCRIPTION

This role add support for localized numbers to your Catalyst application.

All methods are lazy. This means that the values will be only calculated
upon the first call of the method.

=head1 MEDTHODS

=head3 i18n_numberformat

 my $number_format = $c->i18n_numberformat;

Returns a L<Number::Format> object for your current locale. 

The L<Number::Format> settings will be taken from L<POSIX::localeconv> but 
can be overdriven in your Catalyst I18N configuration:

 # Add some I18N configuration
 __PACKAGE__->config( 
     name    => 'MyApp', 
     I18N    => {
         default_locale          => 'de_AT',
         locales                 => {
             'de_AT'                 => {
                 int_curr_symbol        => 'EURO',
             },
         }
     },
 );

The following configuration options are available (see L<Number::Format> for
detailed documentation):

=over

=item * int_curr_symbol

=item * currency_symbol

=item * mon_decimal_point

=item * mon_thousands_sep

=item * mon_grouping

=item * positive_sign

=item * negative_sign

=item * int_frac_digits

=item * frac_digits

=item * p_cs_precedes

=item * p_sep_by_space

=item * n_cs_precedes

=item * n_sep_by_space

=item * p_sign_posn

=item * n_sign_posn

=item * thousands_sep

=item * decimal_point

=item * decimal_fill

=item * neg_format

=item * decimal_digits

=back

=head1 SEE ALSO

L<Number::Format>

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    
    L<http://www.revdev.at>