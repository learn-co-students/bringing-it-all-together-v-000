class Dog
	attr_accessor :name, :breed
	attr_reader :id

	def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
	end

  def self.table_name
	   "#{self.to_s.downcase}s"
  end

   def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS #{self.table_name} (
       id INTEGER PRIMARY KEY,
       name TEXT,
       album TEXT
     );
    SQL

    DB[:conn].execute (sql)
  end

  def self.drop_table
	   DB[:conn].execute("DROP TABLE IF EXISTS #{self.table_name}")
  end

  def save
      if self.id  # check if record already exists, to prevent duplicate insertions
         self.update
      else
          sql = <<-SQL
            INSERT INTO #{self.class.table_name} (name, breed)
            VALUES (?, ?)
          SQL
          DB[:conn].execute(sql, self.name, self.breed)

          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")[0][0]
      end
      self
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.find_by_id(find_id)
    sql = <<-SQL
      SELECT * from #{self.table_name} WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, find_id)[0]

    self.new_from_db(row)
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row [1], breed: row [2])
  end

  def self.find_or_create_by(name:, breed:)
    row = DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ? AND breed = ?", name, breed)
    if !row.empty? # prevent record duplication
      row_data = row[0]
      new_dog = self.new(id: row_data[0], name: row_data[1], breed: row_data[2])
    else
      new_dog = self.create(name: name, breed: breed)
    end
    new_dog
  end

   def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    row = DB[:conn].execute(sql, name)[0]

    self.new_from_db(row)
  end

  def update
    # update all attributes based on the unique ID
    sql = <<-SQL
      UPDATE #{self.class.table_name}
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
