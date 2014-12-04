#!/usr/bin/perl
#sendfileserver.pl

use IO::Socket::INET;
# flush after every write
$| = 1;

my $port = $ARGV[0]||5000;
my $save_dir = './output';

if (! -d $save_dir) {
	mkdir($save_dir, 0755);
	print "Save directory created: ", $save_dir, "\n";
}

my $socket = new IO::Socket::INET (
	#LocalAddr => 'localhost',
	LocalPort => '5000',
	Proto => 'tcp',
	Listen => 5
) or die 'ERROR in Socket Creation : ', $!, "\n";

print "Socket opened: port:", $port, "\n", "Waiting for client...", "\n";

while ( my $client = $socket->accept ) {
	print "\nNew client!", "\n";
	my ( $buffer, %data, $data_content );
	my $buffer_size = 1;
	
	while ( sysread($client, $buffer, $buffer_size) ) {
		if    ($data{filename} !~ /#:#$/) { $data{filename} .= $buffer ;}
		elsif ($data{filesize} !~ /_$/) { $data{filesize} .= $buffer ;}
		elsif ( length($data_content) < $data{filesize}) {
			
			if ($data{filesave} eq '') {
			  $data{filesave} = "$save_dir/$data{filename}" ;
			  $data{filesave} =~ s/#:#$// ;
			  $buffer_size = 1024*10 ;
			  if (-e $data{filesave}) { unlink ($data{filesave}) ;}
			  print "Saving: $data{filesave} ($data{filesize}bytes)\n" ;
			}
			open (FILENEW,">>$data{filesave}") ; binmode(FILENEW) ;
			print FILENEW $buffer ;
			close (FILENEW) ;
			print "." ;
		}
		else {last;}
	}
	print "\nDone\n";
	print "Waiting for new client...\n";
}
close ($socket);
