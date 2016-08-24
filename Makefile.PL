use inc::Module::Install;

name 'CloudFlare-Nginx-RealIP';
all_from 'lib/CloudFlare/Nginx/RealIP.pm';

requires 'LWP::UserAgent';
requires 'Net::CIDR';
requires 'Time::Piece';
requires 'Array::Utils';

test_requires 'Test::More';
test_requires 'File::Temp';

install_script 'script/cloudflare_update_nginx_realip';

WriteAll;
