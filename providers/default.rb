action :create do
  directory "#{new_resource.shared_dir}" do
    recursive new_resource.recursive
    user new_resource.user
    group new_resource.group
    path "#{new_resource.shared_dir}"
    action :create
    only_if { !::File.directory?("#{new_resource.shared_dir}") }
  end

  template "#{new_resource.shared_dir}secrets.yml" do
    cookbook 'secrets-lwrp'
    source "secrets.yml.erb"
    owner new_resource.user
    group new_resource.group
    mode "0660"
    variables({
      :secret_keys => new_resource.secret_keys
    })
  end

  Chef::Log.info("secrets.yml file should now exist at: #{new_resource.shared_dir}secrets.yml")
end


# Override Load Current Resource
def load_current_resource

  @current_resource = Chef::Resource::SecretsLwrp.new(@new_resource.name)
  #secrets-lwrp is the name of my cookbook.  chef will convert the name to a class so it becomes SecretsLwrp.  This is because there is a '-'
  #If I were to create something other than default, say service.rb in my provider/resource.  This would then be SecretsLwrpService.new and you
  #would access it in your recipes with secrets_lwrp_service.

  #A common step is to load the current_resource instance variables with what is established in the new_resource.
  #What is passed into new_resouce via our recipes, is not automatically passed to our current_resource.
  @current_resource.user(@new_resource.user)  #DSL converts our parameters/attrbutes to methods to get and set the instance variable inside the Provider and Resource.
  @current_resource.group(@new_resource.group)
  @current_resource.shared_dir(@new_resource.shared_dir)
  @current_resource.secret_keys(@new_resource.secret_keys)
  @current_resource.recursive(@new_resource.recursive)

  #Get current state
  # @current_resource.exists = ::File.file?("/var/#{ @new_resource.name }")

end
