package WWW::AdServer::Database::YAML;
use Moo::Role;

use YAML ();
use Data::Dumper qw(Dumper);
use List::MoreUtils qw(none);

has data => (
    is  => 'rw',
    isa => sub { die "$_[0] is not a refernce to a hash" unless ref $_[0] eq 'HASH' },
);

sub load {
    my ($self, $path) = @_;
    $self->data( YAML::LoadFile($path) );
    return;
}

sub count_ads {
    my ($self) = @_;
    return scalar @{ $self->data->{ads} };
}

sub get_ads {
	my ($self, %args) = @_;
	my @ads;
	for my $ad (@{ $self->data->{ads} }) {
		#warn Dumper $ad;
		if ($args{country}) {
			next if $ad->{countries} and none {$args{country} eq $_} @{ $ad->{countries} };
		}
		if (defined $args{limit}) {
			last if $args{limit} <= 0;
			$args{limit}--;
		}
		push @ads, $ad;
	}

	return \@ads;
}


1;
