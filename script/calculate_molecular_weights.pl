
use strict;

use SMIDDB;

my $schema = SMIDDB->connect('dbi:Pg:dbname=smid_db;host=localhost;user=postgres;password=DebianBox**');

my $compounds = $schema->resultset("SMIDDB::Result::Compound")->search( {} );

while (my $compound = $compounds->next()) {
    my $molecular_weight = molecular_weight($compound->formula());

    $compound->update( { molecular_weight => $molecular_weight });


}



sub molecular_weight {
  #...
  #The default variable will be used as the chemical Formula
  $_ = shift(@_);

  my %elements = ("H" => 1.01, "C" => 12.01, "O" => 16.0, "N" => 14.01, "P" => 30.97, "S" => 32.06);
  my $weight = 0;

  my @pairs = /([CHONPS][0-9]*)/g;
  foreach my $pair (@pairs){
    if (length($pair)==1){
      $weight += $elements{substr($pair, 0, 1)};
    }else{
      $weight += $elements{substr($pair, 0, 1)}*substr($pair, 1);
    }
  }
  return $weight;
}
