class MessagesController < ApplicationController
  before_action :set_user,          only: [:index]
  before_action :require_signed_in, only: [:index]

  def new
    @message = Message.new
  end

  #TODO: SPLIT THIS INTO POLICY & SERVICE OBJECTS
  #params: contact_email, current_user,
  ###this needs to decide what kind of message, because it needs to redirect accordingly
  def create
    @unpost  = Unpost.find(params[:unpost_id])
    manager  = MessagesManager.new(unpost_id: params[:unpost_id],
                                       reply: params[:message][:reply])

    manager.send_message( contact_email: message_params[:contact_email],
                            sender_user: current_user,
                        reply_recipient: params[:sender_id],
                                content: message_params[:content])

    if manager.success
      flash[:success]    = manager.flash_message
      redirect_to @unpost
    elsif manager.flash_notice
      flash.now[:notice] = manager.flash_notice
      render 'unposts/show'
    else
      flash.now[:error]  = manager.error_message
      render 'unposts/show'
    end

    #I would like to have access to: success,
    # if params[:unpost_id]

    #                                         }
    #   @safeguest = Safeguest.where(email: message_params[:contact_email]).take if (session[:user_id] == nil)

    #   if signed_in? && current_user.confirmed?
    #     unpost_message_setup
    #     @message.sender = current_user
    #     if @message.save
    #       flash[:success] = "Message Sent!"
    #       redirect_to @unpost
    #     else
    #       flash[:error] = "Message could not be sent. Please fix errors & try again."
    #       render 'unposts/show'
    #     end

    #   elsif signed_in?
    #     flash[:notice] = "Welcome! Please see the email we sent you when you registered - in it there is a link to confirm your account. Then you will be able to contact users on unposts!"
    #     render 'unposts/show'

    #   elsif @safeguest && @safeguest.blacklisted?
    #     flash.now[:notice] = "Your account is currently suspended from use.
    #                           If you believe this to be in error, please contact Unlist."
    #     render 'unposts/show'

    #   elsif @safeguest && @safeguest.confirmed?
    #     unpost_message_setup
    #     if @message.save
    #       flash[:success] = "Message Sent!"
    #       redirect_to @unpost #Where to go after reply sent?
    #     else
    #       flash.now[:error] = "Message could not be sent. Please fix errors & try again."
    #       render 'unposts/show'
    #     end

    #   elsif @safeguest && !@safeguest.confirmed?
    #     if @safeguest.token_expired?
    #       @safeguest.reset_confirmation_token
    #       send_confirmation_email_and_render_instructions
    #     else
    #       flash.now[:notice] = "Please check your email & click the link to confirm that your email is safe.
    #                            Once confirmed safe, then click the 'Send Message' button below again to send this message, and it will be allowed.
    #                            You won't have to confirm your email is safe ever again. Thanks!"
    #       render 'unposts/show'
    #     end
    #     #notify the user to confirm & send another email if token is expired

    #   elsif @safeguest.blank?
    #     @safeguest = Safeguest.new(email: message_params[:contact_email])
    #     if @safeguest.save
    #       send_confirmation_email_and_render_instructions
    #     else
    #       flash[:error] = 'Your email is invalid. Please fix & try again.'
    #       render 'unposts/show'
    #     end
    #   end

    #   #FOR USER MESSAGES & REPLIES
    # elsif params[:sender_id] && params[:message][:reply]
    #   reply_message_setup
    #   if @message.save
    #     flash[:success] = "Message Sent!"
    #     redirect_to user_message_path(current_user, @parent_message) #Where to go after reply sent?
    #   else
    #     flash[:error] = "Message could not be sent. Please fix errors & try again."
    #     render 'new'  #Where to render?
    #   end
    # end
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
        all_messages = current_user.received_messages
        all_messages << current_user.sent_messages
        ###THIS DESERVES A NAMED SCOPE
        @messages = all_messages.select{|m| (m.messageable_type != "Message") } #NOT replies
    end
    render 'index'
  end


  ############################ PRIVATE METHODS #################################
  private
  def message_params
    params.require(:message).permit(:content, :contact_email)
  end

  def guest_is_unconfirmed?
    message_params[:contact_email].present? && !@safeguest.confirmed?
  end

  def send_confirmation_email_and_render_instructions
    UnlistMailer.safeguest_confirmation_email(@safeguest.id).deliver
    flash.now[:notice] = 'You must be on our list of safe-emails to contact Unlist members.
                          Please check your email for a confirmation link to add you to our safe-email list.
                          Then you can re-click this Send Message link & your message will be sent.'
    render 'unposts/show'
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
