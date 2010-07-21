require 'twitpic4r'

API_KEY = 'API KEY for your twitpic application'
CONSUMER_KEY = 'Consumer Key for your twitter application'
CONSUMER_SECRET = 'Consumer Secret for your twitter application'
ACCESS_TOKEN = 'Access Token for a twitter account with which you use application'
ACCESS_TOKEN_SECRET = 'Access Token for a twitter account with which you use application'

# WARNING: 
# Twitpic API v2 does not update twitter status.
# To post message to twitter, you should call twitter API in addition.
oauth = Twitpic::OAuth.new(CONSUMER_KEY, CONSUMER_SECRET)
oauth.authorize(ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
client = Twitpic::Base.new(API_KEY, oauth)
p client.upload('./test.jpg','message..')