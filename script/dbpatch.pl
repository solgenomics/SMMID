#!/usr/bin/perl

use strict;

package dbpatch;

use Moose;

extends 'Dbpatch::RunPatches';

my $dbpatch = dbpatch->new_with_options();

$dbpatch->run();




