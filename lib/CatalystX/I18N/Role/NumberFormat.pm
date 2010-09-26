# ============================================================================
package CatalystX::I18N::Role::NumberFormat;
# ============================================================================

use Moose::Role;

use CatalystX::I18N::TypeConstraints;

use Number::Format;

has 'numberformat' => (
    is          => 'rw',
    isa         => 'Number::Format'
);

after 'set_locale' => sub {
    my ($c,$locale) = @_;
    
    $locale ||= $c->locale;
    
    my $config = $c->config->{I18N}{locales}{$locale};
    
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
};

1;