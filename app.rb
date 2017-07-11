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

get '/' do

message = params[:message] || ''
  messages = {'' => '', 'added' => 'Thanks, for joining our mailing list.', 'exists' => 'You have already joined our mailing list'}
    erb :index, :locals => {:message => messages[message]}
end


#checks to see
#def db()
#  db_params = {
#    host: ENV['host'],
#    port: ENV['port'],
#    dbname: ENV['dbname'],
#    user: ENV['user'],
#    password: ENV['password']
#  } #database conections values set to variables
#  PG::Connection.new(db_params)#confirms connection to database
#end
#
#get '/' do
#
#message = params[:message] || ''
#  messages = {'' => '', 'added' => 'Thanks, for joining our mailing list.', 'exists' => 'You have already joined our mailing list'}
#    erb :index, :locals => {:message => messages[message]}
#end
#
get '/contact'do
 #allows protection against robot spammers
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
reason = params[:reason]
sum = params[:sum]

 robot = params[:robot]

  if robot == sum
    Pony.mail(
        :to => "#{email}",
        :cc => 'info@coalitionforabrightergreene.org',
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

#
#get '/about'do
#    erb :about
#end
#
#get '/services'do
#    erb :services
#end
#
#get '/pricing'do
#    erb :pricing
#end
#
#get '/documentation'do
#    erb :documentation
#end
#
#get'/blog'do
#    erb :blog
#end
#

get '/' do

 erb :commingsoon

end

get '/support' do

 erb :support
end
#
post '/subscribe' do
  email = params[:email]

 check_email = db.exec("SELECT * FROM mailing_list WHERE email = '#{email}'")

  if check_email.num_tuples.zero? == false
    db.close
    redirect '/?message=exists'
  else
    db.exec("INSERT INTO mailing_list (email) VALUES ('#{email}');")
    db.close
    redirect '/?message=added'
  end
end
#
#get '/manifesto'do
#  signed = db.exec("SELECT * FROM manifesto")
#
# erb :manifesto, :locals => {signed: signed}
#
#end
#
#post '/manifesto' do
#
#name = params[:name]
#email_address = params[:email_address]
# time = Time.new
# date = time.strftime("%Y-%m-%d")
#
# db.exec("INSERT INTO manifesto (name,email_address,date) values ('#{name}','#{email_address}','#{date}')")
#
# redirect ('/manifesto')
#end
#
#get '/current_happenings' do
#
# erb :current_happenings
#
#end
#
#get '/404' do
#
# erb :ohno
#
#end
#
#not_found do
#  redirect '/404'
#end
#
#get '/new' do
#
#erb :new
#end
#
#get '/volunteer'do
#
# thanks = params[:thanks] || ''
#  num1 = rand(9)
#  num2 = rand(9)
#  sum = num1 + num2
#  deliver = params[:deliver] || ''
#  messages = {'' => '', 'success' => "Thank you for your message. We'll get back to you shortly.", 'error' => 'Sorry, there was a problem delivering your message.'}
#  message = messages[deliver]
#
#    erb :volunteer, :locals => {thanks: thanks, num1: num1, num2: num2, sum: sum, message: message }
#end
#
#
#
#post '/volunteer' do
#
#  num1 = rand(9)
#  num2 = rand(9)
#  sum = num1 + num2
#
# erb :volunteer, :locals => {thanks: thanks, num1: num1, num2: num2, sum: sum, message: message }
#
#end


get '/manifesto'do
  signed = db.exec("SELECT * FROM manifesto")

 erb :manifesto, :locals => {signed: signed}

end

post '/manifesto' do

name = params[:name]
email_address = params[:email_address]
 time = Time.new
 date = time.strftime("%Y-%m-%d")

 db.exec("INSERT INTO manifesto (name,email_address,date) values ('#{name}','#{email_address}','#{date}')")

 redirect ('/manifesto')
end

get '/current_happenings' do

 erb :current_happenings

end

get '/404' do

 erb :ohno

end

not_found do
  redirect '/404'
end

get '/new' do

erb :new
end

get '/volunteer'do

 thanks = params[:thanks] || ''
  num1 = rand(9)
  num2 = rand(9)
  sum = num1 + num2
  deliver = params[:deliver] || ''
  messages = {'' => '', 'success' => "Thank you for your message. We'll get back to you shortly.", 'error' => 'Sorry, there was a problem delivering your message.'}
  message = messages[deliver]

    erb :volunteer, :locals => {thanks: thanks, num1: num1, num2: num2, sum: sum, message: message }
end



post '/volunteer' do
 # robot spammer protection
  num1 = rand(9)
  num2 = rand(9)
  sum = num1 + num2

 erb :volunteer, :locals => {thanks: thanks, num1: num1, num2: num2, sum: sum, message: message }

end

