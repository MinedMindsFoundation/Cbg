require 'sinatra'
require 'pg'
require 'pony'
require 'mail'
require 'bcrypt'
load './local_env.rb' if File.exist?('./local_env.rb')

enable :sessions

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

def authentication_required
	redirect to('/login') unless session[:user]
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
        :domain               => ENV['domain']
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
	db = connection()
	string = "select to_char(article_date,'TMMonth, TMYYYY')as article_month, article_link,article_name from public.news_articles group by article_date,article_link,article_name order by article_date,article_link,article_name"
	news_articles = db.exec("#{string}")
	erb :current_happenings, :locals => {:news_articles => news_articles}
end

get '/404' do
	erb :ohno
end

not_found do
	redirect '/404'
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
				:domain               => ENV['domain']
				}#mails and loads sender info
			)
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
	authentication_required
	db = connection() 
	spotlight_show = db.exec("select * from public.spotlight")
	db.close
	db = connection() 
	sponsor_logos = db.exec("select * from public.sponsors")
	db.close
	db = connection() 
	manifesto_signers = db.exec('SELECT "name", email_address, "date" FROM public.manifesto;')
	db.close
	erb :admin, :locals => {:spotlight_show => spotlight_show, :sponsor_logos => sponsor_logos, :manifesto_signers => 	manifesto_signers }
end

post '/spotlight_update' do
	spotlight_photo = params[:spotlight_photo]
	actual_names = params[:actual_names]
	individual_or_organization_name = params[:individual_or_organization_name]
	bio = params[:bio]
	start_date = params[:start_date]
	db = connection()
	spotlight_update = db.exec("INSERT INTO public.spotlight (spotlight_photo, actual_names, individual_or_organization_name, bio,start_date) VALUES('#{spotlight_photo}', '#{actual_names}', '#{individual_or_organization_name}', '#{bio}', '#{start_date}'); ")
	redirect to '/admin'
end

post '/sponsor_update' do
	sponsor_name = params[:sponsor_name]
	sponsor_logo = params[:sponsor_logo]
	db = connection()
	sponsor_update = db.exec("INSERT INTO public.sponsors (sponsor_name,sponsor_logo) VALUES ('#{sponsor_name}','#{sponsor_logo}')")
	redirect to '/admin'
end

post '/news_update' do
	article_link = params[:article_link]
	article_name = params[:article_name]
	article_date_month = params[:article_date_month]
	article_date_day = params[:article_date_day]
	article_date_year = params[:article_date_year]
	article_partial_date = params[:article_date_year] + "-" + params[:article_date_month]
	article_whole_date = params[:article_date_year] + "-" + params[:article_date_month] + "-" + params[:article_date_day]
	db = connection()
	article_links = [] || article_links
	article_names = [] || article_names
	existing_articles_check = db.exec("select to_char(article_date,'yyyy mm')as article_date,article_link,article_name from public.news_articles where article_date >= '#{article_partial_date}-01 ' and article_date < '#{article_partial_date}-31' ")
	existing_articles_check[0]["article_link"].gsub(/(\[\"|\"\])/, '').split('", "').each do  |link|
		article_links.push(link)
	end
	article_links.push(article_link) 
	existing_articles_check[0]["article_name"].gsub(/(\[\"|\"\])/, '').split('", "').each do  |link|
		article_names.push(link)
	end
	article_names.push(article_name) 
	update = db.exec("UPDATE public.news_articles SET article_link='#{article_links}', article_date='#{article_whole_date}', article_name='#{article_names}' where article_date >= '#{article_partial_date}-01 ' and article_date < '#{article_partial_date}-31';")
	db.close
	redirect to '/admin'
end

get '/login' do
	invalid = params[:invalid] || ''
	adminadded = params[:adminadded] || ''
	email_exists = params[:email_exists] || ''
	erb :login, :locals => {:message => "", :invalid => invalid, :adminadded => adminadded, :email_exists => email_exists}
end

get '/request_access' do
	alreadyexists = params[:alreadyexists]
	erb :register, :locals => {:alreadyexists => alreadyexists}
end

post '/request_access' do
	fname = params[:fname].gsub(" ", "%20")
	lname = params[:lname]
	email = params[:email]
	db = connection()
	sql1 = "SELECT email FROM admin_users WHERE email = '#{email}'"
	email_check = db.exec(sql1)
	if email_check.num_tuples.zero?
		encrypted_email = BCrypt::Password.create(email)
		email_body = ENV['domain'] + '/create_admin?fname=' + fname + '&lname=' + lname + '&email=' + email + '&id=' + encrypted_email
		Pony.mail(
			:to => 'info@coalitionforabrightergreene.org',
			:bcc => 'greenecocoalition@gmail.com',
			:from => 'info@coalitionforabrightergreene.org',
			:subject => "'#{fname}  '#{lname}' is requesting admin access ",
			:content_type => 'text/html',
			:body => "#{email_body}",
			:via => :smtp,
			:via_options => {
				:address              => 'smtp.gmail.com',
				:port                 => '587',
				:enable_starttls_auto => true,
				:user_name           => ENV['email'],
				:password            => ENV['email_pass'],
				:authentication       => :plain,
				:domain               => ENV['domain']
				}#mails and loads sender info
			)	
		redirect '/request_access?alreadyexists=Your request has been sent and you will be notified if you are approved?'
	else
		redirect '/request_access?alreadyexists=You are already in our system, prehaps you want to reset your password?'
	end
	db.close
end

get '/create_admin' do
	fname = params[:fname].gsub(" ", "%20")
	lname = params[:lname]
	email = params[:email]
	id = params[:id]	
	password = 'changeme'
	db = connection()
	encrypted_password = BCrypt::Password.create(password)
	sql1 = "SELECT email FROM admin_users WHERE email = '#{email}'"
	sql2 = "INSERT INTO admin_users (first_name, last_name,email, password) VALUES ('#{fname}','#{lname}','#{email}', '#{encrypted_password}')"
	email_check = db.exec(sql1)
	id = params[:id]
	begin
		encrypted_email = BCrypt::Password.new(id)
	rescue BCrypt::Errors::InvalidHash
		redirect '/?message=invalid'
	end 
	if encrypted_email == email
		if email_check.num_tuples.zero?
			db.exec(sql2)
			redirect '/login?adminadded=Admin User Created'
		else
			redirect '/login?email_exists=Email already exists' + '&email=' + email
		end		
		erb :reset_password, :locals => {:name => "",:survey => "",:email=> email, :message => ""}
	else
		redirect '/?message=invalid'
	end
	db.close
end

post '/login' do
	user_email = params[:form_email]
	user_password = params[:form_password]
	db = connection()
	sql = "SELECT email, password FROM admin_users WHERE email = '#{user_email}'"
	user = db.exec(sql)
	if user.num_tuples.zero?
		db.close
		redirect '/login?invalid=Invalid Email or Password'
	end
	begin
		db_pass = user[0]['password']
		pass = BCrypt::Password.new(db_pass)
	rescue BCrypt::Errors::InvalidHash
		redirect '/login?invalid=Invalid Email or Password'
	end 
	db_pass = user[0]['password']
	pass = BCrypt::Password.new(db_pass)
	if pass != user_password
		redirect '/login?invalid=Invalid Email or Password'
	else
		session[:user] = user_email
		redirect to '/admin'
		db.close
	end
end

get '/logout' do
	session[:user] = nil
	redirect '/'
end

# After clicking on the forgot passowrd link, auser will be provided an form will they can provide and email and if that email exists as a current admin a password will then be sent to the registered email , if the email address is not assocaited with a admin account an error message will show stating the fact
get '/forgot_password' do
	email = params[:email]
	message = params[:message] || ''
	erb :forgot_password, :locals => {:name => "Login",:survey => "",:email => email, :invalid => "", :message => message}
end


post '/forgot_password' do
	email = params[:email]
	db = connection()
	sql1 = "SELECT email FROM admin_users WHERE email = '#{email}'"
	email_check = db.exec(sql1)
	if email_check.num_tuples.zero?
		db.close
		redirect 'forgot_password?message=Sorry+that+email+does+not+exist+in+our+database.'
	else
		# Having provided an email address that is associated with a current admin an email (Using the Pony Mail Gem) will be sent to the email address provided. This is sent with a encrypted id using bcrypt to prevent malicous attempts to reset anothers passowrd.
		encrypted_email = BCrypt::Password.create(email)
		email_body = ENV['domain'] + '/reset_password?id=' + encrypted_email + '&email=' + email
		Pony.mail(
			:to => "#{email}",
			:cc => 'info@coalitionforabrightergreene.org',
			:bcc => 'greenecocoalition@gmail.com',
			:from => 'info@coalitionforabrightergreene.org',
			:subject => "Password reset link for Coalition for a Brighter Greene Admin",
			:content_type => 'text/html',
			:body => "#{email_body}",
			:via => :smtp,
			:via_options => {
				:address              => 'smtp.gmail.com',
				:port                 => '587',
				:enable_starttls_auto => true,
				:user_name           => ENV['email'],
				:password            => ENV['email_pass'],
				:authentication       => :plain,
				:domain               => ENV['domain']
				}#mails and loads sender info
			)
		redirect '/?email=' + email + '&message=reset'
	end
	db.close
end

#This is where the user comes after clicking on the link in the email requesting the password reset
	#Attempts to change to the email address through inspecting will not work as it an encrypted email id must match before a password reset will be allowed
get '/reset_password' do
	email = params[:email]
	id = params[:id]
	begin
		encrypted_email = BCrypt::Password.new(id)
	rescue BCrypt::Errors::InvalidHash
		redirect '/?message=invalid'
	end 
	if encrypted_email == email
		erb :reset_password, :locals => {:name => "",:survey => "",:email=> email, :message => ""}
	else
		redirect '/?message=invalid'
	end
end

#Having clicked on a real reset link thus providing the correct id a users password is updated with anew one of their choosing which is thenencrypted using bcrypt for storage a database
post '/reset_password' do
	email = params[:email]
	password = params[:password]
	encrypted_password = BCrypt::Password.create(password)
	db = connection()
	sql1 = "UPDATE admin_users SET password = '#{encrypted_password}' WHERE email = '#{email}'"
	sql2 = "SELECT firstname, lastname, address, address2, city, state, zip, phone, email,preferred_email FROM admin_users"
	db.exec(sql1)
	db.close
	redirect '/'
end

#get '/' do
#
# erb :comingsoon
#
#end


