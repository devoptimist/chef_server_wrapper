#
# Cookbook:: chef_server_wrapper
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

chef_ingredient 'chef-server' do
  channel node['chef_server_wrapper']['channel'].to_sym
  config node['chef_server_wrapper']['config']
  action :install
  version node['chef_server_wrapper']['version']
  accept_license node['chef_server_wrapper']['accept_license']
  notifies :reconfigure, 'chef_ingredient[chef-server]'
end

node['chef_server_wrapper']['chef_users'].each do |name, params|
  chef_user name do
    first_name params['first_name']
    last_name params['last_name']
    email params['email']
    password params['password']
    serveradmin params['serveradmin']
  end
end

node['chef_server_wrapper']['chef_orgs'].each do |name, params|
  chef_org name do
    org_full_name params['org_full_name']
    admins params['admins']
  end
end
