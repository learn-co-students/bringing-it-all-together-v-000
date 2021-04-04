
class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end 

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dog (
        
    )
  end
    
end