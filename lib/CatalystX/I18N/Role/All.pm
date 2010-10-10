# ============================================================================
package CatalystX::I18N::Role::All;
# ============================================================================

use CatalystX::I18N::Meta::Role;
use Moose::Role -metaclass => 'CatalystX::I18N::Meta::Role';

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

This role is just a shortcut for loading every I18N role and trait 
individually.

 use Catalyst qw/CatalystX::I18N::Role::All/;

Is same as

 use Catalyst qw/
     +CatalystX::I18N::Role::Base
     +CatalystX::I18N::Role::GetLocale
     +CatalystX::I18N::Role::DateTime
     +CatalystX::I18N::Role::Maketext
 /;
 
 use CatalystX::RoleApplicator;
 __PACKAGE__->apply_request_class_roles(qw/CatalystX::I18N::TraitFor::Request/);
 __PACKAGE__->apply_response_class_roles(qw/CatalystX::I18N::TraitFor::Response/);

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    
    L<http://www.revdev.at>
