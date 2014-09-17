class Admin::MessagesController < AdminController

  def index
    ###FIRST THING: MOVE THIS TO MODEL SO IT RETURNS WHAT YOU WANT FOR @message. Set @message that way!
    case params[:type]
      when 'contact'
        @messages = current_user.received_messages.active.where("msg_type = 'Contact'").paginate(page: params[:page])
      when 'feedback'
        @messages = current_user.received_messages.active.where("msg_type = 'Feedback'").paginate(page: params[:page])
      when 'hits'
        @messages = current_user.received_messages.active.where("messageable_type = 'Unlisting'").paginate(page: params[:page]) #NOT replies
      when 'joined'
        @messages = current_user.sent_messages.active.where("msg_type = 'Join'").paginate(page: params[:page])
      when 'received'
        @messages = current_user.received_messages.active.where.not("messageable_type = 'Message'").paginate(page: params[:page]) #NOT replies
      when 'sent'
        @messages = current_user.sent_messages.active.where.not("messageable_type = 'Message'").paginate(page: params[:page]) #NOT replies
      else
        @messages = current_user.all_msgs_sent_received.paginate(page: params[:page])
    end

    respond_to do |format|
      format.any(:html, :js) { render 'messages/index' }
    end
  end
end
