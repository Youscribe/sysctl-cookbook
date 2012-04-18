#
# Cookbook Name:: sysctl
# Recipe:: default
#
# Copyright 2011, Fewbytes Technologies LTD
#

if node.attribute?(:sysctl)
  node[:sysctl].each do |name, instructions|
    template "/etc/sysctl.d/50-chef-attributes-#{name.gsub(" ", "_")}.conf" do
      source "sysctl.conf.erb"
      mode "0644"
      owner "root"
      group "root"
      variables (
        :instructions => instructions
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
