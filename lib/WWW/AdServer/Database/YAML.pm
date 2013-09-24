package WWW::AdServer::Database::YAML;
use Moo::Role;

use YAML ();

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

	return;
}


1;
