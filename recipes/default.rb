#
# Cookbook Name:: sysctl
# Recipe:: default
# Author:: Guilhem Lettron <guilhem.lettron@youscribe.com>
#
# Copyright 2012, Societe Publica.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package "fake-procps" do
  action :upgrade
  only_if { platform?("fedora") }
end

# redhat supports sysctl.d but doesn't create it by default
directory "/etc/sysctl.d" do
  owner 'root'
  group 'root'
  mode '755'
end

execute "sysctl-p" do
  command 'cat /etc/sysctl.d/*.conf /etc/sysctl.conf | sysctl -e -p -'
  action :nothing
end

sysctl "chef-attributes" do
  priority "50"
  source "chef-attributes.erb"
  value ""
end

ruby_block "zap_sysctl_d" do
  block do
    all = Dir.glob('/etc/sysctl.d/*.conf')
    @run_context.resource_collection.each do |r|
      if r.kind_of?(Chef::Resource::Sysctl) or r.kind_of?(Chef::Resource::SysctlMulti)
        name = "/etc/sysctl.d/#{r.priority}-#{r.name.gsub(' ', '_')}.conf"
        if all.delete(name)
          Chef::Log.debug("Keeping #{name}")
        end
      end
    end

    all.each do |name|
      r = Chef::Resource::File.new(name, @run_context)
      r.cookbook_name=(cookbook_name)
      r.recipe_name=(recipe_name)
      r.action(:delete)
      r.notifies(:run, "execute[sysctl-p]")
      @run_context.resource_collection << r
    end
  end
end
