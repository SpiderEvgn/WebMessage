# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

实现一个 Web 上的私信系统

功能：

* 用户可以注册、登录。需要 id（可以自己决定 email 或者 username）和 password  --OK
* 用户登录后，进入联系人列表页面                    --OK
- 可以看到自己所有的联系人                         --OK
- 每个联系人需要显示对方 id 以及未读私信数量提醒      ***
- 用户可以通过 id 添加新联系人（可以不需要对方同意）  --OK
- 用户可以删除某个联系人，但保留与对方用户的消息等数据。当再次添加新联系人时，消息等数据都还在
* 点击一个联系人会进入聊天界面，同时未读消息置为 0    --
- 可以看到和某个用户的历史消息                      --
- 能够在这里收发私信（不需要实时，可以刷一下页面才看到新消息）    --OK
- 当用户 A 发私信给用户 B 时，如果 A 还不是 B 的联系人，应该自动把 A 添加为 B 的联系人，并能够在 B 的联系人列表正常显示（不需要实时）
- 用户可以删除自己发的消息

------------------------------------------------------------------------------------------
Model:
User, id, email, username, password, password_confirmation
Contact, user_id, contact_id, created_at
Message, user_id, to_user_id, content, created_at

user has_many contacts
通过 contacts 表关联起一个 user 和他所有的 contacts

user has_many messages
一个 user a 能罗列他所有的联系人，当点击一个联系人 b 的时候通过获取 b.contact_id，这时，检索 a.messages.where(to_user_id: b.id) 和 b.messages.where(to_user_id: a.id) 来获取 a <-> b 的所有聊天记录

Views:
1. 用户注册，登录后，进入 1_联系人列表界面_ （删除，选择）
2. 联系人列表界面可以跳往 2_添加联系人界面_
3. 点击联系人进入 3_聊天界面_  ，显示历史聊天记录，记录可删除


删除 user 会对应删除 所有的 user.contacts，但会保留所有 messages，因为原本的 contact 还能查看历史消息
发信息要确认对方账户是否还存在，不存在则不能发信息，对方联系人把自己账户删除并不会影响你的列表，你依旧能查看历史消息
------------------------------------------------------------------------------------------
加分项：

* 联系人列表页面未读消息数实时更新
* 聊天界面新消息实时接收
* 自动把 A 添加为 B 联系人时，B 实时更新联系人列表
* 部署，可在线演示

提醒：

* 在 README.md 中记录一下设计的思路
* 可以选择任意 Ruby 的 Web Framework
* 为节省时间，用户系统可以考虑使用成熟的 Gem 实现
* 可以参考「流利说」消息中心、「微信」的个人消息或者「知乎」私信

尽量实现所有的功能，我们会根据以下几点进行评价：

* 你完成了多少功能，完成的好不好
* 整个应用的设计、代码质量等方面
* 记住：一个 work 的解决方案比好看但不 work 的解决方案好得多。

提交形式：

完成之后将代码 push 到 GitHub 上，然后邮件告诉我们 Repository 的地址和在线演示的 URL（如果有的话）。

时间要求：

我们对笔试的时间没有强制要求，但希望能在收到你回复确认之后的两天内看到成果或收到开发进度的回复，你可以自己平衡完成的时间和效果。

如果很快就完成了，可以考虑对代码做一些优化或者在页面上添加一些可以改善用户体验的元素；如果时间比较赶，把能完成的做好就可以了。