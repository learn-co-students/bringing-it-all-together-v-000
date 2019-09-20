class Dog

  attr_accessor :name, :breed, :id

def initialize(id: nil, name:, breed:)
  @name = name
  @breed = breed
end

def self.create_table
<<-SQL
  CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);
  SQL
end

end
