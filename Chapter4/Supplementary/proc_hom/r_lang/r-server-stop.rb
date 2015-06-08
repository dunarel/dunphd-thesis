#!/usr/bin/env jruby

require 'rubygems'
require 'rserve'


cmd = "ps aux |grep Rserv"; puts `#{cmd}`

 #connect to Rserve
 c=Rserve::Connection.new
 c.shutdown()
 cmd = `ps aux |grep Rserv`; puts `#{cmd}`


