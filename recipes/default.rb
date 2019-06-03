#
# Cookbook:: chef_server_wrapper
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

chef_ingredient 'chef-server' do
  channel node['chef_server_wrapper']['channel']
  config node['chef_server_wrapper']['config']
  action :install
  version node['chef_server_wrapper']['version']
  accept_license node['chef_server_wrapper']['accept_license']
  notifies :reconfigure, 'chef_ingredient[chef-server]'
end
