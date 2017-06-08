require 'sinatra'
require 'pg'

load './local_env.rb' if File.exist?('./local_env.rb')

def db()
  db_params = {
    host: ENV['host'],
    port: ENV['port'],
    dbname: ENV['dbname'],
    user: ENV['user'],
    password: ENV['password']
  }
  PG::Connection.new(db_params)
end

get '/'do
    erb :index
end

get '/contact'do
    erb :contact
end

get '/about'do
    erb :about
end

get '/services'do
    erb :services
end

get '/pricing'do
    erb :pricing
end

get '/faq'do
    erb :faq
end

get'/bloghome1'do
    erb :bloghome1
end

get '/bloghome2'do
    erb :bloghome2
end

get '/blogpost'do
    erb :blogpost
end

get'/portfolio1col'do
    erb :portfolio1col
end

get'/portfolio2col'do
    erb :portfolio2col
end

get'/portfolio3col'do
    erb :portfolio3col
end

get'/portfolio4col'do
    erb :portfolio4col
end

get'/portfolioitem'do
    erb :portfolioitem
end

get '/sidebar'do
    erb :sidebar
end

get '/manifesto'do
    erb :manifesto
end

post '/manifesto' do
 
name = params[:name]
email_address = params[:email_address]
 
 db.exec("INSERT INTO manifesto (name,email_address) values ('#{name}','#{email_address}')")
 
 redirect ('/manifesto')
end
