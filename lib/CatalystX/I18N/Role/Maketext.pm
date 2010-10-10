# ============================================================================
package CatalystX::I18N::Role::Maketext;
# ============================================================================

use Moose::Role;

sub maketext {
    my ($c,$msgid,@args) = @_;
    
    my @args_expand;
    foreach my $arg (@args) {
        push @args_expand,
            (ref $arg eq 'ARRAY') ? @$arg : $arg;
    }
    
    # TODO: Check if L10N model is available
    my $handle = $c->model('L10N');
    my $msgstr = $handle->maketext( $msgid, @args_expand );
    
    return $msgstr
        if defined $msgstr;
    
    # Method expansion
    my $replacesub = sub {
        my $method = shift;
        my @params = split(/,/,shift);
        if ($handle->can($method)) {
            return $handle->$method(@params);
        }
        return $method;
    };
    
    # TODO: use gettext/maketext style
    $msgstr = $msgid;
    $msgstr =~s{%(\d+)}{ $args[$1-1] || 'missing value %'.$1 }eg;
    $msgstr =~s/%(\w+)\(([^)]+)\)/$replacesub->($1,$2)/eg;
    
    return $msgstr;
}

#no warnings 'once';
#*localize = \&maketext;

no Moose::Role;
1;

=encoding utf8

=head1 NAME

CatalystX::I18N::Role::Maketext - Support for maketext L10N

=head1 SYNOPSIS

 package MyApp::Catalyst;
 
 use Catalyst qw/MyPlugins 
    CatalystX::I18N::Role::Base
    CatalystX::I18N::Role::Maketext/;
 
 
 package MyApp::Model::L10N;
 use parent qw/CatalystX::I18N::Model::L10N/;
 
 
 package MyApp::Catalyst::Controller::Main;
 use strict;
 use warnings;
 use parent qw/Catalyst::Controller/;
 
 sub action : Local {
     my ($self,$c) = @_;
     
     $c->stash->{results} = $c->maketext('Your search found %quant(%1,result,results)',$count);
 }

=head1 DESCRIPTION

This role adds support for L<Locale::Maketext> localisation via the
L<CatalystX::I18N::Model::L10N> model.

=head1 METHODS

=head3 maketext

 my $translated_string = $c->maketext($msgid,@params);
 OR
 my $translated_string = $c->maketext($msgid,\@params);

Translates a string via L<Locale::Maketext>

=head1 SEE ALSO

L<Locale::Maketext>, L<CatalystX::I18N::Model::L10N> 
and L<CatalystX::I18N::L10N>

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    
    L<http://www.revdev.at>