require 'sinatra'
require 'twilio-ruby'

# A hack around multiple routes in Sinatra
def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

# Home page and reference
get '/' do
  @title = "Home"
  erb :home
end

# Voice Request URL
get_or_post '/voice/?' do
  response = Twilio::TwiML::Response.new do |r|
    r.Gather timeout='10';
    r.Say ".Hello, I am Ryan's phone robot.  How may I help you?", :voice => 'man';
  end
  response.text
end

# SMS Request URL
get_or_post '/sms/?' do
  response = Twilio::TwiML::Response.new do |r|
    r.Sms 'Congratulations! You\'ve successfully deployed ' \
          'the Twilio HackPack for Heroku and Sinatra!'
  end
  response.text
end

# Twilio Client URL
get_or_post '/client/?' do
  TWILIO_ACCOUNT_SID = ENV['TWILIO_ACCOUNT_SID'] || TWILIO_ACCOUNT_SID
  TWILIO_AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN'] || TWILIO_AUTH_TOKEN
  TWILIO_APP_SID = ENV['TWILIO_APP_SID'] || TWILIO_APP_SID
  
  if !(TWILIO_ACCOUNT_SID && TWILIO_AUTH_TOKEN && TWILIO_APP_SID)
    return "Please run configure.rb before trying to do this!"
  end
  @title = "Twilio Client"
  capability = Twilio::Util::Capability.new(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
  capability.allow_client_outgoing(TWILIO_APP_SID)
  capability.allow_client_incoming('twilioRubyHackpack')
  @token = capability.generate
  erb :client
end