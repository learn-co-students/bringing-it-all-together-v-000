require_relative "../config/environment.rb"

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
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
      )
      SQL

      DB[:conn].execute(sql)
  end


  def self.drop_table
      DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if self.id != nil
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

      self
    end
  end

  def self.create(attributes)
    new_dog_attributes = attributes.each {|k,v| instance_variable_set("@#{k}",v)} #k=key, v=value
    new_dog = self.new(new_dog_attributes)
    new_dog.save #save the new dog
    new_dog #call on the new dog
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map do |row|
    self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
        if !dog.empty?
          dog_data = dog[0]
          dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
      end

      def self.find_by_name(name)
        sql = <<-SQL
       SELECT *
       FROM dogs
       WHERE name = ?
     SQL

     DB[:conn].execute(sql, name).map do |row|
       self.new_from_db(row)
     end.first
   end

   def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end


  end
