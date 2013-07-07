# NAME

Class::Enum - typed enum

# SYNOPSIS

## Simple usage.

Define \`Direction\`,

    # Direction.pm
    package Direction;
    use Class::Enum qw(Left Right);

and using.

    # using
    use Direction qw(Left Right);
    

    # compare by ordinal
    print Left() <=> Right; # -1
    print Left() <   Right; # 1
    print Left() <=  Right; # 1
    print Left() >   Right; # ''
    print Left() >=  Right; # ''
    print Left() ==  Right; # ''
    print Left() !=  Right; # 1
    

    # compare by name
    print Left() cmp Right; # -1
    print Left() lt  Right; # 1
    print Left() le  Right; # 1
    print Left() gt  Right; # ''
    print Left() ge  Right; # ''
    print Left() eq  Right; # ''
    print Left() ne  Right; # 1
    

    # list values
    print join("\n",                                                 # '0: Left
               map { sprintf('%d: %s', $_, $_) } Direction->values); #  1: Right'
    

    # list names
    print join(', ', Direction->names); # 'Left, Right'
    

    # retrieve value of name
    print Left() == Direction->value_of('Left'); # 1
    

    # type
    print ref Left; # 'Direction'

## Advanced usage.

Define \`Direction\`,

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

## Override default properties. (Unrecommended)

Define \`Direction\`,

    # Direction.pm
    package Direction;
    use Class::Enum (
        Left   => { name => 'L', ordinal => -1 },
        Center => { name => 'C' }
        Right  => { name => 'R' },
    );

and using.

    # using
    use Direction qw(Left Center Right);
    

    my $pos = 5;
    print $pos + int(Left);   # 4
    print $pos + int(Center); # 5
    print $pos + int(Right);  # 6
    

    print 'Left is '   . Left;   # 'Left is L'
    print 'Center is ' . Center; # 'Center is C'
    print 'Right is '  . Right;  # 'Right is R'

# DESCRIPTION

Class::Enum provides behaviors of typed enum, such as a Typesafe enum in java.

# LICENSE

Copyright (C) keita.iseki.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

keita.iseki <keita.iseki+cpan at gmail.com>
