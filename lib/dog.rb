class Dog
   attr_accessor :id, :name, :breed

   def initialize(attributes)
      unless attributes.nil?
         attributes.each do |key, value|
            send("#{key}=", value)
         end
         @id = nil unless attributes.key?(:id)
      end
   end

   def save
      if id
         update
      else
         sql = <<-SQL
         INSERT INTO dogs (name, breed)
         VALUES (?, ?)
         SQL

         DB[:conn].execute(sql, name, breed)
         id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
         Dog.find_by_id(id)
      end
   end

   def update
      sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?'
      DB[:conn].execute(sql, name, breed, id)
   end

   def self.find_or_create_by(attributes)
      dog = Dog.find_by_name(attributes[:name])
      dog.breed == attributes[:breed] ? dog : Dog.create(attributes)
   end

   def self.create(attributes)
      dog = new(attributes)
      dog.save
   end

   def self.new_from_db(row)
      attributes = { id: row[0], name: row[1], breed: row[2] }
      new(attributes)
   end

   def self.find_by_name(name)
      sql = <<-SQL
         SELECT * from dogs
         WHERE name = ?
      SQL
      Dog.new_from_db(DB[:conn].execute(sql, name).flatten)
   end

   def self.find_by_id(id)
      sql = <<-SQL
         SELECT * from dogs
         WHERE id = ?
      SQL
      Dog.new_from_db(DB[:conn].execute(sql, id).flatten)
   end

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
end
