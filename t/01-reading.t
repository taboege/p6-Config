#! /usr/bin/env perl6

use v6.c;
use Test;
use lib "lib";

plan 5;

use Config;

my Config $config = Config.new();

throws-like { $config.read("t/files/none") }, Config::Exception::FileNotFoundException, "Reading nonexisting file";
throws-like { $config.read("t/files/config", "Config::Parser:NoSuchParserForTest") }, Config::Exception::MissingParserException, "Using non-existing parser";

my $hash = {
    "a" => "a",
    "b" => {
        "c" => "test"
    }
};

$config.read($hash);

is-deeply $config.get(), $hash, "Correctly sets hash";

$config.read({
    "b" => {
        "d" => "another"
    }
});

is-deeply $config.get(), {
    "a" => "a",
    "b" => {
        "c" => "test",
        "d" => "another"
    }
}, "Correctly merges new hash into existing config";

subtest {
    plan 3;

    # Use the NULL parser to mock the parser
    my $parser = "Config::Parser::NULL";

    is $config.read(("t/files/config", "t/files/config.yaml"), $parser, skip-not-found => True), True, "All paths exist";
    is $config.read(("t/files/config", "t/files/none", "t/files/config.yaml"), $parser, skip-not-found => True), True, "At least one path exists";
    is $config.read(("t/files/none", "t/files/none.yaml"), $parser, skip-not-found => True), False, "No paths exist";
}, "Read with a List of paths";
