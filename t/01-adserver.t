use strict;
use warnings;

use Test::More;

plan tests => 2;

use WWW::AdServer;

my $ads = WWW::AdServer->new;
isa_ok($ads, 'WWW::AdServer');

my $db = WWW::AdServer::Database->new;
isa_ok($db, 'WWW::AdServer::Database');

