require 'sinatra'
require 'pg'
require 'pony'

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
 
 thanks = params[:thanks] || ''
  num1 = rand(9)
  num2 = rand(9)
  sum = num1 + num2
  deliver = params[:deliver] || ''
  messages = {'' => '', 'success' => "Thank you for your message. We'll get back to you shortly.", 'error' => 'Sorry, there was a problem delivering your message.'}
  message = messages[deliver]
 
    erb :contact, :locals => {thanks: thanks, num1: num1, num2: num2, sum: sum, message: message }
end

post '/contact' do

name = params[:name]
phone = params[:phone]
email = params[:email]
message = params[:message]
thankyou = "Thanks For Contacting Coalition for a brighter Greene" 
sum = params[:sum]

 robot = params[:robot]
  sum = params[:sum]
  
  if robot == sum
    Pony.mail(
        :to => "#{email}",
#        :bcc => '', 
        :from => 'joseph@minedminds.org',
        :subject => "CBG", 
        :content_type => 'text/html', 
        :body => erb(:email2,:layout=>false),
        :via => :smtp, 
        :via_options => {
          :address              => 'smtp.gmail.com',
          :port                 => '587',
          :enable_starttls_auto => true,
           :user_name           => ENV['email'],
           :password            => ENV['email_pass'],
           :authentication       => :plain, 
           :domain               => 'localhost:4567' 
        }

      )
     redirect '/contact?deliver=success'
  else
    redirect '/contact?deliver=error'
  end
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
