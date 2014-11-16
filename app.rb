# encoding: utf-8
require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra'
require 'sinatra/r18n'
require 'sinatra/flash'
require 'redcarpet'
require 'json'
require 'rss'
require 'i18n'

require File.join(File.dirname(__FILE__),'lib/twitter_card')
require File.join(File.dirname(__FILE__),'lib/facebook_open_graph')

helpers do
  
  def t(key, ops = Hash.new)
    ops.merge!(:locale => session[:locale])
    I18n.t key, ops
  end
  
end

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
  
  I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'locales', '*.yml').to_s]
  
  enable :sessions
end

before do
  if request.path.length < 3 || request.path[3] != "/" 
    redirect "http://" + request.host + ( request.port==80 ? "" : ":#{request.port}") + "/es" + request.path, 301
  end
end

before '/:locale/*' do
    
  locale = params[:locale]
  
  if locale == "es" || locale == "en"
    session[:locale] = locale
    request.path_info = '/' + params[:splat][0]
    
      @twitter_card = TwitterCard.new
      @twitter_card.card_type = "summary"
      @twitter_card.site = "@martinalaimo"
      @twitter_card.creator = "@martinalaimo"
      @twitter_card.image_url = "http://scrum.coachingretreat.la/assets/img/retreat/social.jpg"

      @facebook_og = FacebookOpenGraph.new
      @facebook_og.site_name = ""
      @facebook_og.og_type = "blog"
      @facebook_og.image = @twitter_card.image_url

#      @active_section = ""
      flash.sweep 
  end
end

get '/' do
    
#  @active_section = "index"

  @twitter_card.title = "Scrum Coaching Retreat Latin America 2015 - Buenos Aires"
  @twitter_card.description = t "about.text"
  
  @facebook_og.title = @twitter_card.title
  @facebook_og.description = @twitter_card.description
  
  erb :index
  
end