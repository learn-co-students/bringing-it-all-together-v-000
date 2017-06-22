class Dog
  attr_accessor :name, :breed
  attr_reader :id
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
  sql = <<-SQL
  DROP TABLE dogs;
  SQL

  DB[:conn].execute(sql)
  end

  def save
      if self.id
        self.update
      else
        sql = <<-SQL
          INSERT INTO dogs(name, breed)
          VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
      end
  end

  def self.create(hash)
    #binding.pry
    dog_instance = self.new(hash)
    dog_instance.save
    #binding.pry
  end

  def self.new_from_db(row)
    object_instance = self.new(row[0], row[1], row[2])
    object_instance
  end

  def self.find_by_name(name)
    sql = "SELECT id, name, breed FROM dogs WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end
  end

  def self.find_by_id(id_num)
    #binding.pry
    sql = "Select id From dogs WHERE id = ?"
    result = DB[:conn].execute(sql,id_num)[0]
    Dog.new(id:result[0], name:result[1], breed:result[2])
  end
end
