#
# Cookbook:: chef_server_wrapper
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

config = node['chef_server_wrapper']['config']

config += if node['chef_server_wrapper']['data_collector_url'] != ''
            <<~EOF
            data_collector['root_url'] = '#{node['chef_server_wrapper']['data_collector_url']}/data-collector/v0/'
            data_collector['proxy'] = true
            profiles['root_url'] = '#{node['chef_server_wrapper']['data_collector_url']}'

            EOF
          else
            ''
          end

config += if node['chef_server_wrapper']['token'] != ''
            <<~EOF
            data_collector['token'] =  #{node['chef_server_wrapper']['token']}

            EOF
          else
            ''
          end

remote_file '/bin/jq' do
  source node['chef_server_wrapper']['jq_url']
  mode '0755'
end

hostname = if node['chef_server_wrapper']['fqdn'] != ''
             node['chef_server_wrapper']['fqdn']
           elsif node['cloud']
             node['cloud']['public_ipv4_addrs'].first
           else
             node['ipaddress']
           end

config += if hostname != node['cloud']['public_ipv4_addrs'].first && hostname != node['ipaddress']
            <<~EOF
            api_fqdn = #{hostname}

            EOF
          else
            ''
          end

chef_ingredient 'chef-server' do
  channel node['chef_server_wrapper']['channel'].to_sym
  config node['chef_server_wrapper']['config']
  action :install
  version node['chef_server_wrapper']['version']
  accept_license node['chef_server_wrapper']['accept_license'].to_s == 'true' ? true : false
end

execute 'chef-server-reconfigure-first-boot' do
  command 'chef-server-ctl reconfigure'
  not_if { File.exist?('/etc/opscode/pivotal.rb') }
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

template node['chef_server_wrapper']['starter_pack_knife_rb_path'] do
  source 'knife.rb.erb'
  variables(
    user: node['chef_server_wrapper']['starter_pack_user'],
    org: node['chef_server_wrapper']['starter_pack_org'],
    fqdn: hostname
  )
end
