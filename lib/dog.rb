require 'pry'

class Dog

  attr_accessor :name, :breed, :id

    def initialize(attributes)
      self.id = nil
      attributes.each {|key, value| self.send("#{key}=", value)}
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end

    def self.drop_table
      DB[:conn].execute("DROP TABLE dogs;")
    end

    def save

      sql = <<-SQL
      INSERT INTO dogs
      (name, breed)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

      self
    end

    def self.create(attributes)
      Dog.new(attributes).tap{|dog| dog.save}
    end

    def self.find_by_id(id)

      sql = <<-SQL
      SELECT (*)
      FROM dogs
      WHERE id = ?;
      SQL

      DB[:conn].execute(sql, id)

end
