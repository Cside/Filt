package Filt::View::Atom;
use strict;
use warnings;
use utf8;
use Digest::MD5 qw/md5_base64/;
use XML::Feed;
use XML::Feed::Entry;
use DateTime;
use DateTime::Format::W3CDTF;

sub render {
    my ($class, %opt) = @_;
    my $self = bless {}, $class;
    my $username = $opt{username};
    my $data     = $opt{data};
    my $url = 'http://b.hatena.ne.jp/' . $username . '/favorite';

    my $feed = XML::Feed->new('Atom');
    $feed->title($username . 'のブックマーク');
    $feed->id(url_to_id($url));
    $feed->author($username);

    $feed->add_entry(to_entry($_)) for @$data;
    $feed->as_xml;
}

sub to_entry {
    my ($data) = @_;
    my %category_label = (
        social        => '社会',
        economics     => '政治・経済',
        life          => '生活・人生',
        entertainment => 'スポーツ・芸能・音楽',
        knowledge     => '科学・学問',
        it            => 'コンピュータ・IT',
        game          => 'ゲーム・アニメ',
        fun           => 'おもしろ',
    );

    my $entry = XML::Feed::Entry->new('Atom');
    $entry->title($data->{title});
    $entry->id(url_to_id($data->{url}));

    my $dt = DateTime::Format::W3CDTF->new;
    $entry->modified($dt->parse_datetime($data->{timestamp}));

    $entry->link($data->{url});

    $entry->category($category_label{$data->{category}});

    my $content = $entry->content;
    $content->type('text/html');
    $content->body(
        sprintf "<p>%s</p><ul style=\"list-style:none;\">%s</ul>",
                $data->{summary},
                join '', map {'<li>' . $_ . '</li>'} @{$data->{comments}}
    );
    $entry->content($content);

    $entry;
}

sub url_to_id { 'tag:hatena.ne.jp,2011:bookmark-' . md5_base64($_[0]) }

1;
