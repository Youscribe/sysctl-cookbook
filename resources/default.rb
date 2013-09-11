#
# Cookbook Name:: sysctl
# Resources:: default
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

def initialize(*args)
  super
  @action = :save

  unless node.recipe?("sysctl::default")
    @run_context.include_recipe "sysctl::default"
  end
end

actions :save, :set, :remove

attribute :name, :kind_of => String, :name_attribute => true
attribute :variable, :kind_of => String, :default => nil
attribute :value, :kind_of => String, :required => true
attribute :path, :kind_of => String, :default => nil
attribute :priority, :kind_of => String, :default => "40"
attribute :cookbook, :kind_of => String, :default => "sysctl"
attribute :source, :kind_of => String, :default => "sysctl.conf.erb"
