#!perl
use strict;
use warnings;

use Test::More tests => 11;

use_ok( 'CatalystX::I18N' );
use_ok( 'CatalystX::I18N::L10N' );
use_ok( 'CatalystX::I18N::Role::Base' );
use_ok( 'CatalystX::I18N::Role::Request' );
use_ok( 'CatalystX::I18N::Role::DateTime' );
use_ok( 'CatalystX::I18N::Role::NumberFormat' );
use_ok( 'CatalystX::I18N::TraitFor::Response' );
use_ok( 'CatalystX::I18N::TraitFor::Request' );
use_ok( 'CatalystX::I18N::Role::GetLocale' );
use_ok( 'CatalystX::I18N::TypeConstraints' );
use_ok( 'CatalystX::I18N::Model::L10N' );

