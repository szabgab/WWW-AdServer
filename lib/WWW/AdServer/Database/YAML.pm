package WWW::AdServer::Database::YAML;
use Moo::Role;
use 5.010;

use YAML ();
use Data::Dumper    qw(Dumper);
use List::Util      qw(shuffle sum);
use List::MoreUtils qw(none);
use Time::Local     qw(timegm);

has data => (
    is  => 'rw',
    isa => sub { die "$_[0] is not a refernce to a hash" unless ref $_[0] eq 'HASH' },
);
has weights => (
	is => 'rw',
	default => sub { [] },
);

sub load {
    my ($self, $path) = @_;
    my $data =  YAML::LoadFile($path);

	# TODO some tool to return the entries where the dead-line passed
	my @valid_ads;
	my $now = time;
	my @weights;
	foreach my $ad (@{ $data->{ads} }) {
        if ($ad->{end_date}) {
            my ($year, $month, $day) = split /-/, $ad->{end_date};
            eval {
                $ad->{end_date} = timegm(59, 59, 23, $day, $month-1, $year-1900);
            };
            if ($@) {
                #print STDERR "$ad->{text}\n";
                #print STDERR "$ad->{end_date}\n";
                #print STDERR "$@\n";
                $ad->{end_date} = 0;
            }
			next if $ad->{end_date} < $now;
		}
		if ($ad->{weight}) {
			push @weights, (scalar @valid_ads) x $ad->{weight};
		}
		push @valid_ads, $ad;
	}
	$data->{ads} = \@valid_ads;
    $self->data( $data );
	$self->weights( \@weights );

    return;
}

sub count_ads {
    my ($self) = @_;
    return scalar @{ $self->data->{ads} };
}

sub get_random_ad {
	my ($self, %args) = @_;
	my @all_ads = @{ $self->data->{ads} };
	#my $weight = sum map { $_->{weight} } @all_ads;
	#return $weight;
	my $weights = $self->weights;
	return $weights->[ int rand scalar @$weights ];
}

sub get_ads {
	my ($self, %args) = @_;

	my @ads;
	my @all_ads = @{ $self->data->{ads} };
	if ($args{shuffle}) {
		@all_ads = shuffle @all_ads;
	}
	for my $ad (@all_ads) {
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
