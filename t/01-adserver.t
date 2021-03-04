use strict;
use warnings;

use Test::More;
use Test::Deep qw(cmp_details);

plan tests => 10;

use WWW::AdServer;
use WWW::AdServer::Database;
use Geo::IP;

my $ads = WWW::AdServer->new;
isa_ok($ads, 'WWW::AdServer');

my $db = WWW::AdServer::Database->new(dsn => 't/files/ads.yml');
isa_ok($db, 'WWW::AdServer::Database');
is $db->dsn, 't/files/ads.yml', 'dsn ok';
is $db->type, 'YAML', 'type ok';

is $db->count_ads, 10, 'count_ads';

subtest 'FR' => sub {
	my $ads = $db->get_ads(country => 'FR');
	is_deeply $ads,
[
   {
     'text' => 'Need an IDE for Perl? <a href=http://padre.perlide.org/>Download Padre</a>'
   },
   {
     'text' => '<a href=http://www.perlmonks.org/>Get help from the PerlMonks</a>'
   },
   {
     'text' => '<a href=http://www.perlbuzz.com/>All the Buzz Perl can get</a>'
   },
   {
     'text' => 'Don\'t miss the <a href=http://perlweekly.com/>Perl Weekly</a> newsletter',
     'end_date' => '1439596799',
   },
   {
     'countries' => [
       'FR',
       'CH'
     ],
     'text' => "<a href=http://www.perlfoundation.org/perl5/index.cgi?french>Ressources Perl en fran\x{e7}ais</a>"
   }
], 'get_ads FR';
	#diag explain $ads;
};


subtest 'IL' => sub {
	my $il_ads = $db->get_ads(country => 'IL');
	#diag explain $il_ads;
	my $ads = $db->get_ads(country => 'IL', limit => 1);
	is_deeply $ads,
	[
	   {
	     'text' => 'Need an IDE for Perl? <a href=http://padre.perlide.org/>Download Padre</a>'
	   },
	], 'get_ads IL 1';

	$ads = $db->get_ads(country => 'IL', limit => 1, shuffle => 1);
	#diag explain $ads;
	one_deeply_ok($ads->[0], $il_ads, 'one IL shuffle');
};

subtest 'geoip' => sub {
	my $gi;
	eval {
		$gi = Geo::IP->new(GEOIP_MEMORY_CACHE);
	};
	plan skip_all => 'Geo::IP is not working' if $@ or not defined $gi;

	my %data = (
		'24.24.24.24'  => 'US',
		'86.59.162.2'  => 'HU',
	);
	foreach my $ip (sort keys %data) {
		my $country = $gi->country_code_by_addr($ip);
		#diag $country;
		is($country, $data{$ip}, $ip);
	}
};

subtest 'more' => sub {
	plan tests => 5;

	my $adsense = WWW::AdServer->new;
	isa_ok($adsense, 'WWW::AdServer');

	my $db = WWW::AdServer::Database->new(dsn => 't/files/adsense.yml');
	isa_ok($db, 'WWW::AdServer::Database');
	is $db->dsn, 't/files/adsense.yml', 'dsn ok';
	is $db->type, 'YAML', 'type ok';

	is $db->count_ads, 3, 'count_ads';
};

subtest 'weight' => sub {
	plan tests => 8;

	my $adsense = WWW::AdServer->new;
	isa_ok($adsense, 'WWW::AdServer');

	my $db = WWW::AdServer::Database->new(dsn => 't/files/ads_weight.yml');
	isa_ok($db, 'WWW::AdServer::Database');
	is $db->dsn, 't/files/ads_weight.yml', 'dsn ok';
	is $db->type, 'YAML', 'type ok';

	is $db->count_ads, 3, 'count_ads';

	my %count;
	my $N = 10000;
	for (1..$N) {
		my $ad = $db->get_random_ad;
		$count{$ad}++;
	}

	# random numbers can't be exact but should not differ a lot from the expected
	cmp_ok $count{0}, '<', $N*2/100, 'should be around 1%';
	cmp_ok $count{1}, '<', $N*4/100, 'should be around 2%';
	cmp_ok $count{2}, '>', $N*94/100, 'should be around 97%';
	#:diag explain \%count;
};

sub one_deeply_ok {
    my ($real, $possibilities, $name) = @_;
	$name ||= '';

	my $oks = 0;
	foreach my $exp (@$possibilities) {
		my ($ok, $stack) = cmp_details($real, $exp);
		$oks = $ok ? $ok : $oks;
		last if $oks;
	}
	ok($oks, $name);
}



