class Dog
  attr_accessor :name, :breed, :id

  def initialize(attrs, id: nil)
    attrs.each { |k,v| self.send("#{k}=", v) }
    @id = id
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
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
    if !id.nil?
      update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?);"
      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
  end

  def self.create(args)
    dog = Dog.new(args)
    dog.save
    dog
  end

  def self.new_from_db(row)
    name = row[1]
    breed = row[2]
    dog = Dog.new(name: name, breed: breed)
    dog.id = row[0]
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    DB[:conn].execute(sql, id).map { |row| new_from_db(row) }.first
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    DB[:conn].execute(sql, name).map { |row| new_from_db(row) }.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    dog = DB[:conn].execute(sql, name, breed)
    if dog.empty?
      create({name: name, breed: breed})
    else
      dog_attrs = dog[0]
      dog = Dog.new({name: dog_attrs[1], breed: dog_attrs[2]})
      dog.id = dog_attrs[0]
      dog
    end
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, name, breed, id)
  end
end












