require 'rubygems'
require 'rbconfig'

#http://rbjl.net/35-how-to-properly-check-for-your-ruby-interpreter-version-and-os
module OS
  class << self
    def is?(what)
      what === RbConfig::CONFIG['host_os']
    end
    alias is is?

    def to_s
      RbConfig::CONFIG['host_os']
    end
  end

  module_function

  def linux?
    OS.is? /linux|cygwin/
  end

  def mac?
    OS.is? /mac|darwin/
  end

  def bsd?
    OS.is? /bsd/
  end

  def windows?
    OS.is? /mswin|win|mingw/
  end

  def solaris?
    OS.is? /solaris|sunos/
  end

  def posix?
    linux? or mac? or bsd? or solaris? or Process.respond_to?(:fork)
  end

  #def symbian?
    #TODO who knows what symbian returns?
  #end

  # ...
end

module RubyEngine
  class << self
    # try to guess it
    @interpreter = case
    when RUBY_PLATFORM == 'parrot'
      'cardinal'
    when Object.constants.include?( :RUBY_ENGINE ) ||
         Object.constants.include?( 'RUBY_ENGINE'  )
      if RUBY_ENGINE == 'ruby'
        if RUBY_DESCRIPTION =~ /Enterprise/
          'ree'
        else
          'mri'
        end
      else
        RUBY_ENGINE.to_s # jruby, rbx, ironruby, macruby, etc.
      end
    else # probably 1.8
      'mri'
    end

    def is?(what)
      what === @interpreter
    end
    alias is is?

    def to_s
      @interpreter
    end
  end

module_function

  def mri?
    RubyEngine.is? 'mri'
  end
  alias official_ruby? mri?
  alias ruby? mri?

  def jruby?
    RubyEngine.is? 'jruby'
  end
  alias java? jruby?

  def rubinius?
    RubyEngine.is? 'rbx'
  end
  alias rbx? rubinius?

  def ree?
    RubyEngine.is? 'ree'
  end
  alias enterprise? ree?

  def ironruby?
    RubyEngine.is? 'ironruby'
  end
  alias iron_ruby? ironruby?

  def cardinal?
    RubyEngine.is? 'cardinal'
  end
  alias parrot? cardinal?
  alias perl? cardinal?
end

### usage examples
# RubyVersion
### check for the main version with a Float
# RubyVersion.is? 1.8
### use strings for exacter checking
# RubyVersion.is.above '1.8.7'
# RubyVersion.is.at_least '1.8.7' # or below, at_most, not
### you can use the common comparison operators
# RubyVersion >= '1.8.7'
# RubyVersion.is.between? '1.8.6', '1.8.7'
### relase date checks
# RubyVersion.is.older_than Date.today
# RubyVersion.is.newer_than '2009-08-19'
### accessors
# RubyVersion.major # e.g. => 1
# RubyVersion.minor # e.g. => 8
# RubyVersion.tiny  # e.g. => 7
# RubyVersion.patchlevel # e.g. => 249
# RubyVersion.description # e.g. => "ruby 1.8.7 (2010-01-10 patchlevel 249) [i486-linux]"

require 'date'
require 'time'

module RubyVersion
  class << self
    def to_s
      RUBY_VERSION
    end

    # comparable
    def <=>(other)
      value = case other
        when Integer
          RUBY_VERSION.to_i
        when Float
          RUBY_VERSION.to_f
        when String
          RUBY_VERSION
        when Date,Time
          other.class.parse(RUBY_RELEASE_DATE)
        else 
          other = other.to_s
          RUBY_VERSION
        end  
      value <=> other
    end  
    include Comparable

    # chaining for dsl-like language
    def is?(other = nil)
      if other
        RubyVersion == other
      else
        RubyVersion
      end
    end
    alias is is?

    # aliases
    alias below     <
    alias below?    <
    alias at_most   <=
    alias at_most?  <=
    alias above     >
    alias above?    >
    alias at_least  >=
    alias at_least? >=
    alias exactly   ==
    alias exactly?  ==
    def not(other)
      self != other
    end
    alias not?     not
    alias between between?

    # compare dates
    def newer_than(other)
      if other.is_a? Date or other.is_a? Time
        RubyVersion > other
      else
        RUBY_RELEASE_DATE > other.to_s
      end
    end
    alias newer_than? newer_than

    def older_than(other)
      if other.is_a? Date or other.is_a? Time
        RubyVersion < other
      else
        RUBY_RELEASE_DATE < other.to_s
      end
    end
    alias older_than? older_than

    def released_today
      RubyVersion.date == Date.today
    end
    alias released_today? released_today

    # accessors

    def major
      RUBY_VERSION.to_i
    end
    alias main major

    def minor
      RUBY_VERSION.split('.')[1].to_i
    end
    alias mini minor

    def tiny
      RUBY_VERSION.split('.')[2].to_i
    end
    
    alias teeny tiny

    def patchlevel
      RUBY_PATCHLEVEL
    end

    def platform
      RUBY_PLATFORM
    end

    def release_date
      Date.parse RUBY_RELEASE_DATE
    end
    alias date release_date

    def description
      RUBY_DESCRIPTION
    end
  end
end

