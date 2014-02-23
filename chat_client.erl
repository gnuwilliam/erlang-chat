-module(chat_client).

-compile(export_all).

send_message(Addressee, MessageBody) ->
    message_router:send_chat_message(Addressee, MessageBody).

print_message(MessageBody) ->
    io:format("Received: ~p~n", [MessageBody]).

start_router() ->
    message_router:start(fun chat_client:print_message/1).
