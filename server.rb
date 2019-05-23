require "sinatra"
require "pg"
require "pry" if development? || test?
require "sinatra/reloader" if development?
require_relative "./app/models/article"

set :bind, '0.0.0.0'  # bind to all interfaces
set :views, File.join(File.dirname(__FILE__), "app", "views")

configure :development do
  set :db_config, { dbname: "news_aggregator_development" }
end

configure :test do
  set :db_config, { dbname: "news_aggregator_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get "/articles/new" do
  erb :new
end

post "/articles" do
  title = params["article_title"]
  url = params["article_url"]
  description = params["article_description"]

  CSV.open("article_list.csv", "a") do |csv|
    csv << [title, url, description]
  end

  redirect "/articles"
end

get "/articles" do
  @articles = CSV.readlines("article_list.csv", headers: true)
  erb :index
end
