#
# Cookbook:: chef_server_wrapper
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

hostname = if node['chef_server_wrapper']['fqdn'] != ''
             node['chef_server_wrapper']['fqdn']
           elsif node['cloud']
             node['cloud']['public_ipv4_addrs'].first
           else
             node['ipaddress']
           end

if node['chef_server_wrapper']['config_block'] ! = {}
  config = node['chef_server_wrapper']['config_block'][hostname]
else
  config = node['chef_server_wrapper']['config']
end

config += if node['chef_server_wrapper']['supermarket_url'] != ''
            <<~EOF
            oc_id['applications'] ||= {}
            oc_id['applications']['supermarket'] = {
              'redirect_uri' => '#{node['chef_server_wrapper']['supermarket_url']}/auth/chef_oauth2/callback'
            }

            EOF
          else
            <<~EOF
            EOF
          end

config += if node['chef_server_wrapper']['data_collector_url'] != ''
            <<~EOF
            data_collector['root_url'] = '#{node['chef_server_wrapper']['data_collector_url']}/data-collector/v0/'
            data_collector['proxy'] = true
            profiles['root_url'] = '#{node['chef_server_wrapper']['data_collector_url']}'

            EOF
          else
            <<~EOF
            EOF

          end

config += if node['chef_server_wrapper']['data_collector_token'] != ''
            <<~EOF
            data_collector['token'] =  '#{node['chef_server_wrapper']['data_collector_token']}'

            EOF
          else
            <<~EOF
            EOF
          end

remote_file '/bin/jq' do
  source node['chef_server_wrapper']['jq_url']
  mode '0755'
end



config += if hostname != node['cloud']['public_ipv4_addrs'].first && hostname != node['ipaddress']
            <<~EOF
            api_fqdn = '#{hostname}'

            EOF
          else
            <<~EOF
            EOF
          end

chef_ingredient 'chef-server' do
  channel node['chef_server_wrapper']['channel'].to_sym
  config config
  action %i(install reconfigure)
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
