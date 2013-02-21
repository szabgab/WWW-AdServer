use strict;
use warnings;

use Test::More;

plan tests => 1;

use WWW::AdServer;

my $ads = WWW::AdServer->new;
isa_ok($ads, 'WWW::AdServer');


