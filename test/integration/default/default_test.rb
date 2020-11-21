# # encoding: utf-8

# Inspec test for recipe chef_server_wrapper::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe file('/etc/opscode/users/jdoe.pem') do
  it { should exist }
end

describe file('/etc/opscode/orgs/acme-validation.pem') do
  it { should exist }
end

describe port(5432) do
  it { should be_listening }
end

describe port(80) do
  it { should be_listening }
end

describe port(5672) do
  it { should be_listening }
end

describe port(443) do
  it { should be_listening }
end

describe port(9683) do
  it { should be_listening }
end
