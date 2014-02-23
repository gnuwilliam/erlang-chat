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

register_nickname(ClientName, PrintFunction) ->
    ?SERVER ! { register_nickname, ClientName, PrintFunction }.

unregister_nickname(ClientName) ->
    ?SERVER ! { unregister_nickname, ClientName }.

route_messages(Clients) ->
    receive
        { send_chat_msg, ClientName, MessageBody } ->
            ?SERVER ! { receive_chat_msg, ClientName, MessageBody },
            route_messages(Clients);
        { receive_chat_msg, ClientName, MessageBody } ->
            case dict:find(ClientName, Clients) of
                { ok, PrintFunction } ->
                    PrintFunction(MessageBody);
                error ->
                    io:format("Unknown client~n")
            end,
            route_messages(Clients);
        { register_nickname, ClientName, PrintFunction } ->
            route_messages(dict:store(ClientName, PrintFunction, Clients));
        { unregister_nickname, ClientName } ->
            route_messages(dict:erase(ClientName, Clients));
        shutdown ->
            io:format("Shutting down~n");
        Oops ->
            io:format("Warning! Received ~p~n", [Oops]),
            route_messages(Clients)
    end.
