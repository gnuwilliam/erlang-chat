-module(chat_client).

-compile(export_all).

send_message(RouterPid, Addressee, MessageBody) ->
  message_router:send_chat_message(RouterPid, Addressee, MessageBody).

print_message(MessageBody) ->
  io:format("Received: ~p~n", [MessageBody]).

