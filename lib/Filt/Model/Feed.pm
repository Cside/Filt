package Filt::Model::Feed;
use strict;
use warnings;
use utf8;
use URI;
use Web::Scraper;
use parent qw/Filt::Config/;

sub get {
    my ($class) = @_;
    my $url = "http://b.hatena.ne.jp/"
              . __PACKAGE__->CONF->{_}->{username}
              . "/favorite?threshold="
              . __PACKAGE__->CONF->{_}->{threshold};
    my $scraper = scraper {
        process "ul.main-entry-list > li", 'entries[]' => scraper {
            process "h3.entry-title a.entry-link",
                    title => "TEXT";
            process "h3.entry-title a.entry-link",
                    url => ['@href', sub { $_->as_string }];
            process "ul > li.category > a.category-link",
                    category => ['@href', sub { substr $_->path, 10 }];
            process "ul.entry-comment > li > a.username",
                    'users[]' => 'TEXT';
            process "ul.entry-comment > li > span.timestamp",
                    timestamp => ['TEXT', sub { sprintf "%04d-%02d-%02dT00:00:00Z", $_ =~ m#(\d{4})/(\d{2})/(\d{2})# }];
            process "ul.entry-comment > li",
                    'comments[]' => 'HTML';
        };
    };
    my $res = eval { $scraper->scrape(URI->new($url)) };
    return undef if $@;
    $res->{entries};
}

1;
