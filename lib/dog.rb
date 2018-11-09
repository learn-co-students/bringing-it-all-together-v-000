 class Dog
   attr_accessor :name, :breed
   attr_reader :id

   def initialize(name:, breed:, id: nil)
     @id = id
     @name = name
     @breed = breed
   end

   def save
     if self.id
       self.update
     else
       sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES(?, ?)
            SQL
       DB[:conn].execute(sql, self.name, self.breed)
       @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten.first
     end
      self
   end

   def update
     sql = <<-SQL
          UPDATE dogs
          SET name = ?, breed = ?
          WHERE id = ?
          SQL
     DB[:conn].execute(sql, self.name, self.breed, self.id)
   end

# class methods
   def self.create_table
     sql = <<-SQL
          CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
          )
          SQL
     DB[:conn].execute(sql)
   end

   def self.drop_table
     sql = <<-SQL
          DROP TABLE dogs
          SQL
    DB[:conn].execute(sql)
   end

   def self.create(new_dog)
     dog = self.new(new_dog)
     dog.save
   end

   def self.new_from_db(row)
     self.new(id: row[0], name: row[1], breed: row[2])
   end

   def self.find_by_id(id)
     sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE id = ?
          SQL
    DB[:conn].execute(sql, id).map do |row|
      new_from_db(row)
    end.first
   end

   def self.find_by_name(name)
     sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?
          SQL
    DB[:conn].execute(sql, name).map do |row|
      new_from_db(row)
    end.first
   end

   def self.find_or_create_by(new_dog)
     dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", new_dog[:name], new_dog[:breed])
    if !dog.empty?
      dog_data = dog.first
      dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(new_dog)
    end
     dog
   end
 end
