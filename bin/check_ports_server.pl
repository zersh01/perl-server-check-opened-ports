#!/usr/bin/perl
# Вс ноя  3 13:27:42 MSK 2019
#parhomenko

use feature(say);
use strict;
use warnings;
use FindBin;

# где ищем библиотеки
use lib "$FindBin::Bin/../lib"; 

use Net::Server::Check;

our $server = Net::Server::Check->new(conf_file => "$FindBin::Bin/../etc/checkserver.cfg");

$server->run();