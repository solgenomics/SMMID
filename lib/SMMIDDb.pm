use strict;

package SMMIDDb;

use Tie::UrlEncoder;

our %urlencode;
our $PARSED;
our %SMMID;

sub new { 
    my $class = shift;
    my $file = shift;
    my $smmid = shift;
    my $self = bless {}, $class;

    $self->set_smmid($smmid);

    print STDERR "SMMID FILE = $file\n";
    $self->{smmid_file} = $file;

    $self->fetch();

    return $self;
}

=head2 accessors get_smmid, set_smmid

 Usage:
 Desc:
 Property
 Side Effects:
 Example:

=cut

sub get_smmid {
  my $self = shift;
  return $self->{smmid}; 
}

sub set_smmid {
  my $self = shift;
  $self->{smmid} = shift;
}

sub fetch { 
    my $self = shift;    

    if (!$PARSED) { 
	open (my $F, "<".$self->{smmid_file}) || die "Can't open the SMMID definition file $self->{smmid_file}.";
	my $current = "";	
	while (<$F>) { 
	    chomp;
	    
	    if (/^SMMID\:\s*(.*)/) { 
		$current = $1;
		$SMMID{$current}->{SMMID}=$current;
	    }
	    else { 
		my ($key, $value) = split /\s*\:\s*/;
		if ($key=~/^http/) { 
		    print STDERR "Adding URL $value\n";
		    push @{$SMMID{$current}->{link_url}}, $value;
		}
		elsif ($key=~/^\(/) { 
		    print STDERR "Adding link text $key\n";
		    push @{$SMMID{$current}->{link_text}}, $key;
		}
		else { 
		    $SMMID{$current}->{$key}=$value;
		}
	    
	    }
	    $PARSED = "TRUE!";
	}
    }
    
}
	    
=head2 accessors get_name, set_name

 Usage:
 Desc:
 Property
 Side Effects:
 Example:

=cut

sub get_name {
  my $self = shift;
  if (!exists $SMMID{$self->get_smmid()}) { 
      die "Need to set smmid first with set_smmid()";
  }
  return $SMMID{$self->get_smmid()}->{NAME}; 
}

sub set_name {
  my $self = shift;
  $SMMID{$self->get_smmid()}->{NAME}=shift;
}

=head2 accessors get_synonyms, set_synonyms

 Usage:
 Desc:
 Property
 Side Effects:
 Example:

=cut

sub get_synonyms {
  my $self = shift;
  return $SMMID{$self->get_smmid()}->{SYNONYMS}; 
}

sub set_synonyms {
  my $self = shift;
  $SMMID{$self->get_smmid()}->{SYNONYMS}=shift;
}

=head2 accessors get_molecular_formula, set_molecular_formula

 Usage:
 Desc:
 Property
 Side Effects:
 Example:

=cut

sub get_molecular_formula {
  my $self = shift;
  return $SMMID{$self->get_smmid()}->{"MOLECULAR FORMULA"};
}

sub set_molecular_formula {
  my $self = shift;
  $SMMID{$self->get_smmid()}->{"MOLCULAR FORMULA"}=shift;
}


=head2 accessors get_molecular_weight, set_molecular_weight

 Usage:
 Desc:
 Property
 Side Effects:
 Example:

=cut

sub get_molecular_weight {
  my $self = shift;
  return $SMMID{$self->get_smmid()}->{"MOLECULAR WEIGHT"};
}

sub set_molecular_weight {
  my $self = shift;
  $SMMID{$self->get_smmid()}->{"MOLECULAR WEIGHT"}=shift;
}

=head2 get_structure_file

 Usage:
 Desc:
 Ret:
 Args:
 Side Effects:
 Example:

=cut

sub get_structure_file {
    my $self = shift;
    my $file = $self->get_smmid();
    $file=~s/\#//g;
    $file=~s/\./\-/g;
    return $file;

}

=head2 get_smmid_for_link

 Usage: 
 Desc:
 Ret:
 Args:
 Side Effects:
 Example:

=cut

sub get_smmid_for_link {
    my $self = shift;
    return $urlencode{$self->get_smmid()};

}

=head2 get_links

 Usage:
 Desc:
 Ret:
 Args:
 Side Effects:
 Example:

=cut

sub get_links {
    my $self =shift;
    
    my @links = ();
    for (my $i=0; $i<@{$SMMID{$self->get_smmid()}->{link_text}}; $i++) { 
	push @links, [ ${$SMMID{$self->get_smmid()}->{link_text}}[$i], ${$SMMID{$self->get_smmid()}->{link_url}}[$i] ];
    }
    return @links;
    
}



=head2 all_smmids

 Usage:
 Desc:
 Ret:
 Args:
 Side Effects:
 Example:

=cut

sub all_smmids {
    my $class = shift;
    my $path = shift;

    my $self = $class->new($path);

    $self->fetch();

    my @all_smmids = ();
    
    foreach my $s (sort keys(%SMMID)) {
	my $smmid = SMMIDDb->new($path, $s);
	
	push @all_smmids, $smmid;
    }
    return @all_smmids;
    
}




    
return 1;
