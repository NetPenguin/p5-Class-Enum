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

=head2 Advanced usage.

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

=head2 Override default properties. (Unrecommended)

Define `Direction`,

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

=head1 DESCRIPTION

Class::Enum provides behaviors of typed enum, such as a Typesafe enum in java.

=cut
use Carp qw(
    carp
    croak
);
use Data::Util qw(
    install_subroutine
    is_hash_ref
    is_string
);
use Exporter qw();
use String::CamelCase qw(
    decamelize
);

sub import {
    my $class = shift;
    my ($package) = caller(0);
    my @parameters = __read_import_parameters(@_);
    my $definition = __prepare($package);
    __define($package, $definition, $_) foreach @parameters;
}

sub __read_import_parameters {
    my @parameters;
    for (my $i=0; $i<@_; $i++) {
        my ($identifier, $properties) = @_[$i, $i+1];

        unless (is_string($identifier)) {
            local $Carp::CarpLevel += 1;
            croak('requires NAME* or (NAME => PROPERTIES)* parameters at \'use Class::Enum\', ' .
                  'NAME is string, PROPERTIES is hashref. ' .
                  '(e.g. \'use Class::Enum qw(Left Right)\' ' .
                  'or \'use Class::Enum Left => { delta => -1 }, Right => { delta => 1 }\')');
        }

        push @parameters, {
            identifier => $identifier,
            properties => is_hash_ref($properties) ? do { $i++; $properties } : {},
        };
    }
    return @parameters;
}

my %definition_of;
sub __prepare {
    my ($package) = @_;
    return $definition_of{$package} if exists $definition_of{$package};

    # install overload.
    install_subroutine(
        $package,
        '((' => \&__nil,
        '(<=>' => \&__ufo_operator,
        '(cmp' => \&__cmp_operator,
        '(""' => \&__string_conversion,
        '(0+' => \&__numeric_conversion,
    );

    # install exporter.
    install_subroutine(
        $package,
        import => \&Exporter::import,
    );
    my $exportables = [];
    {
        no strict 'refs';
        *{$package . '::EXPORT_OK'} = $exportables;
        *{$package . '::EXPORT_TAGS'} = {all => $exportables};
    }

    # install class methods.
    install_subroutine(
        $package,
        value_of => \&__value_of,
        values => \&__values,
        names => \&__names,
    );

    # create initial definition.
    return $definition_of{$package} = {
        value_of => {},
        properties => {},
        identifiers => {},
        next_ordinal => 0,
        exportables => $exportables,
    };
}

# installed for overload method.
sub __nil {}
sub __ufo_operator {
    my ($lhs, $rhs) = @_;
    carp('Use of uninitialized value in overloaded numeric comparison '.
         '(<=>, <, <=, >, >=, ==, !=)')
        unless defined($lhs) && defined($rhs);
    return ($lhs ? $lhs->ordinal : 0) <=> ($rhs ? $rhs->ordinal : 0);
}
sub __cmp_operator {
    my ($lhs, $rhs) = @_;
    carp('Use of uninitialized value in overloaded string comparison '.
         '(cmp, lt, le, gt, ge, eq, ne)')
        unless defined($lhs) && defined($rhs);
    return ($lhs ? $lhs->name : '') cmp ($rhs ? $rhs->name : '');
}
sub __string_conversion {
    my ($self) = @_;
    return $self->name;
}
sub __numeric_conversion {
    my ($self) = @_;
    return $self->ordinal;
}

# installed for class method.
sub __value_of {
    my ($class, $name) = @_;
    return $definition_of{$class}->{value_of}->{$name};
}
sub __values {
    my ($class) = @_;
    my $definition = $definition_of{$class};
    my $values = $definition->{values} ||= [
        sort { $a <=> $b }
            values %{$definition->{value_of}}
    ];
    return @$values;
}
sub __names {
    my ($class) = @_;
    my $names = $definition_of{$class}->{names}
                ||= [map { $_->name } __values($class)];
    return @$names;
}

# define instance.
sub __define {
    my ($package, $definition, $parameter) = @_;
    local $Carp::CarpLevel += 1;

    # create instance.
    my $value = bless {
        name    => $parameter->{identifier},
        ordinal => $definition->{next_ordinal},
        %{$parameter->{properties}},
    }, $package;

    # update definition.
    my $name = $value->{name};
    my $value_of = $definition->{value_of};
    croak("Same name is already defined.(name: $name)")
        if exists $value_of->{$name};

    $value_of->{$name} = $value;
    $definition->{next_ordinal} = $value->{ordinal} + 1;
    delete $definition->{values};
    delete $definition->{names};

    # install property accessors.
    my $properties = $definition->{properties};
    foreach my $key (grep { not exists $properties->{$_} } keys(%$value)) {
        my $accessor = __generate_property_accessor($key);
        install_subroutine(
            $package,
            $key => $accessor,
        );
        $properties->{$key} = $accessor;
    }

    # install identifier function.
    my $identifier = $parameter->{identifier};
    my $identifiers = $definition->{identifiers};
    croak("Same identifier is already defined.(identifier: $identifier)")
        if exists $identifiers->{$identifier};

    my $instance_accessor = __generate_instance_accessor($value);
    install_subroutine(
        $package,
        $identifier => $instance_accessor,
    );
    $identifiers->{$identifier} = $instance_accessor;
    push @{$definition->{exportables}}, $identifier;

    # install is_* methods.
    install_subroutine(
        $package,
        'is_' . decamelize($name) => __generate_is_method($value),
    );
}
sub __generate_property_accessor {
    my ($name) = @_;
    return sub {
        my ($self) = @_;
        return $self->{$name};
    };
}
sub __generate_instance_accessor {
    my ($instance) = @_;
    return sub {
        return $instance;
    };
}
sub __generate_is_method {
    my ($instance) = @_;
    return sub {
        my ($self) = @_;
        return $self == $instance;
    };
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
