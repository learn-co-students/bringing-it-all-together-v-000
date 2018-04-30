class Dog
  attr_accessor :name, :breed, :id

  def initialize(params)
    @id = params[:id]
    @name = params[:name]
    @breed = params[:breed]
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      SQL

    new_from_db(DB[:conn].execute(sql, id).first)
  end

  def self.find_or_create_by(attributes)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      AND breed = ?
      SQL

    dog = DB[:conn].execute(sql, attributes[:name], attributes[:breed])
    if !dog.empty?
      dog_data = dog[0]
      new_from_db(dog_data)
    else
      dog = self.create(attributes)
    end
  end

  def self.new_from_db(row)
    dog_attributes = {
      :id => row[0],
      :name => row[1],
      :breed => row[2]
    }
    dog = Dog.new(dog_attributes)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      SQL
      dog = (DB[:conn].execute(sql, name))
      new_from_db(dog[0])
  end

  def update
   sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
   DB[:conn].execute(sql, self.name, self.breed, self.id)
 end

end
