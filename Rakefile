task :default => :start

app = 'app'

desc "Start #{app} using the Thin webserver"
task :start do
  system('thin -p 4568 start')
end

desc "Start #{app} using the default webserver"
task :rackup do
  rackup
end
