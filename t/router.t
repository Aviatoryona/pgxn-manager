#!/usr/bin/env perl

use 5.12.0;
use utf8;
use Test::More tests => 10;
#use Test::More 'no_plan';
use Plack::Test;
use HTTP::Request::Common;
use Test::File::Contents;
use PGXN::Manager;

BEGIN {
    use_ok 'PGXN::Manager::Router' or die;
}

test_psgi +PGXN::Manager::Router->app => sub {
    my $cb = shift;
    ok my $res = $cb->(GET '/'), 'Fetch /';
    is $res->code, 200, 'Should get 200 response';
    like $res->content, qr/Welcome/, 'The body should look correct';
};

test_psgi +PGXN::Manager::Router->app => sub {
    my $cb = shift;
    ok my $res = $cb->(GET '/ui/css/screen.css'), 'Fetch /ui/css/screen.css';
    is $res->code, 200, 'Should get 200 response';
    file_contents_is 'www/ui/css/screen.css', $res->content,
        'The file should have been served';
};

# /auth should require authentication.
test_psgi +PGXN::Manager::Router->app => sub {
    my $cb = shift;
    ok my $res = $cb->(GET '/auth'), 'Fetch /auth';
    is $res->code, 401, 'Should get 401 response';
    like $res->content, qr/Authorization required/,
        'The body should indicate need for authentication';
};

# XXX Test authentication (need fixtures).

