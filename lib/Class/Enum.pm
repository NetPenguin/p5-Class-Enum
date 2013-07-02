package Class::Enum;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

=encoding utf-8

=head1 NAME

Class::Enum - typed enum

=head1 SYNOPSIS

Simple usage.

    # Direction.pm
    package Direction;
    use Class::Enum qw(Left Right);

    # using
    use Direction qw(Left Right);
    
    # compare with ordinal
    print Left <=> Right; # -1
    print Left == Right;  # ''
    print Left != Right;  # 1
    print Left <= Right;  # 1
    
    # compare with name
    print Left cmp Right; # -1
    print Left eq Right;  # ''
    print Left ne Right;  # 1
    
    # list values
    print join("\n",                                                     # '0: Left
               map { $_->ordinal . ': ' . $_->name } Direction->values); #  1: Right'
    
    # list names
    print join(', ', Direction->names); # 'Left, Right'
    
    # retrieve value of name
    print Left == Direction->value_of('Left'); # 1
    
    # type
    print ref Left; # 'Direction'

Extended usage.

    # Direction.pm
    package Direction;
    use Class::Enum (
        Left  => { delta => -1 },
        Right => { delta =>  1 },
    );
    
    sub move {
        my ($self, $pos) = @_;
        return $pos + $self->delta;
    }

    # using
    use Direction qw(Left Right);
    
    my $pos = 5;
    my $left_pos = Left->move($pos);   # $left_pos is 4
    my $right_pos = Right->move($pos); # $right_post is 6

=head1 DESCRIPTION

Class::Enum provides behaviors of typed enum, such as a Typesafe enum in java.

=cut


1;
__END__

=head1 LICENSE

Copyright (C) keita.iseki.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

keita.iseki E<lt>keita.iseki+cpan at gmail.comE<gt>

=cut
