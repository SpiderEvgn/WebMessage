jQuery(document).on 'turbolinks:load', ->
  message_box = $('#message-box')

  # 当页面出现聊天框时，也就是进入了聊天界面
  if $('#message-box').length > 0

    messages_to_bottom = -> message_box.scrollTop(message_box.prop("scrollHeight"))
    messages_to_bottom()

    App.global_chat = App.cable.subscriptions.create {
        channel: "MessagesChannel"
        chat_user_ids: "#{message_box.data('current-user-id')}-#{message_box.data('contact-user-id')}"
      },
      connected: ->
        # Called when the subscription is ready for use on the server

      disconnected: ->
        # Called when the subscription has been terminated by the server

      received: (data) ->
        if message_box.data('current-user-id') == data['receiver']
          message_box.append data['messageYou']
          # 把新消息置为已读
          $.ajax "/contacts/#{message_box.data('contact-user-id')}/messages/#{data['message_id']}", type: "PATCH"
        else
          message_box.append data['messageMy']

        messages_to_bottom()

      # TODO: 可以直接通过“发送”按钮的 js 实现，因为原本是用remote: true的方式提交 js 请求，这里就先不改了，有空再优化
      # send_message: (message, chat_room_id) ->
        @perform 'send_message', message: message, chat_room_id: chat_room_id