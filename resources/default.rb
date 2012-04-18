def initialize(*args)
  super
  @action = :set
end

actions :set, :remove

attribute :variable, :kind_of => String, :name_attribute => true
attribute :value, :kind_of => String, :required => true
attribute :instructions, :kind_of => Hash, :default => nil
attribute :save, :kind_of => [ TrueClass, FalseClass ], :default => true