# vi:filetype=

use lib 't/lib';
use Test::Nginx::Socket;

plan tests => repeat_each() * 2 * blocks();

#no_diff;

run_tests();

__DATA__

=== TEST 1: bad ext (missing leading ;)
--- config
    location /main {
        echo_read_request_body;
        echo_request_body;
    }
--- more_headers
Transfer-Encoding: chunked
--- request eval
"POST /main
3 a=b\r
abc\r
0\r
\r
"
--- response_body_like: 400 Bad Request
--- error_code: 400



=== TEST 2: sanity
--- config
    location /main {
        echo_read_request_body;
        echo_request_body;
    }
--- more_headers
Transfer-Encoding: chunked
--- request eval
"POST /main
3;a=b\r
abc\r
0\r
\r
"
--- response_body: abc



=== TEST 3: with spaces
--- config
    location /main {
        echo_read_request_body;
        echo_request_body;
    }
--- more_headers
Transfer-Encoding: chunked
--- request eval
"POST /main
3 ;\t a\t = b\r
abc\r
0\r
\r
"
--- response_body: abc



=== TEST 4: ext with out val
--- config
    location /main {
        echo_read_request_body;
        echo_request_body;
    }
--- more_headers
Transfer-Encoding: chunked
--- request eval
"POST /main
3 ;\t foo\t \r
abc\r
0\r
\r
"
--- response_body: abc



=== TEST 5: multiple exts
--- config
    location /main {
        echo_read_request_body;
        echo_request_body;
    }
--- more_headers
Transfer-Encoding: chunked
--- request eval
"POST /main
3 ;\t foo = bar; blah = ".'"hello\\\"!"'."\t \r
abc\r
0\r
\r
"
--- response_body: abc

