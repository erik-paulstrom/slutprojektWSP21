require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions 

get('/') do 
    slim(:register)
end 

get('/showlogin') do 
    slim(:login)
end 

post('/login') do 
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/guitar_webshop.db')
    db.results_as_hash = true
    result = db.execute('SELECT * FROM users WHERE username = ?',username).first
    pwdigest = result["pwdigest"]
    id = result["id"]

    if BCrypt::Password.new(pwdigest) == password
        session[:user_id] = id 
        redirect('/shop')
    else
        "Fel lösenord!"
    end
end

get('/shop') do 
    slim(:"shop/index")
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

# 1. Lägg till i tabell
# 2. Hömta allt frpn tabellern ( i app.rb)
# 3. slim(:ngt, locals:{products:result})
# 4. - products.each do |product|
# a href="/products/#{product["id"]" #{product["name"]} 

get('/checkout') do 
    slim(:"shop/checkout")
end 

post('/photos/1') do 
    user_id = session[:user_id]
    guitar = params[:id]
    id = params[:id]

    db = SQLite3::Database.new('db/guitar_webshop.db')
    result = db.execute('SELECT * FROM products WHERE id = ?',id).first
    redirect('/checkout')
end 
post('/photos/2') do 
    user_id = session[:user_id]
    guitar = params[:id]
    id = params[:id]

    db = SQLite3::Database.new('db/guitar_webshop.db')
    result = db.execute('SELECT * FROM products WHERE id = ?',id).first
    redirect('/checkout')
end 

get('/seed') do 
    db = SQLite3::Database.new('db/guitar_webshop.db')
    db.results_as_hash = true
    db.execute('DROP TABLE if exists products')

    db.execute('CREATE TABLE "products" (
        "id"	INTEGER,
        "name"	TEXT NOT NULL UNIQUE,
        "img" TEXT NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT)
    );')

    guitars = [
        {name: "Telecaster1", img: "img/tele1.png"},
        {name: "Telecaster2", img: "img/tele2.jpg"},
        {name: "Telecaster3", img: "img/tele3.jpg"},
        {name: "Strata1", img: "img/strata1.jpg"},
        {name: "Strata2", img: "img/strata2.jpg"},
        {name: "Strata3", img: "img/strata3.jpg"},
        {name: "LesPaul1", img: "img/lespaul1.jpg"},
        {name: "LesPaul2", img: "img/lespaul2.png"},
        {name: "LesPaul3", img: "img/lespaul3.jpeg"},
    ]

    guitars.each do |product|
        db.execute('INSERT INTO products (name, img) values(?,?)', product[:name], product[:img])
    end
end 

