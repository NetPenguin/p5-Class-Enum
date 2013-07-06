package Class::Enum;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

=encoding utf-8

=head1 NAME

Class::Enum - typed enum

=head1 SYNOPSIS

=head2 Simple usage.

Define `Direction`,

    # Direction.pm
    package Direction;
    use Class::Enum qw(Left Right);

and using.

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

=head2 Extended usage.

Define `Direction`,

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

and using.

    # using
    use Direction qw(Left Right);
    
    my $pos = 5;
    print Left->move($pos);  # 4
    print Right->move($pos); # 6

=head2 Override default properties.

Define `Direction`,

    # Direction.pm
    package Direction;
    use Class::Enum (
        Left  => { ordinal => -1, name => 'L' },
        Right => { ordinal =>  1, name => 'R' },
    );

and using.

    # using
    use Direction qw(Left Right);
    
    my $pos = 5;
    print $pos + Left;  # 4
    print $pos + Right; # 6
    
    print 'Left is '  . Left;  # 'Left is L'
    print 'Right is ' . Right; # 'Right is R'

=head1 DESCRIPTION

Class::Enum provides behaviors of typed enum, such as a Typesafe enum in java.

=cut
use Carp qw(croak);
use Data::Util qw(
    install_subroutine
    is_hash_ref
    is_string
);

sub import {
    my $class = shift;
    my ($package) = caller(0);
    my @definitions = __normalize_import_parameter(@_);
}

sub __normalize_import_parameter {
    my @definitions;
    for (my $i=0; $i<@_; $i++) {
        my ($name, $properties) = @_[$i, $i+1];

        unless (is_string($name)) {
            local $Carp::CarpLevel += 1;
            croak('requires NAME* or (NAME => PROPERTIES)* parameters at \'use Class::Enum\', ' .
                  'NAME is string, PROPERTIES is hashref. ' .
                  '(e.g. \'use Class::Enum qw(Left Right)\' ' .
                  'or \'use Class::Enum Left => { delta => -1 }, Right => { delta => 1 }\')');
        }

        push @definitions, { name => $name };

        if (is_hash_ref($properties)) {
            ++$i;
            $definitions[-1]->{properties} = $properties;
        }
    }
    return @definitions;
}

1;
__END__

=head1 LICENSE

Copyright (C) keita.iseki.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

keita.iseki E<lt>keita.iseki+cpan at gmail.comE<gt>

=cut
