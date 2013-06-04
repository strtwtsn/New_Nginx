package "libcurl4-openssl-dev"


bash "Extract and install nginx" do
user "root"
code <<-EOH
sudo apt-get update
sudo apt-get install nginx
EOH
end

template "/etc/init.d/nginx start script" do
  path "/etc/init.d/nginx"
  source "startup.erb"
  owner "root"
  group "root"
  mode 0755  
end

execute "add nginx startup script to server boot" do 
  command "/usr/sbin/update-rc.d -f nginx defaults"
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true  
end

#SETUP NGINX CONF FILE
template "nginx.conf" do
  path "/etc/nginx/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  notifies :reload, resources(:service => "nginx")
end

directory "/etc/nginx/sites-available" do
owner "root"
group "root"
action :create
end

directory "/etc/nginx/sites-enabled" do
owner "root"
group "root"
action :create
end

directory "/var/www" do
owner "root"
group "root"
action :create
end


directory "/etc/nginx/conf.d" do
owner "root"
group "root"
action :create
end


template "passenger.conf" do
  path "/etc/nginx/conf.d/passenger.conf"
  source "passenger.conf.erb"
  owner "root"
  group "root"
  notifies :reload, resources(:service => "nginx")
end

bash "Tidy up" do
 user "root"
 code <--EOH
 mkdir -p /var/log/nginx
 cd /var/log/nginx
 touch access.log
 touch error.log
 cd /home/ubuntu/.rvm/gems/ruby-1.9.3-p429/gems/passenger-4.0.5
 rvmsudo rake nginx
 EOH
end
 

