class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.drop_table
     sql = <<-SQL
     DROP TABLE IF EXISTS dogs
     SQL
     DB[:conn].execute(sql)
  end

end
