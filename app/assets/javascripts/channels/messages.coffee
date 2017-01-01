jQuery(document).on 'turbolinks:load', ->
  messages = $('#message-box')
  if $('#message-box').length > 0
    messages_to_bottom = -> messages.scrollTop(messages.prop("scrollHeight"))

    messages_to_bottom()

    App.global_chat = App.cable.subscriptions.create {
        channel: "MessagesChannel"
        chat_room_id: "room001"
        # chat_room_id: messages.data('chat-room-id')
      },
      connected: ->
        # Called when the subscription is ready for use on the server

      disconnected: ->
        # Called when the subscription has been terminated by the server

      received: (data) ->
        messages.append data['message']
        messages_to_bottom()
        # alert(data['message'])


      # send_message: (message, chat_room_id) ->
        @perform 'send_message', message: message, chat_room_id: chat_room_id