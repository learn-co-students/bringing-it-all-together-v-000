class Dog

  attr_accessor :id, :name, :breed

  def initialize(hash)
      @id = hash[:id]
      @name = hash[:name]
      @breed = hash[:breed]
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE dogs ( id INTEGER PRIMARY KEY, name TEXT, breed TEXT );")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?,?)"
    DB[:conn].execute(sql, name, breed)
  end

end
