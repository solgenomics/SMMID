#!/bin/bash
cpanm -L /home/production/local-lib Config::General
cpanm -L /home/production/local-lib Config::Std
cpanm -L /home/production/local-lib Catalyst
cpanm -L /home/production/local-lib Catalyst::Plugin::Static::Simple
cpanm -L /home/production/local-lib Catalyst::Plugin::ConfigLoader
cpanm -L /home/production/local-lib Catalyst::Action::RenderView
cpanm -L /home/production/local-lib Catalyst::Restarter
cpanm -L /home/production/local-lib Catalyst::Plugin::Authorization::Roles
cpanm -L /home/production/local-lib Catalyst::View::TT
cpanm -L /home/production/local-lib String::Random
cpanm -L /home/production/local-lib Plack::Handler::Starman
cpanm -L /home/production/local-lib DateTime
cpanm -L /home/production/local-lib DateTime::Format::ISO8601
cpanm -L /home/production/local-lib DateTime::Format::Pg
cpanm -L /home/production/local-lib Catalyst::Plugin::SmartURI
cpanm -L /home/production/local-lib Catalyst::Model::DBIC::Schema
cpanm -L /home/production/local-lib Catalyst::View::HTML::Mason
cpanm -L /home/production/local-lib Tie::UrlEncoder
cpanm -L /home/production/local-lib DBD::Pg
cpanm -L /home/production/local-lib Try::Tiny
cpanm -L /home/production/local-lib JSON::XS
cpanm -L /home/production/local-lib Chemistry::File::SMILES
cpanm -L /home/production/local-lib Image::Size
cpanm -L /home/production/local-lib YAML
cpanm -L /home/production/local-lib Test::Selenium::Remote::Driver
cpanm -L /home/production/local-lib MooseX::Runnable

