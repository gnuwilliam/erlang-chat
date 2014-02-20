-module(message_router).

-define(SERVER, message_router).

-compile(export_all).

start(PrintFunction) ->
  spawn(message_router, route_messages, [PrintFunction]).

stop(RouterPid) ->
  RouterPid ! shutdown.

send_chat_message(RouterPid, Addressee, MessageBody) ->
  RouterPid ! { send_chat_msg, Addressee, MessageBody }.

route_messages(PrintFunction) ->
  receive
    { send_chat_msg, Addressee, MessageBody } ->
      Addressee ! { receive_chat_msg, MessageBody },
      route_messages(PrintFunction);
    { receive_chat_msg, MessageBody } ->
      PrintFunction(MessageBody);
    shutdown ->
      io:format("Shutting down~n");
    Oops ->
      io:format("Warning! Received ~p~n", [Oops]),
      route_messages(PrintFunction)
  end.
