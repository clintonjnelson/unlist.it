class MessagesController < ApplicationController
  before_action :set_user,          only: [:index]
  before_action :require_signed_in, only: [:index]

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    if params[:unpost_id] #FOR UNPOST MESSAGES (VIA GUEST & USER)
      if guest_user?
        unpost_message_setup
      elsif signed_in?
        unpost_message_setup
        @message.sender = current_user
      end

      if @message.save
        flash[:success] = "Message Sent!"
        redirect_to @unpost #Where to go after reply sent?
      else
        flash[:error] = "Message could not be sent. Please fix errors & try again."
        render 'unposts/show'
      end
    elsif params[:sender_id] && params[:message][:reply] #FOR USER MESSAGES & REPLIES
      reply_message_setup
      if @message.save
        flash[:success] = "Message Sent!"
        redirect_to user_message_path(current_user, @parent_message) #Where to go after reply sent?
      else
        flash[:error] = "Message could not be sent. Please fix errors & try again."
        render 'new'  #Where to render?
      end
    end
  end

  #maybe 3 actions - received_index & sent_index & hits_index
  #could make OOP with ViewsObject to render correct one in index
  #would take a parameter of request, and return array of correct messages & heading name Index/Sent/Hits
  #TODO: Show only primary messages, displaying replies inside when clicked to show
    #Show replies within message or in a message-show page?
  def index
    case params[:type]
      when 'hits'
        @messages = current_user.received_messages.select{|m| (m.messageable_type == "Unpost") } #NOT replies
      when 'received'
        @messages = current_user.received_messages.select{|m| (m.messageable_type != "Message") } #NOT replies
      when 'sent'
        @messages = current_user.sent_messages.select{|m| (m.messageable_type != "Message") } #NOT replies
      else
        all_messages = current_user.sent_messages
        all_messages << current_user.received_messages
        @messages = all_messages.select{|m| (m.messageable_type != "Message") } #NOT replies
    end
    render 'index'
  end


  ############################ PRIVATE METHODS #################################
  private
  def message_params
    params.require(:message).permit(:content, :contact_email)
  end

  def unpost_user_message_setup

  end

  def reply_message_setup
    @parent_message = Message.find(params[:message_id])
    if @parent_message
      @message.messageable = @parent_message
      #MAKE SURE THIS AS INTENDED. COULD JUST ASSOCIATE WITH FIRST MESSAGE INSTEAD OF USERS EACH TIME...
      #BUT MAYBE THE EXTRA INFO IS USEFUL.
      @message.recipient = ((current_user == @parent_message.recipient) ? @parent_message.sender : @parent_message.recipient)
      @message.subject = @parent_message.subject
      @message.sender = current_user
    end
  end

  #SET THESE IN THE MODEL OR SERVICE, NOT THE CONTROLLER
  def unpost_message_setup
    @unpost = Unpost.find(params[:unpost_id])
    if @unpost
      @message.subject = "RE: " + @unpost.title
      @message.recipient = @unpost.creator
      @message.messageable = @unpost
    else
      render 'public/500'
    end
  end
end
