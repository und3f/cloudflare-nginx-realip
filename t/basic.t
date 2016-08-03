#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use File::Temp;

my $tmp = File::Temp->new;

use_ok 'CloudFlare::Nginx::RealIP';
my $cf = new_ok 'CloudFlare::Nginx::RealIP', [output_file => $tmp->filename];

my @ips;
subtest 'get ip list' => sub {
    @ips = $cf->get_ip_list();
    ok scalar @ips > 2, "got some ips";
};

subtest 'do()' => sub {
    $cf->do;
    open my $fh, '<', $tmp->filename;
    my @config_ips = grep { !/^\s*#/ } <$fh>;
    close $fh;
    chomp @config_ips;
    is_deeply \@config_ips, \@ips;
};

&done_testing;
