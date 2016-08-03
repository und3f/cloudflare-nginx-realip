package CloudFlare::Nginx::RealIP;

use strict;
use warnings;

use LWP::UserAgent;
use Net::CIDR;
use Time::Piece;

sub new {
    my ($class, %args) = @_;

    $args{ua} = LWP::UserAgent->new() unless defined $args{ua};
    bless {
        basic_url   => 'https://www.cloudflare.com/',
        ips_lists   => [qw(ips-v4 ips-v6)],
        output_file => "/etc/nginx/cloudflare-realip.conf",
        %args
    }, $class;
}

sub _get_list {
    my ($self, $url) = @_;

    my $response = $self->{ua}->get($url);
    die qq(Error retrieving "$url": ) . $response->status_line
      unless $response->is_success;

    my $text = $response->decoded_content;
    my @ips = split /\n/, $text;
    foreach my $ip (@ips) {
        die qq(Received invalid cidr from "$url": $ip)
          unless Net::CIDR::cidrvalidate($ip);
    }

    return @ips;
}

sub get_ip_list {
    my $self = shift;

    my @ips;
    foreach my $ips_list_uri (@{$self->{ips_lists}}) {
        my $url = $self->{basic_url} . $ips_list_uri;
        push @ips, $self->_get_list($url);
    }
    return @ips;
}

sub write_config {
    my ($self, $ips) = @_;

    open my $fh, '>', $self->{output_file}
      or die qq(Unable to open "$self->{output_file}": $!);

    print $fh "# CloudFlare IP ranges updated on "
      . localtime->strftime . "\n";

    print $fh join("\n", map {"set_real_ip_from $_;"} @$ips);
    close $fh;
}

sub do {
    my $self = shift;

    my @ips = $self->get_ip_list;
    $self->write_config(\@ips);
}


1;
