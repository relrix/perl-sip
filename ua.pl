#!/usr/bin/perl -w

use Net::SIP ':all';

my $loop = Dispatcher_Eventloop->new;
my $leg = Leg->new( addr => '172.18.6.130:5063' );
my $disp = Dispatcher->new(
    [ $leg ],
    $loop,
    do_retransmits => 1
) || die;
$disp->set_receiver( \&receive );


  # create new agent
  my $ua = Net::SIP::Simple->new(
        registrar => '172.18.6.130',
        domain => '172.18.6.30',
        from => '2000',
        auth => [ '2000','on24' ],
  );

  # Register agent
  $ua->register;


# create INVITE request
  my $sdp;
  my $invite = Net::SIP::Request->new(
        'INVITE', 'sip:8888@172.18.6.130',
        { from => '2000@172.18.6.130', 
		to => '8888@172.18.6.130',
		contact => '2000@172.18.6.130',
		'call-id' => 'sdfsdfwe434ter345343efds@172.18.6.130',
		cseq      => '1 INVITE',
	}, 
	
        $sdp = Net::SIP::SDP->new(
		{ addr => '172.18.6.130'} ,
        	{ port => 2012, proto => 'RTP/AVP', media => 'audio', fmt => 0 } ,
	      	{ port => 2014, proto => 'RTP/AVP', media => 'video', fmt => 0 } ,
		),
 );


#$disp->deliver( $invite, do_retransmits => 0 );

my $call = $ua->invite( '8888',
        init_media => $ua->rtp( 'send_recv', 'announcement.pcmu-8000' ),
        asymetric_rtp => 1,
  );



sub receive {
	print "Test\n";
}
