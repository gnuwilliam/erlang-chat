-module(chat_client).

-compile(export_all).

send_message(RouterPid, Addressee, MessageBody) ->
  RouterPid ! { send_chat_msg, Addressee, MessageBody }.
