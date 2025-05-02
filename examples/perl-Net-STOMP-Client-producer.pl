#!/usr/bin/perl
use strict;
use warnings;
use Tie::IxHash qw{};
use Net::STOMP::Client::Wrapper 0.03; #send method
use JSON::XS qw{encode_json};

my $wrapper     = Net::STOMP::Client::Wrapper->new(queue_name=>'example-perl');
my $stomp       = $wrapper->stomp_connect;

foreach my $id (1 .. 1000) {
  my $result    = $wrapper->management_api_get_queue;
  my $content   = $result->content;
  my $consumers = $content->{'consumers'} || 0; #undef if new queue
  my $messages  = $content->{'messages'}  || 0;
  printf "Consumers: %s, Messages: %s\n", $consumers, $messages;

  my $time      = time;
  tie my %payload, 'Tie::IxHash', id=>$id, time=>$time, source=>'perl';
  my $string    = encode_json(\%payload);
  printf "Destination: %s, ID: %s, Time: %s, String: %s\n", $wrapper->destination, $id, $time, $string;
  $wrapper->send(body => $string);
  sleep 3;
}

$wrapper->stomp_disconnect;
