#
require('rubygems')

module Twitpic; end

def require_local(suffix)
  require(File.expand_path(File.join(File.dirname(__FILE__), suffix)))
end

# For better unicode support in 1.8
if RUBY_VERSION < '1.9'
  $KCODE = 'u'
  require 'jcode'
end

# External requires
#require('any-lib')

# Internal requires
require_local('twitpic/twitpic')
require_local('twitpic/helper')
require_local('twitpic/oauth')
require_local('twitpic/base')
