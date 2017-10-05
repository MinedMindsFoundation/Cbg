require 'sinatra'
require 'pg'
require 'pony'
#gems sinatra for structure pg for database pony for mail
load './local_env.rb' if File.exist?('./local_env.rb')

def connection()
  db_params = {
    host: ENV['host'],
    port: ENV['port'],
    dbname: ENV['dbname'],
    user: ENV['user'],
    password: ENV['password']
  }
  db = PG::Connection.new(db_params) #sets connection with db
end

get '/' do

message = params[:message] || ''
  messages = {'' => '', 'added' => 'Thanks, for joining our mailing list.', 'exists' => 'You have already joined our mailing list'}
  db = connection() 
  spotlight_show = db.exec("select * from public.spotlight")
 db.close
   db = connection() 

  sponsor_logos = db.exec("SELECT * from public.sponsors")
 db.close
    erb :index, :locals => {:message => messages[message],:spotlight_show => spotlight_show, :sponsor_logos => sponsor_logos}
end


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
        :bcc => 'greenecocoalition@gmail.com',
        :from => 'info@coalitionforabrightergreene.org',
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


#get '/' do
#
# erb :comingsoon
#
#end


get '/support' do
erb :support
end

post '/subscribe' do
  email = params[:email]
 db = connection()
 check_email = db.exec("SELECT * FROM mailing_list WHERE email = '#{email}'")

  if check_email.num_tuples.zero? == false
    db.close
    redirect '/?message=exists'
  else
    db = connection()
    db.exec("INSERT INTO mailing_list (email) VALUES ('#{email}');")
    db.close
    redirect '/?message=added'
  end
end


get '/manifesto'do

  db = connection()
  signed = db.exec("SELECT * FROM manifesto")
  db.close
 erb :manifesto, :locals => {signed: signed, message: " "}

end

post '/manifesto' do

name = params[:name]
email_address = params[:email_address]
 time = Time.new
 date = time.strftime("%Y-%m-%d")
 db = connection()
signed = db.exec("SELECT * FROM manifesto")
check_signed = db.exec("SELECT email_address FROM manifesto WHERE email_address = '#{email_address}'")
    if check_signed.num_tuples.zero? == false
    db.close
    erb :manifesto, :locals => {signed: signed, message: 'Already signed, thank you.'}
  else

 db.exec("INSERT INTO manifesto (name,email_address,date) values ('#{name}','#{email_address}','#{date}')")
 db.close
 erb :manifesto, :locals => {signed: signed, message: 'Thanks for signing & making a commitment to keep Greene County drug free.'}
    end
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

#get '/new' do
#
#erb :new
#end

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

  name = params[:name]
  phone = params[:phone]
  email = params[:email]#block gathers user info places values into variables
  message = params[:message]
  reason = params[:reason]
  sum = params[:sum]
  time = Time.new#kernel for registering time of new signup
  date = time.strftime("%Y-%m-%d")#kernel for registering date
  robot = params[:robot]
  messages = {'' => '', 'success' => "Thank you for your message. We'll get back to you shortly.", 'error' => 'Sorry, there was a problem delivering your message.'}
  if robot == sum #confirms human interaction
    Pony.mail(
        :to => "#{email}",
        :cc => 'info@coalitionforabrightergreene.org',
        :bcc => 'greenecocoalition@gmail.com',
        :from => 'info@coalitionforabrightergreene.org',
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
        }#mails and loads sender info

      )

puts "This is the info:
name = '#{name}'
email = '#{email}'
date = '#{date}'
phone = '#{phone}'
message ='#{message}'
reason = '#{reason}'"
db = connection()
  db.exec("INSERT INTO volunteer (name,email,date,phone,message, reason) VALUES ('#{name}','#{email}','#{date}','#{phone}','#{message}','#{reason}');")
   #places data into database of new signup

db.close
        redirect '/volunteer?deliver=success'
  else
    redirect '/volunteer?deliver=error'#human interaction function part of
  end
end

get '/admin' do
  db = connection() 
  spotlight_show = db.exec("select * from public.spotlight")
  db.close
  db = connection()
  sponsor_logos = db.exec("select * from public.sponsors")
 db.close
erb :admin, :locals => {:spotlight_show => spotlight_show, :sponsor_logos => sponsor_logos }
 
end

post '/spotlight_update' do
 spotlight_photo = params[:spotlight_photo]
 actual_names = params[:actual_names]
 individual_or_organization_name = params[:individual_or_organization_name]
 bio = params[:bio]
 start_date = params[:start_date]
 db = connection()

 spotlight_update = db.exec("INSERT INTO public.spotlight (facebook_url, individual_or_organization_name, bio, start_date,actual_names) VALUES('#{spotlight_photo}', '#{actual_names}', '#{individual_or_organization_name}', '#{bio}', '#{start_date}'); ")
 
 redirect to '/admin'
end

post '/sponsor_update' do

 sponsor_name = params[:sponsor_name]
 sponsor_logo = params[:sponsor_logo]
 
 db = connection()
 sponsor_update = db.exec("INSERT INTO public.sponsors (sponsor_name,sponsor_logo) VALUES ('#{sponsor_name}','#{sponsor_logo}')")
 
 redirect to '/admin'
end
