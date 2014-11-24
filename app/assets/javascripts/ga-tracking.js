/////THIS SHOULD BE A GENERIC JQUERY FUNCTION

$(document).ready( function(){
  //Tracking the SignUp Button
  $('#signup-button').on('click', function() {
    ga('send', 'event', 'button', 'click', 'signup');
  });

  //Tracking the Register Link
  $('#register-link').on('click', function() {
    ga('send', 'event', 'link', 'click', 'register');
  });

  //Tracking Added Unlistings
  $('#addunlisting-button').on('click', function(){
    ga('send', 'event', 'button', 'click', 'addunlisting');
  });

  //Tracking Added Friends
  $('#addfriend-link').on('click', function(){
    ga('send', 'event', 'link', 'click', 'addfriend');
  });
});
