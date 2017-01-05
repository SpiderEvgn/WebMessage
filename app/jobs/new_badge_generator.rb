module NewBadgeGenerator
  extend ActiveSupport::Concern
  
  private
  
  # 更好的方式是 broadcast 只是传送一个信号，由前端完成对未读消息的自+/-操作，这样就避免了多余的数据库读取和计算
  def render_new_badge(message)
    new_count = message.user.messages.to_user(message.to_user_id).not_read.count
    if new_count == 0
      "<span class='badge' id='badge_#{message.user.id}'>#{new_count}</span>"
    else
      "<span class='badge' id='badge_#{message.user.id}' style='color:red'>#{new_count}</span>"
    end
  end

end