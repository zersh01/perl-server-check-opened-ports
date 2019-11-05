#!/usr/bin/perl

package Net::Server::Check; # Объявляем свой пакет

use feature(say);
use strict; 
use warnings;
use DDP;

use base qw(Net::Server::PreFork); # Наследуем
use IO::Socket::PortState qw(check_ports);

my $debug = 1;
my $timeout = 5;
my $default_ports = "25 110 80 443 3306 5666";

sub process_request {	# Собственно, здесь и выполняется вся работа с запросом
    my $self = shift;   # Получаем ссылку на себя.
    my $client_ip = $self->{server}{peeraddr};
    say "You IP : $client_ip";

#    p $client_ip;
    my $usage = "Enter command: 
		    port - Checks one or few specified port. Use space separator.
		    scan - Checks default ports: 25,110,80,443 3306 5666.";

    say $usage;
    print "command: ";
   while (<STDIN>) {    # Net::Server дает нам сокет как STDIN + STDOUT!
	
	#убираем переводы строк
	s/[\r\n]+$//;

	my $command = $_; 

	if ("$command" eq "scan"){
	    say "Scaned";
	    &scan_check($client_ip,$default_ports);

	}elsif ($command eq "port"){
	    say "Please enter port for check:";

	    my $port = <STDIN>; s/[\r\n]+$//;
	    &single_check($client_ip,$port);

	}else{
	    # На любую не коорректную ошибку выдаём подсказку.
	    say $usage;
	    print "command: ";
	}
        last if /quit/i;
   }
}

sub single_check {
    my $client_ip = shift; s/[\r\n]+$//;
    my $ports = shift; s/[\r\n]+$//;
    my @port = split(" ",$ports); p @port;

    my $final_result = "Finished: \n";

    foreach my $port (@port) {
	if ($port =~ m/[a-zA-Z]+/){ 
	    $final_result = $final_result . "$port - Skiped - port is not digits\n"; 
	    next;
	}

	if (($port > 65535) or ($port < 0)){ 
	    $final_result = $final_result . "$port - Skiped - port is on not in port range: 0-65535!\n"; 
	    next;
	}
	
        my $result = system ("nc -z -w 5 -v $client_ip $port");

    	if ($result eq "0" ){		
	    $final_result = $final_result . "$port - Port opened\n";
	}else {
	    $final_result = $final_result . "$port - Port Closed/Filtered \n";
	}
    }
	say $final_result;
        print "command: ";
	return;
}


sub scan_check {
    my $client_ip = shift; s/[\r\n]+$//;
    my $ports = shift; s/[\r\n]+$//;
    my @port = split(" ",$ports); p @port;

#    p @port;
    my $final_result = "Finished: \n";

    foreach my $port (@port) {

        my $result = system ("nc -z -w 5 -v $client_ip $port");

    	if ($result eq "0" ){		
	    $final_result = $final_result . "$port - Port opened\n";
	}else {
	    $final_result = $final_result . "$port - Port Closed/Filtered \n";
	}
    }
	say $final_result;
        print "command: ";
	return;
}


1; # Perl-магия: пакет должен иметь return