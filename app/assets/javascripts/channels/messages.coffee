jQuery(document).on 'turbolinks:load', ->
  messages = $('#message-box')
  chat_room = $('#chat-room')

  if $('#message-box').length > 0
    messages_to_bottom = -> messages.scrollTop(messages.prop("scrollHeight"))

    messages_to_bottom()

    App.global_chat = App.cable.subscriptions.create {
        channel: "MessagesChannel"
        chat_user_ids: messages.data('chat-user-ids')
      },
      connected: ->
        # Called when the subscription is ready for use on the server

      disconnected: ->
        # Called when the subscription has been terminated by the server

      received: (data) ->
        if chat_room.data('current-user-id') == data['receiver']
          messages.append data['messageYou']
        else
          messages.append data['messageMy']

        messages_to_bottom()


      # send_message: (message, chat_room_id) ->
        @perform 'send_message', message: message, chat_room_id: chat_room_id