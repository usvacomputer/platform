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
  [
    'docker run',
    '--rm',
    '--privileged',
    '--cgroupns=host',
    '-v /sys/fs/cgroup:/sys/fs/cgroup:rw',
    '-v /var/lib/k0s',
    '--mount type=tmpfs,destination=/var/run',
    '--mount type=tmpfs,destination=/run',
    "-e USVA_DOMAIN=#{USVA_DOMAIN}",
    "-e USVA_ENV=#{USVA_ENV}",
    '-e USVA_NAME=default',
    'ghcr.io/usvacomputer/platform/worker:65061ea4bd7f67a79e768fe371f7193a8a013ea8'
  ].join(' ') + "\n"
end

@app.get '/docker2' do
  [
    'docker run',
    '--rm',
    '--privileged',
    '-v /var/lib/k0s',
    '--mount type=tmpfs,destination=/var/run',
    '--mount type=tmpfs,destination=/run',
    "-e USVA_DOMAIN=#{USVA_DOMAIN}",
    "-e USVA_ENV=#{USVA_ENV}",
    '-e USVA_NAME=default',
    'ghcr.io/usvacomputer/platform/worker:65061ea4bd7f67a79e768fe371f7193a8a013ea8'
  ].join(' ') + "\n"
end

@app.get '/docker3' do
  [
    'docker run',
    '--rm',
    '--privileged',
    '-v /var/lib/k0s',
    "-e USVA_DOMAIN=#{USVA_DOMAIN}",
    "-e USVA_ENV=#{USVA_ENV}",
    '-e USVA_NAME=default',
    'ghcr.io/usvacomputer/platform/worker:65061ea4bd7f67a79e768fe371f7193a8a013ea8'
  ].join(' ') + "\n"
end

@app.get '/docker4' do
  [
    'docker run',
    '--rm',
    '--privileged',
    '--cgroupns=host',
    '-v /sys/fs/cgroup:/sys/fs/cgroup:rw',
    '-v /var/lib/k0s',
    "-e USVA_DOMAIN=#{USVA_DOMAIN}",
    "-e USVA_ENV=#{USVA_ENV}",
    '-e USVA_NAME=default',
    'ghcr.io/usvacomputer/platform/worker:65061ea4bd7f67a79e768fe371f7193a8a013ea8'
  ].join(' ') + "\n"
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
  "chisel client --max-retry-interval 5s --auth magico:sekret https://#{USVA_ENV}-k-#{name}.#{USVA_DOMAIN} 30443:kmc-#{name}:30443 30132:kmc-#{name}:30132\n"
end

@app.get '/v1/clusters' do
  `kubectl get cluster`
end

@app.get '/exit' do
  exit 1
end

puts 'beacon listen 0.0.0.0:8080'
@app.run!
