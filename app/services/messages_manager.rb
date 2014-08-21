class MessagesManager
  attr_reader :user, :safeguest, :success, :type, :sender_type, :sender_status, :error_message, :flash_success, :flash_notice, :message
  def initialize(options={}) #receives unlisting_id & reply
    @unlisting_id     = options[:unlisting_id]
    @parent_msg_id = options[:parent_msg_id]
  end


  def send_message(options={}) #receives contact_email, sender_user, reply_recipient
    @contact_email = options[:contact_email]
    @content       = options[:content]
    @sender_user   = options[:sender_user]

    ###### UNLISTING MESSAGES ######
    if unlisting_message?
      @type    = "Unlisting"

      if from_user?(@sender_user) #if from a user
        @sender_type = "User"

        if user_message_allowed? #check if user can send message

          unless unlisting_message_setup(@content) == false #finds unpose & sets message values. Makes @message & @unlisting
            @message.sender = @sender_user #sets the message sender to current user

            if @message.save #try to save message or return an alert
              @flash_success = "Message Sent!"
              @success       = true #Success. Could return the message? Need to redirect to @unlisting.
            else
              @error_message = "Message could not be sent. Please fix errors & try again."
              @success       = false
            end
          end

        else #if user is restricted from messaging
          if !@sender_user.confirmed?
            @flash_notice = "Welcome! Please see the email we sent you when you
                            registered - in it there is a link to confirm your account.
                           Then you will be able to contact users on unlistings!"
            @success      = false
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
          @flash_notice = "Your account is currently suspended from use.
                           If you believe this to be in error, please contact Unlist."
          @success       = false

        elsif @safeguest && safeguest_message_allowed? #if allowed to message
          unless unlisting_message_setup(@content, @contact_email) == false #finds unlisting & sets message values. Makes @message & @unlisting
            @message.sender = @user #sets the message sender to safeguest

            if @message.save #try to save message or return an alert
              @flash_success = "Message Sent!"
              @success       = true #Success. Could return the message? Need to redirect to @unlisting.
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
            @flash_notice = "Please check your email & click the link to confirm that your email is safe.
                             Once confirmed safe, then click the 'Send Message' button below again to send this message, and it will be allowed.
                            You won't have to confirm your email is safe ever again. Thanks!"
            @success      = false
          end
        end
      end


    ###### MESSAGE REPLIES ######
    elsif reply_message?
      @type = "Reply"
      if user_message_allowed? #check if user can send message
        unless reply_message_setup(@content) == false #finds unlisting & sets message values. Makes @message & @unlisting

          if @message.save #try to save message or return an alert
            @flash_success = "Reply Sent!"
            @success       = true #Success. Could return the message? Need to redirect to @unlisting.
          else
            @error_message = "Reply could not be sent. Please fix errors & try again."
            @success       = false
          end
        end

      else #if user is restricted from messaging
        if !@sender_user.confirmed?
          @flash_notice = "Something seems fishy about how you're replying to
                          an unlisting message without having been prior confirmed...
                          but anyhoo, please visit the inbox of the email account
                          you have on record with us to confirm your Unlist.it account."
          @success      = false
        # elsif @user.blacklisted? #this should be added to user & in the user policy.
        #   @error_message = "Your account is currently suspended from use.
        #                     If you believe this to be in error, please contact Unlist."
        #   @success       = false
        end
      end


    else #Admin Message.
      @type = "Admin"
      unless admin_message_setup(@content) == false #finds admin & sets message values. Makes @message
        if @message.save
          @flash_success = "Feedback Sent!"
          @success = true
        else
          @error_message = "Feedback could not be sent. Please fix the errors noted and try submitting again."
          @success = false
        end
      end
    end
  end

  ################################# SUPPORT METHODS ############################

  # DETERMINE MESSAGE TYPE
  def unlisting_message?
    @unlisting_id.present? && !@reply
  end

  def reply_message?
    @parent_msg_id.present?
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
    @user_message_allowed ||= UserPolicy.new(user: @sender_user).messages_allowed?
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

  #SETTING UP MESSAGES
  def unlisting_message_setup(content, contact_email=nil)
    @message = Message.new(content: content, contact_email: contact_email)
    @unlisting  = Unlisting.find(@unlisting_id)
    if @unlisting
      @message.subject     = "RE: " + @unlisting.title
      @message.recipient   = @unlisting.creator
      @message.messageable = @unlisting
    else
      @error_message = "Unlisting could not be found."
      @success       = false
    end
  end

  def reply_message_setup(content)
    parent_message = Message.find(@parent_msg_id)
    if parent_message
      @message = parent_message.messages.build(content: content)
      @message.subject     = parent_message.subject
      @message.messageable = parent_message #sets messageable_type to "Message"; sets messageable_id
      @message.recipient   = ((@sender_user == parent_message.recipient) ? parent_message.sender : parent_message.recipient)
      @message.subject     = parent_message.subject
      @message.sender      = @sender_user #sets the message sender to current user
    else
      @error_message = "Sorry, we couldn't find the message you were replying to."
      @success       = false
    end
  end

  def admin_message_setup(content)
    admin = User.where(role: "admin").take
    if admin
      @message = Message.new(content: content,
                           recipient: admin,
                              sender: @sender_user,
                             subject: "Feedback from #{@sender_user.username}",
                         messageable: admin) #this is really just a User type
    else
      @error_message = "Argh, something went terribly wrong & this message couldn't be sent!
                        Please email us instead at admin@unlist.it -- we really want to hear what you have to say!"
      @success       = false
    end
  end

  #TAKING ACTION
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
    #UnlistMailer.safeguest_confirmation_email(@safeguest.id).deliver
    UnlistMailer.delay.safeguest_confirmation_email(@safeguest.id)
    @flash_notice = 'You must be on our list of safe-emails to contact Unlist members.
                     Please check your email for a confirmation link to add you to our safe-email list.
                     Then you can re-click this Send Message link & your message will be sent.'
    @success      = false
  end
end


