$stdout.sync = true

require 'sinatra/base'
require 'sinatra/silent'

@app = Sinatra.new
@app.set :bind, '0.0.0.0'
@app.set :port, '8080'
@app.set :silent_sinatra, true
@app.set :silent_access_log, false
@app.set :silent_webrick, true

@app.get '/' do
  'beacon'
end

@app.get '/v1/cluster/:name/kubeconfig' do
  `helpers/ensure_k0smotron.sh #{params[:name]} 30100 30101`
end

@app.get '/v1/cluster/:name/magico' do
  `helpers/ensure_magico.sh #{params[:name]} 30100`
end

@app.get '/v1/cluster/:name/jointoken' do
  `helpers/ensure_jointoken.sh #{params[:name]}`
end

@app.delete '/v1/cluster/:name' do
  `helpers/delete_cluster.sh #{params[:name]}`
end

@app.get '/v1/clusters' do
  `kubectl get cluster`
end

@app.get '/exit' do
  exit 1
end

puts 'beacon listen 0.0.0.0:8080'
@app.run!
