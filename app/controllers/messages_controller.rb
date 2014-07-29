class MessagesController < ApplicationController
  before_action :set_user,          only: [:index]
  before_action :require_signed_in, only: [:index]

  def new
    @message = Message.new
  end

  def create
    @unpost         = Unpost.find( params[:unpost_id ]) if params[:unpost_id]
    @parent_message = Message.find(params[:parent_msg]) if params[:parent_msg]
    manager         = MessagesManager.new(unpost_id: params[:unpost_id ],
                                      parent_msg_id: params[:parent_msg])

    manager.send_message( contact_email: message_params[:contact_email],
                            sender_user: current_user,
                        reply_recipient: params[:sender_id],
                                content: message_params[:content])
    destination_by_response(manager)
  end

  #maybe 3 actions - received_index & sent_index & hits_index
  #could make OOP with ViewsObject to render correct one in index
  #would take a parameter of request, and return array of correct messages & heading name Index/Sent/Hits
  #TODO: Show only primary messages, displaying replies inside when clicked to show

    #Show replies within message or in a message-show page?
  def index

    ###FIRST THING: MOVE THIS TO MODEL SO IT RETURNS WHAT YOU WANT FOR @message. Set @message that way!
    case params[:type]
      when 'hits'
        @messages = current_user.received_messages.active.select{|m| (m.messageable_type == "Unpost") } #NOT replies
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
    params.require(:message).permit(:content, :contact_email)
  end

  def render_or_redirect(options={}) #success, info, error
    manager      = options[:manager]
    success      = options[:success]
    notice_error = options[:notice_error]

    respond_to do |format|
      format.html do
        if manager.success
          flash[:success]    = "#{manager.flash_success}"
          redirect_to :back ####COULD GO TO success VARIABLE HERE IF NEED
        elsif manager.flash_notice
          flash.now[:notice] = "#{manager.flash_notice}"
          render notice_error
        else
          flash.now[:error]  = "#{manager.error_message}"
          render notice_error
        end
      end

      format.js do
        #This replaces the reply form with the reply using Ajax & _reply.js.erb
        if manager.success && (manager.type == "Reply")
          @message = manager.message
          render 'reply'
        else
          render js: "alert(Sorry, I was expecting a reply there, but got something else. Please notify Unlist.it of this message & what you were doing when you got it.);"
        end
      end
    end
  end

  def destination_by_response(manager)
    case manager.type
      when "Unpost"
        success       = @unpost
        notice_error  = 'unposts/show'
        render_or_redirect({success: success, notice_error: notice_error, manager: manager})
      when "User"
        binding.pry

      when "Reply"
        ###THE SECOND OPTION IS JUST A TEMP GUESS FOR WHERE TO GO AFTER USERS MSG EACHOTHER
        success       = (@parent_message.messageable_type == "Unpost" ? Unpost.find(@parent_message.messageable_id) : unposts_path(current_user))
        ###THE SECOND OPTION IS JUST A TEMP GUESS FOR WHERE TO GO AFTER USERS MSG EACHOTHER
        notice_error  = (@parent_message.messageable_type == "Unpost" ? 'unposts/index' : 'messages/index')
        render_or_redirect({success: success, notice_error: notice_error, manager: manager})
      else
        success       = Unpost.find(@parent_message.messageable_id)
        notice_error  = 'unposts/index'
        render_or_redirect({success: success, notice_error: notice_error, manager: manager})
    end
  end
end
