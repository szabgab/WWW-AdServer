use strict;
use warnings;

use Test::More;

plan tests => 5;

use WWW::AdServer;

my $ads = WWW::AdServer->new;
isa_ok($ads, 'WWW::AdServer');

my $db = WWW::AdServer::Database->new(dsn => 't/files/ads.yml');
isa_ok($db, 'WWW::AdServer::Database');
is $db->dsn, 't/files/ads.yml', 'dsn ok';
is $db->type, 'YAML', 'type ok';

is $db->count_ads, 12, 'count_ads';

