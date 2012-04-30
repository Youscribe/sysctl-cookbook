#
# Cookbook Name:: sysctl
# Provider:: sysctl
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


action :save do
  file new_resource.path do
    notifies :start, 'service[procps]'
    content "#{new_resource.variable} = #{new_resource.value}\n"
    owner 'root'
    group 'root'
    mode '0644'
  end
  new_resource.updated_by_last_action(true)
end


action :set do
  execute 'set sysctl' do
    command "sysctl #{new_resource.variable}=#{new_resource.value}"
  end
  new_resource.updated_by_last_action(true)
end


action :remove do
  file new_resource.path do
    action :delete
  end
  new_resource.updated_by_last_action(true)
end


private
def path
  new_resource.path ? new_resource.path : "/etc/sysctl.d/40-#{new_resource.name}.conf"
end


private
def variable
  return new_resource.variable ? new_resource.variable : new_resource.name
end
