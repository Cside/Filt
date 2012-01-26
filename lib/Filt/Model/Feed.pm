package Filt::Model::Feed;
use strict;
use warnings;
use utf8;
use Web::Query;
use HTML::Entities qw/encode_entities/;

our $MAX_RESULTS = 20;

sub _encode_entities { encode_entities(shift, q|<>&"'|) }

sub get {
    my ($class, $stuff) = @_;

    my $wq = wq($stuff);

    my $is_renewed = $wq->find('#left-container')->size > 0;
    my %selector = (
        ul => $is_renewed
            ? 'ul.main-entry-list > li'
            : 'ul#bookmarked_user > li',
        title => $is_renewed
            ? 'h3.entry-title a.entry-link'
            : 'h3.entry > a.entry-link',
        comments => $is_renewed
            ? 'ul.entry-comment > li'
            : 'div.comment > ul.comment > li',
        timestamp => $is_renewed
            ? 'ul.entry-comment > li > span.timestamp'
            : 'div.comment > ul.comment > li > span.timestamp',
        users => $is_renewed
            ? 'ul.entry-comment > li img.profile-image'
            : 'ul.comment > li img.profile-image',
        url => $is_renewed
            ? 'h3.entry-title > a.entry-link'
            : 'h3.entry > a.entry-link',
    );

    $wq
    ->find($selector{ul})
    ->filter(sub {
        my $i = shift;
        $i < $MAX_RESULTS;
    })
    ->map(sub {
        my $entry = $_;

        +{
            title     => _encode_entities($entry->find($selector{title})->text),
                url       => $entry->find($selector{url})->attr('href'),
                category  => substr($entry->find('ul > li.category > a.category-link')->attr('href') || '', 10),
                timestamp => sprintf("%04d-%02d-%02dT00:00:00Z",
                    $entry->find($selector{timestamp})->text =~ m#(\d{4})/(\d{2})/(\d{2})#
                ),
                users     => $entry->find($selector{users})->map(sub {$_->attr('alt')}),
                summary   => do {
                    if ($is_renewed) {
                        my $summary = $entry->find('.entry-summary')->text;
                        $summary =~ s/続きを読む// if $summary;
                        _encode_entities $summary;
                    } else {
                        ''
                    }
                },
                comments  => [grep {$_} @{
                    $entry->find($selector{comments})
                    ->map(sub {
                        my $img = $_->find('img');
                        $img->attr('width',  16);
                        $img->attr('height', 16);
                        $img = $img->html;

                        my $username = $_->find('.username')->text or return;
                           $username = "<strong class=\"username\">$username</strong>";
                        my $tags = join ', ', @{
                            $_->find('.user-tag')
                            ->map(sub {
                                sprintf("<span class=\"tag\" style=\"color:green;\">%s</span>", _encode_entities $_->text || '')
                            })
                        };
                        my $timestamp = sprintf("<span class=\"timestamp\" style=\"color:#999;\">%s</span>", $_->find('.timestamp')->text || '');
                        my $comment = '<span class="comment">' . _encode_entities($_->find('.comment')->text) || '' . '</span>';

                        ($username && $timestamp) ? join(" ", $img, $username, $tags, $comment, $timestamp)
                                                  : undef;
                    })
                }]
        }
    });
}

1;
