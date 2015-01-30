#!/usr/bin/perl
use REST::Client;
use MIME::Base64;
use File::Slurp;
 
# Update for your environment here. Use double quotes around each defined value.
$usr = {REPLACE WITH YOUR VRO USERNAME}
$pwd = {REPLACE WITH YOUR VRO PASSWORD}
$wfid = {REPLACE WITH YOUR VRO WORKFLOW ID}
$jsonFile = {REPLACE WITH PATH TO JSON BODY FILE}
$vroServer = {REPLACE WITH VRO URL:PORT}
 
###### Make no changes below this line ##########
# Original Article: http://bit.ly/perlvco
# Disable server verification (for older LWP implementations)
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;
 
# Setup the connection:
my $client = REST::Client->new();
# Disable server verification (for newer LWP implementations)
$client->getUseragent()->ssl_opts( SSL_verify_mode => SSL_VERIFY_NONE );
 
$client->setHost("https://$vroServer/vco/api");
$client->addHeader("Authorization", "Basic ".encode_base64( $usr .':'. $pwd ));
$client->addHeader("Content-Type","application/json");
$client->addHeader("Accept","application/json");
 
# Perform an HTTP POST on the URI:
$client->POST( "/workflows/$wfid/executions", $jsonFile);
die $client->responseContent() if( $client->responseCode() >= 300 );
print "Response Code: " . $client->responseCode() . "\n";
my @headers = $client->responseHeaders();
foreach (0..$#headers){
    print $headers[$_] . ": " . $client->responseHeader($headers[$_]) . "\n";
}
