package VD;

use warnings;
use strict;

our $VERSION = '0.01';


sub new {
	  my($class)=shift;
	  my($self) = { DIRECTORY => "/media/RAID/Video/"};
	  bless $self,$class;
	  return $self;
}


sub set {
	my($self) = shift;
	my($dir) = shift;
	$self->{DIRECTORY} = $dir;
}


sub get {
	my($self) = shift;
	return $self->{DIRECTORY};
}

1; # End of Mvid::VD
