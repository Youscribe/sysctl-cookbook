def initialize(*args)
  super
  @action = :save
end

actions :save, :set, :remove

attribute :name, :kind_of => String, :name_attribute => true
attribute :path, :kind_of => String, :default => nil
attribute :instructions, :kind_of => Hash, :default => nil, :required => true