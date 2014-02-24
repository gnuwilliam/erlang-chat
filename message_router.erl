-module(message_router).

-define(SERVER, message_router).

-compile(export_all).

start() ->
    Pid = spawn(message_router, route_messages, [dict:new()]),
    erlang:register(?SERVER, Pid).

stop() ->
    ?SERVER ! shutdown.

send_chat_message(Addressee, MessageBody) ->
    ?SERVER ! { send_chat_msg, Addressee, MessageBody }.

register_nick(ClientName, ClientPid) ->
    ?SERVER ! { register_nick, ClientName, ClientPid }.

unregister_nick(ClientName) ->
    ?SERVER ! { unregister_nick, ClientName }.

route_messages(Clients) ->
    receive
        { send_chat_msg, ClientName, MessageBody } ->
            case dict:find(ClientName, Clients) of
                { ok, ClientPid } ->
                    ClientPid ! { pringmsg, MessageBody };
                error ->
                    io:format("Error! Unknown client: ~p~n", [ClientName])
            end,
            route_messages(Clients);
        { register_nick, ClientName, ClientPid } ->
            route_messages(dict:store(ClientName, ClientPid, Clients));
        { unregister_nick, ClientName } ->
            case dict:find(ClientName, Clients) of
                { ok, ClientPid } ->
                    ClientPid ! stop,
                    route_messages(dict:erase(ClientName, Clients));
                error ->
                    io:format("Error! Unknown client: ~p~n", [ClientName]),
                    route_messages(Clients)
            end;
        shutdown ->
            io:format("Shutting down~n");
        Oops ->
            io:format("Warning! Received: ~p~n", [Oops]),
            route_messages(Clients)
    end.
