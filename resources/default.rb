def initialize(*args)
  super
  @action = :save
end

actions :save, :set, :remove

attribute :name, :kind_of => String, :name_attribute => true
attribute :variable, :kind_of => String, :default => nil
attribute :value, :kind_of => String, :required => true
attribute :path, :kind_of => String, :default => nil