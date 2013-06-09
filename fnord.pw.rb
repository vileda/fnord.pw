require 'sinatra'
require 'digest'

def read_files_to_mem
  paths = Dir.glob('storage/**/*.txt')
  hashes = paths.map { |p| p = p.gsub('storage/','').gsub('/','') }
  map = {}
  paths.each_with_index { |p,i|
    File.open(p,'r') { |f| map[hashes[i][0..5]] = f.readline }
  }
  map
end


file_map = read_files_to_mem()

get '/' do
  erb :index
end

post '/' do
  url = params[:url]
  url_hash = Digest::SHA256.new.hexdigest(url)
  path = hash_to_path(url_hash)+'.txt'
  File.open(path,'w+') { |f| f.write(url); f.close } 
  file_map[url_hash[0..5]] = url
  redirect '/'+url_hash[0..5]+'/show'
end

get '/:hash' do
  redirect file_map[params[:hash]]
end

get '/:hash/show' do
  @url = file_map[params[:hash]]
  erb :show
end

def hash_to_path(hash)
  path =  'storage/'+hash.scan(/.{2}/).join('/')
  `mkdir -p #{path}`
  path
end

