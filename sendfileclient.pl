#!/usr/bin/perl
#sendfileclient.pl

use IO::Socket::INET;

$bandwidth = 1024*5; #5 kb/s

&sendFile( $ARGV[0]||'minus.jpg', $ARGV[1]||'127.0.0.1', $ARGV[2]||'5000' );


exit;

sub sendFile {
	my ($file, $host, $port) = @_;
	#my $file = 'Lighthouse.jpg';
	
	if (! -s $file) { die "Error: ", $!;}
	my $file_size = -s $file;
	
	my ($file_name) = ( $file =~ /([^\\\/]+)[\\\/]*$/gs );
	
	# flush after every write
	$| = 1;
	while(1) {
		my $socket = new IO::Socket::INET (
			PeerAddr => $host,
			PeerPort => $port,
			Proto => 'tcp'
		) or print "Could not connect to server... awaiting reply...\n" and next;
		
		#if (! $socket) { die "Error, cant connect: ", $!;}
		#print 'TCP Connection Success, now writing file to server...', "\n";
		
		print "\nSending ", $file_name, "\n", $file_size, "bytes." ;
		print $socket "$file_name#:#" ; # send the file name.
		print $socket "$file_size\_" ; # send the size of the file to server.
		
		open (FILE, $file);
		binmode(FILE);
		my $buffer;
		
		while (sysread(FILE, $buffer, $bandwidth)) {
			print $socket $buffer;
			print ".";
			sleep(1);
		}
		
		print "\nDone\n";
	}
}
close (FILE);
close ($socket);