# ============================================================================
package CatalystX::I18N::Role::All;
# ============================================================================

use Moose::Role;
with qw(
    CatalystX::I18N::Role::Base
    CatalystX::I18N::Role::DateTime
    CatalystX::I18N::Role::Maketext
    CatalystX::I18N::Role::GetLocale
    CatalystX::I18N::Role::NumberFormat
);

no Moose::Role;
1;

=encoding utf8

=head1 NAME

CatalystX::I18N::Role::All - Load all available roles

=head1 SYNOPSIS

 package MyApp::Catalyst;
 
 use Catalyst qw/MyPlugins 
    CatalystX::I18N::Role::All/;

=head1 DESCRIPTION

This role is just a shortcut for loading every I18N role individually.

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    
    L<http://www.revdev.at>
