#!perl -T

use Test::More tests => 9;

use_ok( 'CatalystX::I18N' );
use_ok( 'CatalystX::I18N::L10N' );
use_ok( 'CatalystX::I18N::Role::Base' );
use_ok( 'CatalystX::I18N::Role::Request' );
use_ok( 'CatalystX::I18N::Role::Response' );
use_ok( 'CatalystX::I18N::Role::Maketext' );
use_ok( 'CatalystX::I18N::Controller::GetLocale' );
use_ok( 'CatalystX::I18N::TypeConstraints' );
use_ok( 'CatalystX::I18N::Model::L10N' );

