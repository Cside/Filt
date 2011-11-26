package Filt::Config;
use strict;
use warnings;
use Path::Class;
use Config::Tiny;
use parent qw/Exporter/;
our @EXPORT_OK = qw/conf/;
use Carp;

my $conf;
sub conf { $conf ||= get_conf() }

sub get_conf {
    my $config = Config::Tiny->read(
        file(__FILE__)->dir->parent->parent->file('config.ini')
    )->{_};

    $config->{username}                  or Carp::croak "need username in config.ini";
    $config->{threshold}                 ||= 1;
    $config->{ignore_categories}         ||= '';
    $config->{ignore_words}              ||= '';
    $config->{ignore_urls}               ||= '';
    $config->{ignore_already_bookmarked} ||= 0;
    $config->{ignore_recent_bookmarked}  ||= 0;

    $config;
}

1;

