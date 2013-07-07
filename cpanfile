requires 'perl', '5.008001';
requires 'Carp';
requires 'Data::Util';
requires 'Exporter';
requires 'String::CamelCase';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
