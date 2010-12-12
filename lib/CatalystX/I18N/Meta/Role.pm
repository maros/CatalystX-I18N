# ============================================================================
package CatalystX::I18N::Meta::Role;
# ============================================================================

use Moose;
extends 'Moose::Meta::Role';

before 'apply' => sub {
    my ($self,$thing) = @_;
    
    my $class = $thing->name;
    
    for my $type (qw(Response Request)) {
        my $accessor_method = lc($type).'_class';
        my $super_class = $class->$accessor_method();
        
        # Get role
        my $role_class = 'CatalystX::I18N::TraitFor::'.$type;
        Class::MOP::load_class($role_class);
        
        # Check if role has already been applied
        next
            if grep { $_->meta->does_role($role_class) } $super_class->meta->linearized_isa;
        
        # Build anon class with our roles
        my $meta = Moose::Meta::Class->create_anon_class(
            superclasses => [$super_class],
            roles        => [$role_class],
            cache        => 1,
        );
        
        $class->$accessor_method($meta->name);
    }
};

__PACKAGE__->meta->make_immutable();
no Moose;
1;
