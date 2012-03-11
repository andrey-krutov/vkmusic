#!/usr/bin/perl -w

use strict;
use warnings;
use Encode qw(encode decode is_utf8);
use LWP 5.64;
use HTTP::Cookies; 
use HTTP::Request::Common;
use URI::Escape;
use JSON;

# my $use_proxy = 'http://zh-kd.com:8080/'; # proxy address here
# Your account email in vk.com
my $login_mail = 'user@host.com';
# Your password on vk.com
my $login_pass = 'password';
# url with music list
my $url_post = 'http://vk.com/audio?id=user_id';
my $encoding = 'cp1251';
$url_post =~ m/id=(.*)/;
my $user_id = $1;

my $useragent = 'Mozilla/5.0 (Windows; U; Windows NT 5.1;) Firefox/2.0.0.0';
my $url_login = 'http://vk.com/login.php';

my $ua = LWP::UserAgent->new(keep_alive => 1, requests_redirectable => [ 'POST', 'GET' ]);
$ua->proxy('http', $use_proxy) if $use_proxy;
$ua->agent($useragent);
$ua->cookie_jar({});

print 'Login... ';
my $response = $ua->post($url_login, 
			 [
			  'email' => $login_mail, 
			  'pass' => $login_pass, 
			 ]);
die 'Login error -- ', $response->status_line
    unless $response->is_success or $response->code == 302;
print "Success.\n";
srand;

print 'Get URL content... ';
$response = $ua->post($url_post,
		[
		 'act' => 'load_audios_silent',
		 'al' =>	'1',
		 'edit' => '0',
		 'gid' => '0',
		 'id' => $user_id
		]);
die 'Get page error -- ', $response->status_line
    unless $response->is_success or $response->code == 302;
print "Success.\n";
my $cont = $response->content;
#	my $url = $url_post;
#	my $res; my $app='';


$cont = decode( $encoding, $cont);
$cont = encode( 'UTF-8', $cont);

my $json = JSON->new->utf8;
$cont =~ m/({.*})/;
$cont = $1;
$cont =~ s/\]\,/\]\,\n/g;
my @res = split /<!>/, $cont;
$cont = $res[0];
$cont =~ s/([^\\])'/$1"/g;
$cont =~ s/([^\\])'/$1"/g;

@res = @{$json->decode($cont)->{all}};
foreach(@res){
  my @song_list = @{$_};
  #  print $song_list[2], "\n";
  system "wget", $song_list[2];
}
#print scalar @res;
print "\n";
