一个 Web 上的私信系统

功能：

* 用户可以注册、登录。需要 id（可以自己决定 email 或者 username）和 passwor
* 用户登录后，进入联系人列表页面                 
- 可以看到自己所有的联系人                      
- 每个联系人需要显示对方 id 以及未读私信数量提醒   
- 用户可以通过 id 添加新联系人（可以不需要对方同意)
- 用户可以删除某个联系人，但保留与对方用户的消息等数据。当再次添加新联系人时，消息等数据都还在 
* 点击一个联系人会进入聊天界面，同时未读消息置为 0 
- 可以看到和某个用户的历史消息                   
- 当用户 A 发私信给用户 B 时，如果 A 还不是 B 的联系人，应该自动把 A 添加为 B 的联系人，并能够在 B 的联系人列表正常显示
- 用户可以删除自己发的消息，同时对方联系人聊天框中对应消息也会同步删除
* 联系人列表页面未读消息数实时更新
* 聊天界面新消息实时接收

---
Model:
User, id, email, username, password, password_confirmation
Contact, user_id, contact_id, updated_at
Message, user_id, to_user_id, content, created_at, is_read

user has_many contacts
通过 contacts 表关联起一个 user 和他所有的 contacts
一条 contact 关系是单向的，一个 user 只知道自己的 contacts 而不知道自己是谁的 contact

user has_many messages
每个 user 只关心自己发出去的信息，当要获取双方聊天记录的时候，取出各自发给对方的信息即可：
一个 user a 点击一个联系人 b 的时候获取 b.id，这时，检索 a.messages.where(to_user_id: b.id) 和 b.messages.where(to_user_id: a.id) 来获取 a <-> b 的所有聊天记录

Views:
1. 用户注册 -> 登录 -> 1_联系人列表界面_ （选择聊天，显示未读消息数，删除联系人）
2. 1_联系人列表界面_ ->添加联系人 -> 2_添加联系人弹出框_
3. 1_联系人列表界面_ ->联系人聊天 -> 3_聊天界面_ (只显示最近 10 条聊天记录，自己的信息可删除)
4. 3_聊天界面_ 按时间排序输出双方聊天记录，每一次新的消息插入到最后，按左右区分信息的所有者
5. 3_聊天界面_ ->历史消息 -> 4_历史消息界面_ （显示所有消息，自己的信息可删除）

---