#!perl
use strict;
use warnings;

use Test::Most tests => 13;

use_ok( 'CatalystX::I18N' );
use_ok( 'CatalystX::I18N::L10N' );
use_ok( 'CatalystX::I18N::Role::Base' );
use_ok( 'CatalystX::I18N::Role::DateTime' );
use_ok( 'CatalystX::I18N::Role::GetLocale' );
use_ok( 'CatalystX::I18N::Role::Maketext' );
use_ok( 'CatalystX::I18N::Role::NumberFormat' );
use_ok( 'CatalystX::I18N::Role::All' );
use_ok( 'CatalystX::I18N::TypeConstraints' );
use_ok( 'CatalystX::I18N::Model::L10N' );
use_ok( 'CatalystX::I18N::TraitFor::Response' );
use_ok( 'CatalystX::I18N::TraitFor::Request' );

use_ok( 'Catalyst::Helper::Model::L10N' );
