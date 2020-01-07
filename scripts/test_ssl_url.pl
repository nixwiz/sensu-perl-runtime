use LWP::UserAgent ();

print "Checking HTTPS response with verify disabled\n";

my $ua = LWP::UserAgent->new(timeout => 10);
$ua->env_proxy;
$ua->ssl_opts( verify_hostnames => 0 );

my $response = $ua->get("http://www.sensu.io/");

if ($response->is_success) {
    print "Success!\n";
}
else {
    die $response->status_line;
}

