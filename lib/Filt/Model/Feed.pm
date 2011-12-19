package Filt::Model::Feed;
use strict;
use warnings;
use utf8;
use Filt::Config qw/conf/;
use Web::Query;
use HTML::Entities qw/encode_entities/;

our $Max_Results = 20;

sub _encode_entities { encode_entities(shift, q|<>&"'|) }

sub get {
    my ($class) = @_;
    my $url = sprintf "http://b.hatena.ne.jp/%s/favorite?threshold=%d", conf->{username}, conf->{threshold};

    wq($url)
    ->find('ul.main-entry-list > li')
    ->filter(sub {
        my $i = shift;
        $i < $Max_Results;
    })
    ->map(sub {
        my $entry = $_;

        +{
            title     => _encode_entities($entry->find('h3.entry-title a.entry-link')->text),
            url       => $entry->find('h3.entry-title a.entry-link')->attr('href'),
            category  => substr($entry->find('ul > li.category > a.category-link')->attr('href'), 10),
            timestamp => sprintf("%04d-%02d-%02dT00:00:00Z",
                             $entry->find('ul.entry-comment > li > .timestamp')->text =~ m#(\d{4})/(\d{2})/(\d{2})#
                         ),
            users     => $entry->find('ul.entry-comment > li img.profile-image')->map(sub {$_->attr('alt')}),
            summary   => do {
                             my $summary = $entry->find('.entry-summary')->text;
                             $summary =~ s/続きを読む// if $summary;
                             _encode_entities $summary;
                         },
            comments  => [
                            grep {$_} @{
                                $entry->find('ul.entry-comment > li')
                                ->map(sub {
                                    my $img = $_->find('img');
                                    $img->attr('width',  16);
                                    $img->attr('height', 16);
                                    my $head = join(" ", @{$_->find('.header > *')->map(sub {$_->html})});
                                    my $comment = _encode_entities($_->find('.comment')->text);
                                    my $timestamp = $_->find('.timestamp')->text;

                                    ($head && $timestamp) ? join(" ", $head, $comment, $timestamp) : undef;
                                })
                            }
                         ]
        }
    });
}

1;
