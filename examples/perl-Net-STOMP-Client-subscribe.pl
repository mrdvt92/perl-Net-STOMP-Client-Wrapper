#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes qw{sleep time};
use Net::STOMP::Client::Wrapper 0.03; #stomp_disconnect_subscribe
use JSON::XS qw{decode_json};

my $queue_name    = 'example-perl';
my $continue      = 1;
my $wrapper       = Net::STOMP::Client::Wrapper->new(queue_name=>$queue_name);
my $stomp         = $wrapper->stomp_connect_subscribe; #connect and subscribe
local $SIG{'INT'} = \&_signal;

# wait for a specified message frame

sub queue_callback {
  my $stomp = shift; #isa Net::STOMP::Client
  my $frame = shift; #ias Net::STOMP::Client::Frame
  #print Dumper($frame);
  my $data  = decode_json($frame->body);
  $stomp->ack(frame => $frame);
  printf "ID: %s, Time: %s, Source %s\n", $data->{'id'}, $data->{'time'}, $data->{'source'};
  sleep 1;
  return $continue ? 0 : 1;
}

$stomp->wait_for_frames(callback => \&queue_callback);
$wrapper->stomp_disconnect; #disconnect and unsubscribe

sub _signal {
  print "INT\n";
  $continue   = 0;
  print "Continue: $continue\n";
  $SIG{'INT'} = 'DEFAULT';
}
