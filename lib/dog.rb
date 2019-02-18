class Dog 
  attr_accessor :name, :breed, :id
  
  def initialize(name, breed, id = nil)
    @name = name
    @breed = breed 
    @id = id
  end
  
  def self.create_table
  end
  
  def self.drop_table
  end
  
  def save
end

  def self.create
  end
  
  def self.find_by_id(id)
  end

  def self.find_or_create_by
  end 
end 