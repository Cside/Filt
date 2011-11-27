package Filt::Model::Feed;
use strict;
use warnings;
use utf8;
use URI;
use Filt::Config qw/conf/;
use Web::Query;

sub get {
    my ($class) = @_;
    my $url = sprintf "http://b.hatena.ne.jp/%s/favorite?threshold=%d", conf->{username}, conf->{threshold};
    
    wq($url)->find('ul.main-entry-list > li')->map(sub {
        my $entry = $_;
        +{
            title     => $entry->find('h3.entry-title a.entry-link')->text,
            url       => $entry->find('h3.entry-title a.entry-link')->attr('href'),
            category  => substr($entry->find('ul > li.category > a.category-link')->attr('href'), 10),
            timestamp => sprintf("%04d-%02d-%02dT00:00:00Z",
                             $entry->find('ul.entry-comment > li > .timestamp')->text =~ m#(\d{4})/(\d{2})/(\d{2})#
                         ),
            users     => $entry->find('ul.entry-comment > li img.profile-image')->map(sub {$_->attr('alt')}),
            comments  => $entry->find('ul.entry-comment > li')
                         ->map(sub {
                             join(" ",
                                 join(" ", @{$_->find('.header > *')->map(sub {$_->html})}),
                                 $_->find('.comment')->text,
                                 $_->find('.timestamp')->text
                             );
                         }),
        }
    });
}

1;
