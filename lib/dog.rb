class Dog
  attr_accessor :id, :name, :breed

  def initialize(attr_hash)
    @id = attr_hash[id]
    @name = attr_hash[name]
    @breed = attr_hash[breed]
  end
    
  end