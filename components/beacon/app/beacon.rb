$stdout.sync = true

require 'sinatra/base'
require 'sinatra/silent'

USVA_ENV = ENV.fetch('USVA_ENV')
USVA_DOMAIN = ENV.fetch('USVA_DOMAIN')

@app = Sinatra.new
@app.set :bind, '0.0.0.0'
@app.set :port, '8080'
@app.set :silent_sinatra, true
@app.set :silent_access_log, false
@app.set :silent_webrick, true

@app.get '/' do
  'beacon'
end

@app.get '/docker' do
  "docker run --rm --privileged -v /var/lib/k0s --cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw -e USVA_DOMAIN=#{USVA_DOMAIN} -e USVA_ENV=#{USVA_ENV} -e USVA_NAME=default mattipaksula/worker:1\n"
end

@app.get '/v1/cluster/:name/kubeconfig' do
  `helpers/ensure_k0smotron.sh #{params[:name]}`
end

@app.get '/v1/cluster/:name/magico' do
  `helpers/ensure_magico.sh #{params[:name]}`
end

@app.get '/v1/cluster/:name/jointoken' do
  `helpers/ensure_jointoken.sh #{params[:name]}`
end

@app.delete '/v1/cluster/:name' do
  `helpers/delete_cluster.sh #{params[:name]}`
end

@app.get '/v1/cluster/:name/chisel.sh' do
  name = params[:name]
  "chisel client --auth magico:sekret https://#{USVA_ENV}-k-#{name}.#{USVA_DOMAIN} 30443:kmc-#{name}:30443 30132:kmc-#{name}:30132\n"
end

@app.get '/v1/clusters' do
  `kubectl get cluster`
end

@app.get '/exit' do
  exit 1
end

puts 'beacon listen 0.0.0.0:8080'
@app.run!
