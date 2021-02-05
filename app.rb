require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions 

get('/') do 
    slim(:register)
end 

post('/users/new') do 
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    if (password == password_confirm)
        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new('db/guitar_webshop.db')
        db.execute("INSERT INTO users (username,pwdigest) VALUES (?,?)",username,password_digest)
        redirect('/')
    else
        "Skriv ett lösenord som matchar de angivna."
    end

end 