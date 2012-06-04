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
