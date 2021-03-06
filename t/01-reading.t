#! /usr/bin/env perl6

use v6.c;
use Test;

plan 6;

use Config;

my Config $config = Config.new();
my Str $null-parser = "Config::Parser::NULL";

throws-like { $config.read("t/files/none") }, Config::Exception::FileNotFoundException, "Reading nonexisting file";
throws-like { $config.read("t/files/config", "Config::Parser:NoSuchParserForTest") }, Config::Exception::MissingParserException, "Using non-existing parser";

subtest ".read allows for non-fatal execution with skip-not-found set", {
    plan 3;

    my %old = $config.get;
    my $result = $config.read("t/files/none", $null-parser, :skip-not-found);

    ok $result, "Result is ok";
    is-deeply $result.get, %old, "Config did not change";
    isa-ok $result, Config, ".read returned a Config";
}

my %hash = %(
    "a" => "a",
    "b" => %(
        "c" => "test",
    ),
);

$config.read: %hash;

is-deeply $config.get, %hash, "Correctly sets hash";

$config.read: %(
    "b" => %(
        "d" => "another",
    ),
);

is-deeply $config.get, %(
    "a" => "a",
    "b" => %(
        "c" => "test",
        "d" => "another",
    ),
), "Correctly merges new hash into existing config";

subtest {
    plan 3;

    ok $config.read(("t/files/config", "t/files/config.yaml"), $null-parser, :skip-not-found), "All paths exist";
    ok $config.read(("t/files/config", "t/files/none", "t/files/config.yaml"), $null-parser, :skip-not-found), "At least one path exists";
    ok $config.read(("t/files/none", "t/files/none.yaml"), $null-parser, :skip-not-found), "No paths exist";
}, "Read with a List of paths";
