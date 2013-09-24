use strict;
use warnings;

use Test::More;

plan tests => 7;

use WWW::AdServer;
use WWW::AdServer::Database;

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
     'end_date' => '1439589599',
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


is_deeply $db->get_ads(country => 'IL', limit => 1),
[
   {
     'text' => 'Need an IDE for Perl? <a href=http://padre.perlide.org/>Download Padre</a>'
   },
], 'get_ads IL 1';

