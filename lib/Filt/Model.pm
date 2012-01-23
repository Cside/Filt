package Filt::Model;
use strict;
use warnings;
use Filt::Model::Feed;
use Filt::Model::Filter;
use Filt::Config qw/conf/;

sub get_feed {
    my ($class) = @_;
    my $url = sprintf "http://b.hatena.ne.jp/%s/favorite?threshold=%d", conf->{username}, conf->{threshold};
    my $res = Filt::Model::Feed->get($url);
    return undef unless $res;
    Filt::Model::Filter->do($res);
}

1;

