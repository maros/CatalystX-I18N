package TestApp::View::TT;

use Moose;
extends qw(Catalyst::View::TT);
with qw(CatalystX::I18N::TraitFor::ViewTT);

1;