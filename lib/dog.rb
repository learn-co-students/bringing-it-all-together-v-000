class Dog
  ATTRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :name => "TEXT",
    :breed => "TEXT"
  }

  ATTRIBUTES.keys.each do |attribute_name|
    attr_accessor attribute_name
  end

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end



end
