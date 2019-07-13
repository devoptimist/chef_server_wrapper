hostname = if node['chef_server_wrapper']['fqdn'] != ''
             node['chef_server_wrapper']['fqdn']
           elsif node['cloud'] && node['chef_server_wrapper']['cloud_public_address']
             node['cloud']['public_ipv4_addrs'].first
           else
             node['ipaddress']
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

if node['chef_server_wrapper']['chef_orgs'] != {} &&
   node['chef_server_wrapper']['chef_users'] != {}

  template node['chef_server_wrapper']['starter_pack_knife_rb_path'] do
    source 'knife.rb.erb'
    variables(
      user: node['chef_server_wrapper']['starter_pack_user'],
      org: node['chef_server_wrapper']['starter_pack_org'],
      fqdn: hostname
    )
  end
end
