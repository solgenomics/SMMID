
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

  my %elements = (
  "H" => 1.00794,
  "D" => 2.014101,
  "T" => 3.016049,
  "He" => 4.002602,
  "Li" => 6.941,
  "Be" => 9.012182,
  "B" => 10.811,
  "C" => 12.0107,
  "N" => 14.00674,
  "O" => 15.9994,
  "F" => 18.9984032,
  "Ne" => 20.1797,
  "Na" => 22.989770,
  "Mg" => 24.3050,
  "Al" => 26.981538,
  "Si" => 28.0855,
  "P" => 30.973761,
  "S" => 32.066,
  "Cl" => 35.4527,
  "Ar" => 39.948,
  "K" => 39.0983,
  "Ca" => 40.078,
  "Sc" => 44.955910,
  "Ti" => 47.867,
  "V" => 50.9415,
  "Cr" => 51.9961,
  "Mn" => 54.938049,
  "Fe" => 55.845,
  "Co" => 58.933200,
  "Ni" => 58.6934,
  "Cu" => 63.546,
  "Zn" => 65.39,
  "Ga" => 69.723,
  "Ge" => 72.61,
  "As" => 74.92160,
  "Se" => 78.96,
  "Br" => 79.904,
  "Kr" => 83.80,
  "Rb" => 85.4678,
  "Sr" => 87.62,
  "Y" => 88.90585,
  "Zr" => 91.224,
  "Nb" => 92.90638,
  "Mo" => 95.94,
  "Tc" => 98,
  "Ru" => 101.07,
  "Rh" => 102.90550,
  "Pd" => 106.42,
  "Ag" => 107.8682,
  "Cd" => 112.411,
  "In" => 114.818,
  "Sn" => 118.710,
  "Sb" => 121.760,
  "Te" => 127.60,
  "I" => 126.90447,
  "Xe" => 131.29,
  "Cs" => 132.90545,
  "Ba" => 137.327,
  "La" => 138.9055,
  "Ce" => 140.116,
  "Pr" => 140.90765,
  "Nd" => 144.24,
  "Pm" => 145,
  "Sm" => 150.36,
  "Eu" => 151.964,
  "Gd" => 157.25,
  "Tb" => 158.92534,
  "Dy" => 162.50,
  "Ho" => 164.93032,
  "Er" => 167.26,
  "Tm" => 168.93421,
  "Yb" => 173.04,
  "Lu" => 174.967,
  "Hf" => 178.49,
  "Ta" => 180.9479,
  "W" => 183.84,
  "Re" => 186.207,
  "Os" => 190.23,
  "Ir" => 192.217,
  "Pt" => 195.078,
  "Au" => 196.96655,
  "Hg" => 200.59,
  "Tl" => 204.3833,
  "Pb" => 207.2,
  "Bi" => 208.98038,
  "Po" => 209,
  "At" => 210,
  "Rn" => 222,
  "Fr" => 223,
  "Ra" => 226,
  "Ac" => 227,
  "Th" => 232.038,
  "Pa" => 231.03588,
  "U" => 238.0289,
  "Np" => 237,
  "Pu" => 244,
  "Am" => 243,
  "Cm" => 247,
  "Bk" => 247,
  "Cf" => 251,
  "Es" => 252,
  "Fm" => 257,
  "Md" => 258,
  "No" => 259,
  "Lr" => 262,
  "Rf" => 261,
  "Db" => 262,
  "Sg" => 266,
  "Bh" => 264,
  "Hs" => 269,
  "Mt" => 268,
  "Uun" => 271,
  "Uuu" => 272
  );
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
