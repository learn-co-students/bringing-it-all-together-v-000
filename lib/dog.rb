class Dog

  attr_accessor :name, :breed, :id

    def initialize(attributes)
      self.id = nil
      attributes.each {|key, value| self.send("#{key}=", value)}
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end

    def drop_table
    end

end
