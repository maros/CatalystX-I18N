# ============================================================================
package CatalystX::I18N::TraitFor::ViewTT;
# ============================================================================

use Moose::Role;
requires qw(template);

around render => sub {
    my $orig  = shift;
    my ( $self,$c,$template,$args ) = @_;
    
    no warnings 'once';
    
    local $Template::Stash::HASH_OPS;
    local $Template::Stash::LIST_OPS;
    
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

    $config->{FILTERS}{number} ||= [ \&_i18n_numberformat_factory, 1 ];
    #$config->{FILTERS}{maketext} ||= [ \&_i18n_maketext_factory, 1 ];
    
    # Call original BUILDARGS
    return $self->$orig($app,$config);
};

sub _i18n_numberformat_factory {
    my ( $context, $format, @options ) = @_;
    
    my $c = $context->stash->get('c');
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

#sub _i18n_maketext_factory {
#    my ( $context ) = @_;
#    
#    my $c = $context->stash->get('c');
#    
#    return sub {
#        my ($msgid,@params) = @_;
#        
#        if (scalar @params == 1
#            && ref($params[0]) eq 'ARRAY') {
#            @params = @{$params[0]};
#        }
#        
#        return $c->maketext($msgid,@params);
#    }
#}

no Moose::Role;
1;


=head1 NAME

CatalystX::I18N::TraitFor::ViewTT - Adds number format filters to a TT view

=head1 SYNOPSIS

 # In your view
 package MyApp::View::TT; 
 use Moose;
 extends qw(Catalyst::View::TT);
 with qw(CatalystX::I18N::TraitFor::ViewTT);
 
 
 # In your TT template
 [% 22 | number('number') %]

=head1 DESCRIPTION

This role simply adds a number format filter to TT.

The following formats are available 

=over

=item * price

=item * number

=item * bytes

=item * negative

=item * picture

=back 

=head1 SEE ALSO

L<Number::Format>, L<CatalystX::I18N::Role::NumberFormat>, 
L<Catalyst::View::TT>

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    
    L<http://www.revdev.at>
