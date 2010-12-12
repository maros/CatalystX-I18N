# ============================================================================
package CatalystX::I18N::TraitFor::ViewTT;
# ============================================================================

use Moose::Role;
requires qw(template);

use Template::Stash;

use Scalar::Util qw(weaken);

around render => sub {
    my $orig  = shift;
    my ( $self,$c,$template,$args ) = @_;
    
    no warnings 'once';
    
#    local $Template::Stash::HASH_OPS;
#    local $Template::Stash::LIST_OPS;
    
    if ($c->can('i18n_collator')) {
        my $collator = $c->i18n_collator;
        
        $Template::Stash::HASH_OPS->{'lsort'}  = sub { 
            my ($hash) = @_;
            return [ $collator->sort(keys %$hash) ];
        };
        $Template::Stash::LIST_OPS->{'lsort'}  = sub { 
            my ($list) = @_;
            return $list 
                unless scalar @$list > 1;
            return [ $collator->sort(@$list) ];
        };
    }
    
    return $self->$orig($c,$template,$args);
};

around new => sub {
    my $orig  = shift;
    my ( $self,$app,$config ) = @_;
    
    $config->{CATALYST_VAR} ||= 'c';
    $config->{FILTERS} ||= {};

    if ($app->can('i18n_numberformat')) {
        $config->{FILTERS}{number} ||= [ \&_i18n_numberformat_factory, 1 ];
    }
    
    if ($app->can('maketext')) {
        $config->{FILTERS}{maketext} ||= [ \&_i18n_maketext_factory, 1 ];
    }
    
    # Call original BUILDARGS
    return $self->$orig($app,$config);
};

sub _i18n_numberformat_factory {
    my ( $context, $format, @options ) = @_;
    
    my $c = $context->stash->get('c');
    weaken $c;
    
    my $number_format = $c->i18n_numberformat;
    if (defined $format) {
        undef $format
            unless (grep { $format eq $_ } qw(number negative bytes price picture));
    }
    
    return sub {
        my $value = shift;
        
        my $local_format = 'format_'.($format || 'number');
        
        
        return $c->maketext('n/a')
            unless defined $value;
        
        return $number_format->$local_format($value,@options);
    }
}

sub _i18n_maketext_factory {
    my ( $context,@params ) = @_;
    
    my $c = $context->stash->get('c');
    weaken $c;
    
    return sub {
        my ($msgid) = @_;
        if (scalar @params == 1
            && ref($params[0]) eq 'ARRAY') {
            @params = @{$params[0]};
        }
        
        return $c->maketext($msgid,@params);
    }
}

no Moose::Role;
1;


=head1 NAME

CatalystX::I18N::TraitFor::ViewTT - Adds I18N filters and vmethods to a TT view

=head1 SYNOPSIS

 # In your view
 package MyApp::View::TT; 
 use Moose;
 extends qw(Catalyst::View::TT);
 with qw(CatalystX::I18N::TraitFor::ViewTT);
 
 
 # In your TT template
 [% 22 | number('number') %]
 
 [% mylist.lsort().join(', ') %]
 
 [% 'Hello %1!' | maketext(name) %]

=head1 DESCRIPTION

=head2 Filters

=head3 number

Formats a number with the current locale settings. You need to have
the L<CatalystX::I18N::Role::NumberFormat> role loaded in Catalyst.

The following formats are available 

=over

=item * price

=item * number

=item * bytes

=item * negative

=item * picture

=back

=head3 maketext

Returns the translation for the given string.

You need to have the L<CatalystX::I18N::Role::Maketext> role loaded in 
Catalyst.

=head2 VMethods

=head3 lsort

Locale aware collation. You need to have
the L<CatalystX::I18N::Role::Collate> role loaded in Catalyst.

=head1 SEE ALSO

L<CatalystX::I18N::Role::NumberFormat>, L<CatalystX::I18N::Role::Collate>, 
L<CatalystX::I18N::Role::Maketext> and L<Catalyst::View::TT>

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    
    L<http://www.revdev.at>
