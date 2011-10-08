# ============================================================================
package CatalystX::I18N::Model::DataLocalize;
# ============================================================================

use namespace::autoclean;
use Moose;
extends 'Catalyst::Model';

has 'data_localize' => (
    is          => 'rw', 
    isa         => 'Data::Localize',
    required    => 1,
);

has 'directories' => (
    is          => 'rw', 
    isa         => 'CatalystX::I18N::Type::DirList',
    coerce      => 1,
    default     => sub { [] },
);

has '_app' => (
    is          => 'rw', 
    isa         => 'Str',
    required    => 1,
);

around BUILDARGS => sub {
    my $orig  = shift;
    my ( $self,$app,$config ) = @_;
    
    if (defined $config->{directories}
        && ref($config->{directories}) ne 'ARRAY') {
        $config->{directories} = [ $config->{directories} ];
    }
    
    # Build default directory path unless configured
    unless (defined $config->{directories}
        && scalar @{$config->{directories}} > 0) {
        my $calldir = $app;
        $calldir =~ s{::}{/}g;
        my $file = "$calldir.pm";
        my $path = $INC{$file};
        $path =~ s{\.pm$}{/DataLocalize};
        $config->{directories} = [ Path::Class::Dir->new($path) ];
    }
    
    # No DataLocalize object supplied
    unless (defined $config->{data_localize}) {
        # Get DataLocalize class
        my $class = delete($config->{class}) || $app .'::DataLocalize';
        
        # Load DataLocalize class
        eval {
            Class::MOP::load_class($class);
            return 1;
        } or Catalyst::Exception->throw(sprintf("Could not load '%s' : %s",$class,$@));
        
        Catalyst::Exception->throw(sprintf("Could initialize '%s' because is is not a 'Data::Localize' class",$class))
            unless $class->isa('Data::Localize');
        
        $config->{data_localize} = $class->new();
    }
    
    # Set _app class
    $config->{_app} = $app;
    
    # Call original BUILDARGS
    return $self->$orig($app,$config);
};

sub BUILD {
    my ($self) = @_;
    
    my $loc = $self->data_localize;
    my $app = $self->_app;
    
    # Add localizers if possible
    if ($loc->can('add_localizers')) {
        my (@locales,$config);
        $config = $app->config->{I18N}{locales};
        @locales = keys %$config;
        $app->log->debug(sprintf("Adding localizers for locales %s",join(',',@locales)))
            if $app->debug;
        $loc->add_localizers( 
            locales             => \@locales, 
            directories         => $self->directories,
        );
    } else {
        $app->log->warn(sprintf("'%s' does not implement a 'add_localizers' method",ref($loc)))
    }
    
    $self->_data_localize($loc);
}

sub ACCEPT_CONTEXT {
    my ( $self, $c ) = @_;
    
    # set locale and inheritance
    $self->_data_localize->set_languages($c->locale,$c->i18n_config->{_inherits});
    
    return $self->_data_localize;
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;