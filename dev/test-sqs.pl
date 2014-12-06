#!/usr/bin/perl
use Digest::MD5 qw(md5_hex);
use Amazon::SQS::Simple;
use Data::Dumper;

my $access_key = 'AKIAIJAXBQ3MH55DX4YA';
my $secret_key = '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';

# Create an SQS object
my $q = new Amazon::SQS::Simple($access_key, $secret_key)->GetQueue('https://sqs.us-east-1.amazonaws.com/084723321999/iCAD_Dispatcher-PittsburghPA') or die("Can't start SQS: $@ $!\n");

# Create a new queue
#my $q = $sqs->GetQueue('https://sqs.us-east-1.amazonaws.com/084723321999/iCAD_Dispatcher-PittsburghPA');

# Send a message
my $msg = 'Hello World!';

print "Sending message => [$msg]\n";
my $rc = $q->SendMessage($msg);

print "Sent Message ID: [" . $rc->MessageId . "]\n";

my $localmd5 = md5_hex($msg);
print "Local MD5: [$localmd5] Remote MD5: [" . $rc->MD5OfMessageBody() . "]\n";

print "\n\n";

print "Starting SQS Loop\n";
my $count = 0;
while ( 1 )
{
    print "Polling loop [" . $count++ ."]\n";

    if ( my $msg = $q->ReceiveMessage ) 
    {
       print "Fetching Message From Queue... ($$)\n";

        if ( ! ( fork ) )
        {
            print "Message ID: " . $msg->MessageId() . " ($$)\n";
            print "Message Body: " . $msg->MessageBody() . " \n";
            print "Message Handle: " .  $msg->ReceiptHandle() . " \n";
            print "Deleting message ... ";
            if ( $q->DeleteMessage( $msg->ReceiptHandle() ) )
            {
                print "Done\n";
                exit;
            }
            print "Error deleting $@ $!\n";
            exit;
        }
    }
}
print "Finished Polling\n";

exit;
print "Queue message added\n";

# Retrieve a message
my $msg = $q->ReceiveMessage() or die "Can't get message: $@ $!\n";
print Dumper($msg);
#print $msg->MessageBody() # Hello world!

# Delete the message
#$q->DeleteMessage($msg->MessageId());

# Delete the queue
#$q->Delete();
