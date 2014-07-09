#!/usr/bin/perl
#use strict;
use warnings;

use Net::SIP;
use Net::SIP::Debug;
use Getopt::Long qw(:config posix_default bundling);
use threads;
use threads::shared;
use Data::Dumper;
$Data::Dumper::Indent = 1;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Useqq = 1;


#&write_sdp_file("1111","2222");
#exit;

my @threads;

my $debug = 100;
my $from  = 'sip:100@172.18.6.130';
my $to    = 'sip:3116@172.18.6.130';
my $user  = '100';

Net::SIP::Debug->level($debug);

my $peer_preliminary;
my $peer_established;

my $leg = Net::SIP::Leg->new( addr => '172.18.6.130:5068' );
my $ua = Net::SIP::Simple->new(
    from => $from,
    leg  => $leg,
);

my $call = $ua->invite( $to,cb_preliminary => \$peer_preliminary, cb_established => \$peer_established,) || die "invite failed: ".$ua->error;


my $peers =  $peer_preliminary->{param}->{sdp};

my $medias =  $peers->get_media();


#print Dumper $medias;

my $address;
my $audioPort;
my $videoPort;
my $filename = 'stream.sdp';

for my $elem ( @$medias ) {

    $address = $elem->{addr};

    if($elem->{media} eq "audio"){

	$audioPort = $elem->{port};

	}
	
    elsif($elem->{media} eq "video"){

    $videoPort= $elem->{port};	
	}
}

#print "$address:$audioPort:$videoPort"; 

#`./runsh.sh $port`;

&write_sdp_file($audioPort,$videoPort);

&start_stream();


sub write_sdp_file {

	my ($audioPort,$videoPort) = @_;
	
	open ( my $fileHandler, '>' , $filename ) or die "Couldnot open file $filename";

	print $fileHandler "v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\ns=On24stream\r\nc=IN IP4 127.0.0.1\r\nt=0 0\r\na=tool:libavformat 55.2.100\r\nm=audio $audioPort RTP/AVP\r\nm=video $videoPort  RTP/AVP 115\r\na=rtpmap:115 H263-1998/90000\r\na=fmtp:115 QCIF=2;CIF=2;VGA=2;CIF4=2;I=1;J=1;T=1\r\nb=AS:4096\r\n";

	close $fileHandler;

}

sub start_stream {

my $stream_cmd = "avconv -i $filename -ar 22050 -f flv rtmp://172.18.6.144/live/asterisk_video > /tmp/shishir.log";

my $Thread =  threads->new(exec ($stream_cmd));

push (@threads,$Thread);


}
