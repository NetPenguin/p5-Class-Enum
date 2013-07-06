use strict;
use warnings;
use Test::More;

my $class;
BEGIN {
    use_ok($class='t::SimpleUsage', qw(Left Right));
}

# ----
# Helpers.

# ----
# Tests.
subtest 'default properties' => sub {
    is(Left->name, 'Left', 'Left->name');
    is(Right->name, 'Right', 'Right->name');
    is(Left->ordinal, 0, 'Left->ordinal');
    is(Right->ordinal, 1, 'Right->ordinal');
};

subtest 'compare with ordinal' => sub {
    is(Left  <=> Right, -1, 'Left  <=> Right');
    is(Left  <=> Left ,  0, 'Left  <=> Left');
    is(Right <=> Right,  0, 'Right <=> Right');
    is(Right <=> Left ,  1, 'Right <=> Left');

    is(Left  < Left , '', 'Left  < Left');
    is(Left  < Right,  1, 'Left  < Right');
    is(Right < Left , '', 'Right < Left');
    is(Right < Right, '', 'Right < Right');

    is(Left  <= Left ,  1, 'Left  <= Left');
    is(Left  <= Right,  1, 'Left  <= Right');
    is(Right <= Left , '', 'Right <= Left');
    is(Right <= Right,  1, 'Right <= Right');

    is(Left  > Left , '', 'Left  > Left');
    is(Left  > Right, '', 'Left  > Right');
    is(Right > Left ,  1, 'Right > Left');
    is(Right > Right, '', 'Right > Right');

    is(Left  >= Left ,  1, 'Left  >= Left');
    is(Left  >= Right, '', 'Left  >= Right');
    is(Right >= Left ,  1, 'Right >= Left');
    is(Right >= Right,  1, 'Right >= Right');

    is(Left  == Left ,  1, 'Left  == Left');
    is(Left  == Right, '', 'Left  == Right');
    is(Right == Right,  1, 'Right == Right');

    is(Left  != Left , '', 'Left  != Left');
    is(Left  != Right,  1, 'Left  != Right');
    is(Right != Right, '', 'Right != Right');
};


# ----
done_testing;
