require 'sinatra'
load './local_env.rb' if File.exist?('./local_env.rb')


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

get '/fullwidth'do
    erb :fullwidth
end