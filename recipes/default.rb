#
# Cookbook:: chef_server_wrapper
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

hostname = if node['chef_server_wrapper']['fqdn'] != ''
             node['chef_server_wrapper']['fqdn']
           elsif node['cloud'] && node['chef_server_wrapper']['cloud_public_address']
             node['cloud']['public_ipv4_addrs'].first
           else
             node['ipaddress']
           end

config = if node['chef_server_wrapper']['config_block'] != {}
           node['chef_server_wrapper']['config_block'][hostname]
         else
           ''
         end

config += <<~EOF

  #{node['chef_server_wrapper']['config']}
  EOF

if node['chef_server_wrapper']['cert'] != '' &&
   node['chef_server_wrapper']['cert_key'] != ''

  cert_dir = node['chef_server_wrapper']['cert_directory']
  cert_path = "#{cert_dir}/#{hostname}.crt"
  cert_key_path = "#{cert_dir}/#{hostname}.key"

  directory cert_dir do
    mode '0700'
    owner 'root'
    group 'root'
  end

  file cert_path do
    content node['chef_server_wrapper']['cert']
    mode '0644'
    owner 'root'
    group 'root'
  end

  file cert_key_path do
    content node['chef_server_wrapper']['cert_key']
    mode '0600'
    owner 'root'
    group 'root'
  end

  config += <<~EOF
              nginx['ssl_certificate']  = "#{cert_path}"
              nginx['ssl_certificate_key']  = "#{cert_key_path}"
              EOF
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
  version node['chef_server_wrapper']['version']
  config config
  ctl_command 'chef-server-ctl reconfigure --chef-license accept' if node['chef_server_wrapper']['accept_license'].to_s == 'true'
  action %i(install reconfigure)
end

execute 'chef-server-reconfigure-first-boot' do
  command 'chef-server-ctl reconfigure'
  not_if { File.exist?('/etc/opscode/pivotal.rb') }
end

# we offer suse linux chef server packages but no
# addon packages are build for suse
if node['platform_family'] == 'suse' && node['chef_server_wrapper']['addons'] != {}
  platform = 'el'
  platform_version = '7'
end

node['chef_server_wrapper']['addons'].each do |addon, options|
  chef_ingredient addon do
    action :upgrade
    channel options['channel'].to_sym || :stable
    version options['version'] || :latest
    config options['config'] || ''
    accept_license node['chef_server_wrapper']['accept_license'].to_s == 'true'
    platform platform if platform
    platform_version platform_version if platform_version
  end

  ingredient_config addon do
    notifies :reconfigure, "chef_ingredient[#{addon}]", :immediately
  end
end

if node['chef_server_wrapper']['chef_orgs'] != {} &&
   node['chef_server_wrapper']['chef_users'] != {}

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
end

template node['chef_server_wrapper']['chef_server_details_script_path'] do
  extend ChefServerWrapper::ServerHelpers
  source 'chef_server_details.sh.erb'
  variables(
    user: node['chef_server_wrapper']['starter_pack_user'],
    org: node['chef_server_wrapper']['starter_pack_org'],
    client_pem: lazy { read_pem('client', node['chef_server_wrapper']['starter_pack_user']).inspect },
    validation_pem: lazy { read_pem('org', node['chef_server_wrapper']['starter_pack_org']).inspect },
    fqdn: hostname
  )
end
