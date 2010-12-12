# ============================================================================
package CatalystX::I18N::Role::All;
# ============================================================================

use CatalystX::I18N::Meta::Role;
use Moose::Role -metaclass => 'CatalystX::I18N::Meta::Role';
requires qw(response_class request_class);


with qw(
    CatalystX::I18N::Role::Base
    CatalystX::I18N::Role::DateTime
    CatalystX::I18N::Role::Maketext
    CatalystX::I18N::Role::GetLocale
    CatalystX::I18N::Role::NumberFormat
    CatalystX::I18N::Role::Collate
);


around 'setup_component' => sub {
    my $orig  = shift;
    my ($self,$component) = @_;
    
    Class::MOP::load_class($component);
    
    if ($component->isa('Catalyst::View::TT')
        && $component->can('meta')) {
        my $component_meta = $component->meta;
        unless ($component_meta->does_role('CatalystX::I18N::TraitFor::ViewTT')) {
            if ($component_meta->is_mutable) {
                Moose::Util::apply_all_roles($component_meta, 'CatalystX::I18N::TraitFor::ViewTT')
            }
        }
    }
    
    return $self->$orig($component);
};

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
     +CatalystX::I18N::Role::Collate
 /;
 
 use CatalystX::RoleApplicator;
 __PACKAGE__->apply_request_class_roles(qw/CatalystX::I18N::TraitFor::Request/);
 __PACKAGE__->apply_response_class_roles(qw/CatalystX::I18N::TraitFor::Response/);

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    
    L<http://www.revdev.at>
