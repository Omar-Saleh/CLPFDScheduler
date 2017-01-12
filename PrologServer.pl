:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- http_handler('/api', handle_api, []).

:- multifile http_json/1.

http_json:json_type('application/x-javascript').
http_json:json_type('text/javascript').
http_json:json_type('text/x-javascript').
http_json:json_type('text/x-json').

handle_api(Request) :-
        % http_read_json_dict(Request, Query),
        print(Request),
        Solution = 'Hello',
        reply_json_dict(Solution).

server(Port) :-
        http_server(http_dispatch, [port(Port)]).
        :- http_handler(/, say_hi, []).

        /* The implementation of /. The single argument provides the request
        details, which we ignore for now. Our task is to write a CGI-Document:
        a number of name: value -pair lines, followed by two newlines, followed
        by the document content, The only obligatory header line is the
        Content-type: <mime-type> header.
        Printing can be done using any Prolog printing predicate, but the
        format-family is the most useful. See format/2.   */

        say_hi(_Request) :-
                
                format('Content-type: text/plain~n~n'),
                format('Hello World!~n').
