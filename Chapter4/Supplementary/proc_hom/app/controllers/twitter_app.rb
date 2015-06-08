#require 'sinatra'

class TwitterApp < Sinatra::Base
  set :root, File.dirname(__FILE__)

 #run Rack::File.new("/root/devel/proc_hom/README")
 
  get '/twitter' do
 #   #@user = 'dunarel'
 #   #t = Twitter::Search.new(@user).fetch
 #   #@tweets = t.results
 #   #erb :twitter
 #   run Rack::File.new("/root/devel/proc_hom/README")
   
   #File.new('/root/devel/proc_hom/README').readlines
    Rack::Directory.new('.')

  end
 
#  get "/prefix" do
#   run Rack::File.new("/root/devel/proc_hom/README")
#  end




end

