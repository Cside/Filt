package Filt::Model::Feed;
use strict;
use warnings;
use utf8;
use URI;
use Web::Scraper;
use Filt::Config qw/conf/;

sub get {
    my ($class) = @_;
    my $url = "http://b.hatena.ne.jp/"
              . conf->{username}
              . "/favorite?threshold="
              . conf->{threshold};
    my $scraper = scraper {
        process "ul.main-entry-list > li", 'entries[]' => scraper {
            process "h3.entry-title a.entry-link",
                    title => "TEXT";
            process "h3.entry-title a.entry-link",
                    url => ['@href', sub { $_->as_string }];
            process "ul > li.category > a.category-link",
                    category => ['@href', sub { substr $_->path, 10 }];
            process "ul.entry-comment > li img.profile-image",
                    'users[]' => '@alt';
            process "ul.entry-comment > li > span.timestamp",
                    timestamp => ['TEXT', sub { sprintf "%04d-%02d-%02dT00:00:00Z", $_ =~ m#(\d{4})/(\d{2})/(\d{2})# }];
            process "ul.entry-comment > li",
                    'comments[]' => 'HTML';
        };
    };
    my $res = eval { $scraper->scrape(URI->new($url)) };
    $@ ? undef : $res->{entries};
}

1;
