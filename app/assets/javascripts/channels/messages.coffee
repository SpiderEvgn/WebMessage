jQuery(document).on 'turbolinks:load', ->
  
  # 当页面出现聊天框时，即进入了聊天界面
  if $('#message-box').length > 0
    message_box = $('#message-box')

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

        $('#message_content').val("");
        messages_to_bottom()

      # TODO: 可以直接通过“发送”按钮的 js 实现，因为原本是用remote: true的方式提交 js 请求，这里就先不改了，有空再优化
      # send_message: (message, chat_room_id) ->
        @perform 'send_message', message: message, chat_room_id: chat_room_id

  # 当页面出现联系人列表时，即进入了聊天界面
  if $('#contacts_list').length > 0
    contacts_list = $('#contacts_list')

    App.global_chat = App.cable.subscriptions.create {
        channel: "ContactsChannel"
        current_user_id: contacts_list.data('current-user-id')
      },
      connected: ->
        # Called when the subscription is ready for use on the server

      disconnected: ->
        # Called when the subscription has been terminated by the server

      received: (data) ->
        # 已经是联系人的话就更新未读数；否则就更新联系人列表添加联系人
        if data['new_contact'] == "is_contact"
          $("#badge_#{data['contact_id']}").replaceWith(data['new_badge'])
        else
          contacts_list.append data['new_contact']






