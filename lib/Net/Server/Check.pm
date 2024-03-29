#!/usr/bin/perl

package Net::Server::Check; # Объявляем свой пакет

use feature(say);
use strict; 
use warnings;
#use DDP;

use base qw(Net::Server::PreFork); # Наследуем
use IO::Socket::PortState qw(check_ports);

my $debug = 0;
my $timeout = 5;
my $default_ports = "25 110 80 443 3306 5666";

sub process_request {	# Собственно, здесь и выполняется вся работа с запросом
    my $self = shift;   # Получаем ссылку на себя.
    my $client_ip = $self->{server}{peeraddr};
    say "You IP : $client_ip";

#    p $client_ip;
    my $usage = "Enter command: 
		    port - Checks one or few specified port. Use space separator.
		    scan - Checks default ports: 25,110,80,443 3306 5666.
		    exit/quit - close connection";

    say $usage;
    print "command: ";
   while (<STDIN>) {    # Net::Server дает нам сокет как STDIN + STDOUT!
	
	#убираем переводы строк
	s/[\r\n]+$//;

	my $command = $_; 

	if ("$command" eq "scan"){
	    say "Scaned"; sleep 1;
	    &scan_check($client_ip,$default_ports);

	}elsif ($command eq "port"){
	    say "Please enter port for check:";

	    my $port = <STDIN>; s/[\r\n]+$//;
	    &single_check($client_ip,$port);

	}elsif (($command eq "exit")or ($command eq "quit")){
	    say "Bye-bye!"; exit;
	}else{
	    # На любую не коорректную ошибку выдаём подсказку.
	    say $usage;
	    print "command: ";
	}
        last if /quit|exit/i;
   }
}

sub single_check {
    my $client_ip = shift; s/[\r\n]+$//;
    my $ports = shift; s/[\r\n]+$//;
    my %port_hash;

    foreach (split(" ",$ports)){
	$port_hash{tcp}{$_} = undef;
    }

    my $final_result = "\n"."Finished:"."\n";
    my $opened_ports = "\n"."Opened ports:"."\n";
    my $closed_ports = "Closed ports:\n";

    foreach my $port (keys %{$port_hash{tcp}}) {

	if ($port =~ m/[a-zA-Z_\!\#\%\$\@]+/){ 
	    $final_result = $final_result . "$port - Skiped - port is not digits\n"; 
	    next;
	}

	if (($port > 65535) or ($port < 0)){ 
	    $final_result = $final_result . "$port - Skiped - port is on not in port range: 0-65535!\n"; 
	    next;
	}
	
        my $check = check_ports($client_ip,$timeout,\%port_hash);
	my $result = $check->{tcp}{$port}{open} ? 'yes' : 'no';

    	if ($result eq "yes" ){		
	    $opened_ports = $opened_ports . "$port - Port opened\n";
	}else {
	    $closed_ports = $closed_ports . "$port - Port Closed/Filtered \n";
	}
    }

    $final_result = $final_result . $opened_ports . "\n" . $closed_ports;
    say $final_result;
    print "command: ";
    return;
}


sub scan_check {
    my $client_ip = shift; s/[\r\n]+$//;
    my $ports = shift; s/[\r\n]+$//;
    my %port_hash;

    foreach (split(" ",$ports)){
	$port_hash{tcp}{$_} = undef;
    }

#    p %port_hash;
#    p @port;

    my $final_result = "\n"."Finished:"."\n";
    my $opened_ports = "\n"."Opened ports:"."\n";
    my $closed_ports = "Closed ports: \n";

    foreach my $port (keys %{$port_hash{tcp}}) {

        my $check = check_ports($client_ip,$timeout,\%port_hash);
	my $result = $check->{tcp}{$port}{open} ? 'yes' : 'no';

    	if ($result eq "yes" ){		
	    $opened_ports = $opened_ports . "$port - Port opened\n";
	}else {
	    $closed_ports = $closed_ports . "$port - Port Closed/Filtered \n";
	}
    }
	$final_result = $final_result . $opened_ports . "\n" . $closed_ports;
	say $final_result;
        print "command: ";
	return;
}

1; 