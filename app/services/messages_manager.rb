class MessagesManager
  attr_reader :user, :safeguest, :success, :message_type, :sender_type, :sender_status, :error_message, :flash_message, :flash_notice
  def initialize(options={}) #receives unpost_id & reply
    @unpost_id     = options[:unpost_id]
    @reply         = options[:reply]
    # @user           = options[:user]
    # @safeguest      = options[:safeguest]
    # @success        = options[:success]
    # @message_type   = options[:message_type]
    # @sender_type    = options[:sender_type]
    # @sender_status  = options[:sender_status]
    # @error_message  = options[:error_message]
    # @flash_message  = options[:flash_message]
    # @flash_notice   = options[:flash_notice]
  end


  def send_message(options={}) #receives contact_email, sender_user, reply_recipient
    @contact_email = options[:contact_email]
    @content       = options[:content]
    @sender_user   = options[:current_user]
    #@reply_recipient

    if unpost_message?
      @type    = "Unpost"

      if from_user?(@sender_user) #if from a user
        @sender_type = "User"
        @user        = sender_user #get the user

        if user_message_allowed? #check if user can send message
          unless unpost_message_setup(@content) == false #finds unpose & sets message values. Makes @message & @unpost
            @message.sender = @user #sets the message sender to current user

            if @message.save? #try to save message or return an alert
              @flash_message = "Message Sent!"
              @success       = true #Success. Could return the message? Need to redirect to @unpost.
            else
              @error_message = "Message could not be sent. Please fix errors & try again."
              @success       = false
            end
          end

        else #user is restricted from messaging
          if !@user.confirmed?
            @error_message = "Welcome! Please see the email we sent you when you
                             registered - in it there is a link to confirm your account.
                             Then you will be able to contact users on unposts!"
            @success       = false
          # elsif @user.blacklisted? #this should be added to user & in the user policy.
          #   @error_message = "Your account is currently suspended from use.
          #                     If you believe this to be in error, please contact Unlist."
          #   @success       = false
          end
        end

      elsif from_guest?(@contact_email) #if from a guest
        @safeguest = Safeguest.where(email: @contact_email).take
        if @safeguest.blank? #if email not on list
          invite_new_safeguest(@contact_email) #invite guest

        elsif @safeguest && @safeguest.blacklisted? #if has been blacklisted
          @flash_message = "Your account is currently suspended from use.
                           If you believe this to be in error, please contact Unlist."
          @success       = false

        elsif @safeguest && safeguest_message_allowed? #if allowed to message
          unless unpost_message_setup(@content, @contact_email) == false #finds unpost & sets message values. Makes @message & @unpost
            @message.sender = @user #sets the message sender to safeguest

            if @message.save? #try to save message or return an alert
              @flash_message = "Message Sent!"
              @success       = true #Success. Could return the message? Need to redirect to @unpost.
            else
              @error_message = "Message could not be sent. Please fix errors & try again."
              @success       = false
            end
          end
        elsif @safeguest && !@safeguest.confirmed? #if hasn't confirmed account
          if @safeguest.token_expired? #if confirmation expired
            @safeguest.reset_confirmation_token
            send_confirmation_email_and_render_instructions
          else #if confirmation token still valid
            @error_message = "Please check your email & click the link to confirm that your email is safe.
                              Once confirmed safe, then click the 'Send Message' button below again to send this message, and it will be allowed.
                              You won't have to confirm your email is safe ever again. Thanks!"
            @success       = false
          end
        end
      end
    elsif reply_message?
      #@type = "Reply"
      #send reply message
    end
  end




  # DETERMINE MESSAGE TYPE
  def unpost_message?
    @unpost_id.present? && !@reply
  end

  def reply_message?
    @reply.present?
  end

  # DETERMINE USER TYPE
  def from_user?(sender_user)
    sender_user.present?
  end

  def from_guest?(contact_email)
    contact_email.present?
  end

  #PERMISSIONS
  def user_message_allowed?
    @user_message_allowed ||= UserPolicy.new(user: @user).messages_allowed?
    # False should pass back an error with message for flash
  end

  def safeguest_message_allowed?
    @safeguest_message_allowed ||= UserPolicy.new(safeguest: @safeguest).messages_allowed?
    # False should pass back an error with message for flash
  end

  def guest_is_unconfirmed?
    message_params[:contact_email].present? && !@safeguest.confirmed?
  end


  #RETURN VALUE METHODS
  def successful?
    @success
  end

  #METHODS TO DO STUFF
  def unpost_message_setup(content, contact_email=nil)
    @message = Message.new(content: content, contact_email: contact_email)
    @unpost  = Unpost.find(params[:unpost_id])
    if @unpost
      @message.subject = "RE: " + @unpost.title
      @message.recipient = @unpost.creator
      @message.messageable = @unpost
    else
      @error_message = "Unpost could not be found."
      @success       = false
    end
  end

  def invite_new_safeguest(contact_email)
    @safeguest = Safeguest.new(email: contact_email)
    if @safeguest.save
      send_confirmation_email_and_render_instructions
    else
      @error_message = 'Your email is invalid. Please fix & try again.'
      @success       = false
    end
  end

  def send_confirmation_email_and_render_instructions
    UnlistMailer.safeguest_confirmation_email(@safeguest.id).deliver
    @flash_notice = 'You must be on our list of safe-emails to contact Unlist members.
                     Please check your email for a confirmation link to add you to our safe-email list.
                     Then you can re-click this Send Message link & your message will be sent.'
    @success      = false
  end
end




  # def reply_message_setup
  #   @parent_message = Message.find(params[:message_id])
  #   if @parent_message
  #     @message.messageable = @parent_message
  #     #MAKE SURE THIS AS INTENDED. COULD JUST ASSOCIATE WITH FIRST MESSAGE INSTEAD OF USERS EACH TIME...
  #     #BUT MAYBE THE EXTRA INFO IS USEFUL.
  #     @message.recipient = ((current_user == @parent_message.recipient) ? @parent_message.sender : @parent_message.recipient)
  #     @message.subject = @parent_message.subject
  #     @message.sender = current_user
  #   end
  # end
