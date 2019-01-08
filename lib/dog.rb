class Dog
  
  attr_accessor :name, :breed, :id
  
  def initialize(row)  
    @name= row[:name]
    @breed= row[:breed]
    @id= row[:id]
  end
  
  def self.create_table
  
  end
  
  
  
  
  
end  