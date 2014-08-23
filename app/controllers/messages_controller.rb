class MessagesController < ApplicationController
  before_action :set_user,          only: [:index]
  before_action :require_signed_in, only: [:new_feedback, :index]

  def new
    @message = Message.new
  end

  def new_feedback
    @message = Message.new
  end

  def create
    @message        = Message.new(message_params)
    @unlisting      = Unlisting.find_by(slug: params[:unlisting_id ]) if params[:unlisting_id]
    @parent_message = Message.find(           params[:parent_msg   ]) if params[:parent_msg]

    msg_response    = MessagesManager.new(unlisting_id: params[:unlisting_id ],
                                         parent_msg_id: params[:parent_msg])

    msg_response.send_message( contact_email: message_params[:contact_email],
                            sender_user: current_user,
                        reply_recipient: params[:sender_id],
                                content: message_params[:content])
    destination_by_response(msg_response)
  end

  #maybe 3 actions - received_index & sent_index & hits_index
  #could make OOP with ViewsObject to render correct one in index
  #would take a parameter of request, and return array of correct messages & heading name Index/Sent/Hits

  def index
    ###FIRST THING: MOVE THIS TO MODEL SO IT RETURNS WHAT YOU WANT FOR @message. Set @message that way!
    case params[:type]
      when 'hits'
        @messages = current_user.received_messages.active.select{|m| (m.messageable_type == "Unlisting") } #NOT replies
      when 'received'
        @messages = current_user.received_messages.active.select{|m| (m.messageable_type != "Message") } #NOT replies
      when 'sent'
        @messages = current_user.sent_messages.active.select{|m| (m.messageable_type != "Message") } #NOT replies
      else
        @messages = current_user.all_msgs_sent_received
    end
    render 'index'
  end


  ############################ PRIVATE METHODS #################################
  private
  def message_params
    params[:message][:contact_email].present? ? params.require(:message).permit(:content, :contact_email) :
                                                params.require(:message).permit(:content)
  end

  def render_or_redirect(success, notice_error, msg_response) #success, error msg, message info
    respond_to do |format|
      format.html do
        if msg_response.success
          flash[:success]    = "#{msg_response.flash_success}"
          redirect_to request.referer #:back ####COULD GO TO success VARIABLE HERE IF NEED
        elsif msg_response.flash_notice
          flash.now[:notice] = "#{msg_response.flash_notice}"
          render notice_error
        else
          flash.now[:error]  = "#{msg_response.error_message}"
          render notice_error
        end
      end

      format.js do
        #This replaces the reply form with the reply using Ajax & _reply.js.erb
        if msg_response.success && (msg_response.type == "Reply")
          @message = msg_response.message
          render 'reply'
        else
          render js: "alert(Sorry, I was expecting a reply there, but got something else. Please notify Unlist.it of this message & what you were doing when you got it.);"
        end
      end
    end
  end

  def destination_by_response(msg_response)
    case msg_response.type
      when "Unlisting"
        success       = @unlisting
        notice_error  = 'unlistings/show'
      when "User"
      when "Admin"
        success = user_feedback_path(current_user)
        notice_error = 'messages/new_feedback'
      when "Reply"
        #placeholder destination, but will actually be JS response (see above)
        success       = (@parent_message.messageable_type == "Unlisting" ? Unlisting.find(@parent_message.messageable_id) : unlistings_path(current_user))
        notice_error  = (@parent_message.messageable_type == "Unlisting" ? 'unlistings/index' : 'messages/index')
      else
        success       = Unlisting.find(@parent_message.messageable_id)
        notice_error  = 'unlistings/index'

    end
    render_or_redirect(success, notice_error, msg_response)
  end
end
