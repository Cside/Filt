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

    wq($stuff)
    ->find('ul.main-entry-list > li')
    ->filter(sub {
        my $i = shift;
        $i < $MAX_RESULTS;
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
                                    $img = $img->html;

                                    my $username = '<strong>' . $_->find('.username')->text . '</strong>';
                                    my $tags = join ', ', @{
                                                   $_->find('.user-tag')
                                                   ->map(sub {
                                                       sprintf("<span style=\"color:green;\">%s</span>", _encode_entities $_->text || '')
                                                   })
                                               };
                                    my $timestamp = sprintf("<span style=\"color:#999;\">%s</span>", $_->find('.timestamp')->text || '');
                                    my $comment = _encode_entities($_->find('.comment')->text);

                                    ($username && $timestamp) ? join(" ", $img, $username, $tags, $comment, $timestamp)
                                                              : undef;
                                })
                            }
                         ]
        }
    });
}

1;
