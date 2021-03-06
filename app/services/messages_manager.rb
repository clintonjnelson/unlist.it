class MessagesManager
  attr_reader :user, :safeguest, :success, :type, :sender_type, :sender_status, :error_message, :flash_success, :flash_notice, :message
  def initialize(options={}) #receives reply & unlisting_slug
    @unlisting_slug  = options[:unlisting_slug] #indicates an UNLISTING MSG
    @parent_msg_id   = options[:parent_msg_id ] #indicates a REPLY MSG
  end


  def send_message(options={}) #receives contact_email, sender_user, reply_recipient
    @contact_email = options[:contact_email]
    @content       = options[:content]
    @recaptcha     = options[:recaptcha]
    @sender_user   = options[:sender_user]
    @contact_msg   = options[:contact_msg]

    ###### UNLISTING MESSAGES ######
    if unlisting_message?
      @type        = "Unlisting"
      @unlisting   = Unlisting.find_by(slug: @unlisting_slug)

      if from_user?(@sender_user) #if from a user
        @sender_type = "User"

        if user_message_allowed? #check if user can send message

          unless unlisting_message_setup(@content) == false #finds unpose & sets message values. Makes @message & @unlisting
            @message.sender = @sender_user #sets the message sender to current user

            if @message.save #try to save message or return an alert
              @flash_success = "Message Sent!"
              hit_notification_email(@unlisting, @sender_type)
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
        @safeguest   = Safeguest.where(email: @contact_email).take
        @sender_type = "Safeguest"

        if @safeguest.blank? #if email not on list
          invite_new_safeguest(@contact_email) #invite guest

        elsif @safeguest && @safeguest.blacklisted? #if has been blacklisted
          @flash_notice = "Your account is currently suspended from use.
                           If you believe this to be in error, please contact Unlist."
          @success      = false

        elsif @safeguest && creator_restricts_safeguests?
          @flash_notice = "Sorry, the creator of this unlist only allows contact by other Unlist.it users."
          @success      = false

        elsif @safeguest && safeguest_message_allowed? #if allowed to message
          unless unlisting_message_setup(@content, @contact_email) == false #finds unlisting & sets message values. Makes @message & @unlisting
            @message.sender  = nil #sets the message sender to safeguest

            if @message.save #try to save message or return an alert
              @flash_success = "Message Sent!"
              hit_notification_email(@unlisting, @sender_type)
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
      @type        = "Reply"
      @sender_type = "User" if from_user?(@sender_user)

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

      else #if user is restricted from messaging or is not a user
        if !from_user?(@sender_user) || !@sender_user.confirmed?
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


    ###### OUTSIDER CONTACT ######
    elsif from_outsider? && @sender_user.blank?
      @type = "Contact"
      unless contact_message_setup(@content) == false
        if @recaptcha && @message.save
          @flash_success = "Message sent!"
          @success       = true
        else
          @error_message = "Oops - contact message could not be sent. Please fix the errors below & try again."
          @success       = false
        end
      end


    ###### FEEDBACK MESSAGE TO ADMIN ######
    else
      @type        = "Feedback"
      @sender_type = "User" if @sender_user

      unless feedback_message_setup(@content) == false #finds admin & sets message values. Makes @message
        if @message.save
          @flash_success = "Feedback Sent!"
          @success       = true
        else
          @error_message = "Feedback could not be sent. Please fix the errors noted and try submitting again."
          @success       = false
        end
      end
    end
  end

  ################################# SUPPORT METHODS ############################

  # DETERMINE MESSAGE TYPE
  def unlisting_message?
    @unlisting_slug.present? && !@reply
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

  def from_outsider?
    @contact_msg == "true" ? true : false
  end

  #PERMISSIONS
  def creator_restricts_safeguests?
    value = UserPolicy.new(user: @unlisting.creator).safeguest_contact_allowed?
    !value
  end

  def user_message_allowed?
    @user_message_allowed ||= UserPolicy.new(user: @sender_user).messages_allowed?
    # False should pass back an error with message for flash
  end

  #CHANGE THE NAME OF THIS ONE TO CLARIFY IT FROM USERS ALLOWING SAFEGUEST MESSAGES.
  def safeguest_message_allowed?
    @safeguest_message_allowed ||= UserPolicy.new(safeguest: @safeguest).messages_allowed?
    # False should pass back an error with message for flash
  end

  def guest_is_unconfirmed?
    message_params[:contact_email].present? && !@safeguest.confirmed?
  end

  def hit_notifications_allowed?(creator)
    UserPolicy.new(user: creator).hit_notifications_on?
  end

  #RETURN VALUE METHODS
  def successful?
    @success
  end

  #SETTING UP MESSAGES
  def contact_message_setup(content)
    admin = User.where(role: "admin").take
    if admin && @contact_email
      @message = Message.new(content: content,
                           recipient: admin,
                       contact_email: @contact_email,
                             subject: "Contact from #{@contact_email}",
                            msg_type: @type,
                         messageable: admin) #User type with admin's id
    else
      @error_message = "Contact message could not be sent. Please provide a valid contact email."
      @success       =  false
    end
  end

  def feedback_message_setup(content)
    admin = User.where(role: "admin").take
    if admin && @sender_user
      @message = Message.new(content: content,
                           recipient: admin,
                              sender: @sender_user,
                             subject: "Feedback from #{@sender_user.username}",
                            msg_type: @type,
                         messageable: admin) #User type with admin's id
    else
      @error_message = "Argh, something went terribly wrong & this message couldn't be sent!
                        Feel free to signout and contact us through our contact page."
      @success       = false
    end
  end

  def reply_message_setup(content)
    parent_message = Message.find(@parent_msg_id)
    if parent_message
      @message = parent_message.messages.build(content: content,
                                               subject: parent_message.subject,
                                           messageable: parent_message, #sets messageable_type to "Message"; sets messageable_id
                                             recipient: ((@sender_user == parent_message.recipient) ? parent_message.sender : parent_message.recipient),
                                                sender: @sender_user,   #sets the message sender to current user
                                               subject: parent_message.subject,
                                              msg_type: @type)
      # @message.subject     = parent_message.subject
      # @message.messageable = parent_message
      # @message.recipient   = ((@sender_user == parent_message.recipient) ? parent_message.sender : parent_message.recipient)
      # @message.subject     = parent_message.subject
      # @message.sender      = @sender_user
    else
      @error_message = "Sorry, we couldn't find the message you were replying to."
      @success       = false
    end
  end

  def unlisting_message_setup(content, contact_email=nil)
    @message = Message.new(content: content, contact_email: contact_email)
    #@unlisting   = Unlisting.find_by(slug: @unlisting_slug)
    if @unlisting
      @message.subject     = "RE: " + @unlisting.title
      @message.recipient   = @unlisting.creator
      @message.messageable = @unlisting
    else
      @error_message = "Unlisting could not be found."
      @success       = false
    end
  end

  def hit_notification_email(unlisting, type)
    #UnlistMailer.delay.hit_notification_email(unlisting.id, type) if hit_notifications_allowed?(unlisting.creator)
    UnlistMailer.hit_notification_email(unlisting.id, type).deliver if hit_notifications_allowed?(unlisting.creator)
  end

  #INVITE USER TO UNLIST OR PROMPT TO FIX ERRORS
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


