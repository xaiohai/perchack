:-module(perc_reader, [go/0]).

:- use_module(process_message).

go :-
	create_client('127.0.0.1', 7015).


create_client(Host, Port) :-
	setup_call_catcher_cleanup(tcp_socket(Socket),
                                   tcp_connect(Socket, Host:Port),
                                   exception(_),
                                   tcp_close_socket(Socket)),
        setup_call_cleanup(tcp_open_socket(Socket, In, Out),
                           chat_to_server(In, Out),
                           close_connection(In, Out)).

close_connection(In, Out) :-
        close(In, [force(true)]),
        close(Out, [force(true)]).

chat_to_server(In, _Out) :-
	start_state(State),
	process_perc(In, State).

process_perc(In, _State) :-
	at_end_of_stream(In).
process_perc(In, State) :-
	read(In, Term),!,
	cls,
	process_message(Term, State, NewState),
	process_perc(In, NewState).

cls :-  put(27), put("["), put("2"), put("J"), nl.


