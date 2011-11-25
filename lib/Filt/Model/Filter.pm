package Filt::Model::Filter;
use strict;
use warnings;
use utf8;
use Encode;
use Class::Accessor::Lite (
    rw => [ qw/data/ ],
);
use parent qw/Filt::Config/;

our $AUTOLOAD;

sub do {
    my ($class, $data) = @_;
    my $self = bless { data => $data }, $class;
    $self
    ->filter_by('urls')
    ->filter_by('words')
    ->filter_by('categories')
    ->filter_by('already_bookmarked')
    ->filter_by('recent_bookmarked')
    ->data;
}

sub filter_by {
    my ($self, $key) = @_;

    my %handler = (
        words => sub {
            my ($entry, $ignore_case) = @_;
            grep {
                decode_utf8($entry->{title}) =~ /$_/i
            } split(/,/, decode_utf8 $ignore_case)
        },
        categories => sub {
            my @corresp = qw/social economics life entertainment knowledge it game fun/;
            grep { $entry->{category} eq $_ }
            map { $corresp[$_ - 1]; }
            split(/,/, $ignore_case)
        },
        urls => sub {
            grep { $entry->{url} =~ /$_/i }
            split(/,/,  $ignore_case)
        },
        already_bookmarked => sub {
            grep { $_ eq __PACKAGE__->CONF->{_}->{username} }
            @{$entry->{users}}
        },
        recent_bookmarked => sub {
            $entry->{users}->[0] eq __PACKAGE__->CONF->{_}->{username}
        },
    );

    if (my $method = $handler{$key}) {
        my $ignore_case = __PACKAGE__->CONF->{_}->{'ignore_' . $key});
        my @filtered = grep {
            ! $method->($_, $ignore_case)
        } @{$self->data};

        $self->data(\@filtered);
    }

    $self;
}

1;
