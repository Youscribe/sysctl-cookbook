#
# Cookbook Name:: sysctl
# Recipe:: default
#
# Copyright 2011, Fewbytes Technologies LTD
#


service 'procps'


# TODO(Youscribe) change this by something more "clean".
execute 'remove old files' do
  command 'rm --force /etc/sysctl.d/50-chef-attributes-*.conf'
  action :run
end


if node.attribute?('sysctl')
  node['sysctl'].each do |item|
    f_name = item.first.gsub(' ', '_')
    template "/etc/sysctl.d/50-chef-attributes-#{f_name}.conf" do
      notifies :start, "service[procps]", :immediately
      source 'sysctl.conf.erb'
      mode '0644'
      owner 'root'
      group 'root'
      variables(:instructions => item[1])
    end
  end
end


cookbook_file '/etc/sysctl.d/50-chef-static.conf' do
  notifies :start, 'service[procps]'
  ignore_failure true
  mode '0644'
end
