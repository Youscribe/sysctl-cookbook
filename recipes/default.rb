#
# Cookbook Name:: sysctl
# Recipe:: default
#
# Copyright 2011, Fewbytes Technologies LTD
#

#TODO change this by something more "clean".
execute "remove old files" do
  command "rm /etc/sysctl.d/50-chef-attributes-*.conf"
  action :run
end

if node.attribute?(:sysctl)
  node[:sysctl].each do |item|
    template "/etc/sysctl.d/50-chef-attributes-#{item[0].gsub(" ", "_")}.conf" do
      source "sysctl.conf.erb"
      mode "0644"
      owner "root"
      group "root"
      variables(
        :instructions => item[1]
      )
      notifies :start, "service[procps]"
    end
  end
end

cookbook_file "/etc/sysctl.d/50-chef-static.conf" do
  ignore_failure true
  mode "0644"
  notifies :start, "service[procps]"
end

service "procps"
