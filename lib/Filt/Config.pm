package Filt::Config;
use strict;
use warnings;
use Path::Class;
use Config::Tiny;
use parent qw/Class::Data::Inheritable/;
__PACKAGE__->mk_classdata('CONF');
__PACKAGE__->CONF(get_conf());
use Carp;

sub get_conf {
    my $config = Config::Tiny->read(
        file(__FILE__)->dir->parent->parent->file('config.ini')
    );

    $config->{_}->{username} or Carp::croak "need username in config.ini";
    $config->{_}->{threshold}                 ||= 1;
    $config->{_}->{ignore_categories}         ||= '';
    $config->{_}->{ignore_words}              ||= '';
    $config->{_}->{ignore_urls}               ||= '';
    $config->{_}->{ignore_already_bookmarked} ||= 0;
    $config->{_}->{ignore_recent_bookmarked}  ||= 0;

    $config;
}

1;

