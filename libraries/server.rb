module ChefServerWrapper
  module ServerHelpers
    def read_pem(type, name)
      path = case type
             when 'org'
               "/etc/opscode/orgs/#{name}-validation.pem"
             when 'client'
               "/etc/opscode/users/#{name}.pem"
             end
      if ::File.file?(path)
        ::File.read(path)
      else
        ""
      end
    end
  end
end
