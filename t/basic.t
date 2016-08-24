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

subtest 'old_config_matches() (no)' => sub {
    ok !$cf->old_config_matches(\@ips), 'old config does not matches';
};

subtest 'do()' => sub {
    $cf->do;
    open my $fh, '<', $tmp->filename;
    my @config_ips =
      map { (/^set_real_ip_from\s+(.+);/)[0] } grep { !/^\s*#/ } <$fh>;
    close $fh;
    chomp @config_ips;
    is_deeply \@config_ips, \@ips;
};

subtest 'old_config_matches() (yes)' => sub {
    ok $cf->old_config_matches(\@ips), 'old config matches';
    ok !$cf->old_config_matches([@ips, '127.1.2.3']), 'old config matches';
};

&done_testing;
