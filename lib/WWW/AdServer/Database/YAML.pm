use strict;
use warnings;
package WWW::AdServer::Database::YAML;
use Moo;

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


1;
