#!/usr/bin/env perl
use strict;
use warnings;
use SMMID;

SMMID->setup_engine('PSGI');
my $app = sub { SMMID->run(@_) };

