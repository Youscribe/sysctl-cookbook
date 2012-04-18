#
# Cookbook Name:: sysctl
# Provider:: sysctl
# Author:: Guilhem Lettron <guilhem.lettron@youscribe.com>
#
# Copyright 20012, Societe Publica.
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

action :set do
  if ! new_resource.instructions
    execute "set sysctl" do
      command "sysctl #{new_resource.variable}={new_resource.value}"
    end
    if new_resource.save
      file "/etc/sysctl.d/69-#{new_resource.name_attribute.gsub(" ", "_")}.conf" do
        content "#{new_resource.variable} = {new_resource.value}"
        owner "root"
        group "root"
        mode "0644"
        notifies :start, "service[procps]"
      end
    end
  else
    new_resource.instructions.each do |variable , value|
      execute "set sysctl" do
        command "sysctl #{variable}={value}"
      end
    end
    if new_resource.save
      template "/etc/sysctl.d/69-#{new_resource.name_attribute.gsub(" ", "_")}.conf" do
        source "69-sysctl.conf.erb"
        owner "root"
        group "root"
        mode "0644"
        variables(
          :instructions => new_resource.instructions,
          :name => new_resource.name_attribute
          )
        notifies :start, "service[procps]"
      end
    end
  end
end

action :remove do
  if #{new_resource.save}
    file "/etc/sysctl.d/69-#{new_resource.name_attribute.gsub(" ", "_")}.conf" do
      action :delete
    end
  end
end

service "procps"