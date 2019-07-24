default['chef_server_wrapper']['channel'] = :stable
default['chef_server_wrapper']['version'] = '13.0.17'
default['chef_server_wrapper']['accept_license'] = true
default['chef_server_wrapper']['supermarket_url'] = ''
default['chef_server_wrapper']['data_collector_url'] = ''
default['chef_server_wrapper']['data_collector_token'] = ''
default['chef_server_wrapper']['addons'] = {}
default['chef_server_wrapper']['config'] = ''
default['chef_server_wrapper']['config_block'] = {}
default['chef_server_wrapper']['chef_users'] = {}
default['chef_server_wrapper']['chef_orgs'] = {}
default['chef_server_wrapper']['tmp_path'] = '/var/tmp'

default['chef_server_wrapper']['starter_pack_knife_rb_path'] =
  "#{node['chef_server_wrapper']['tmp_path']}/knife.rb"

default['chef_server_wrapper']['details_script_path'] =
  "#{node['chef_server_wrapper']['tmp_path']}/chef_server_details.sh"

default['chef_server_wrapper']['frontend_script_path'] =
  "#{node['chef_server_wrapper']['tmp_path']}/frontend_secrets.sh"

default['chef_server_wrapper']['starter_pack_user'] = ''
default['chef_server_wrapper']['starter_pack_org'] = ''
default['chef_server_wrapper']['fqdn'] = ''
default['chef_server_wrapper']['jq_url'] = 'https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64'
default['chef_server_wrapper']['cloud_public_address'] = false

# frontend secrets
default['chef_server_wrapper']['frontend_secrets'] = {}

# SSL certificate related attribures
default['chef_server_wrapper']['cert'] = ''
default['chef_server_wrapper']['cert_key'] = ''
default['chef_server_wrapper']['cert_directory'] = '/etc/ssl/private'
