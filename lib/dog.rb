class Dog
  attr_accessor :name, :breed, :id

  def initialize(hash)
  	@name = hash[:name]
  	@breed = hash[:breed]
  	@id = hash[:id] || nil
  end

  def self.create_table
  	sql = <<-SQL
  		CREATE TABLE dogs(
  		id INTEGER PRIMARY KEY, 
  		name TEXT, 
  		breed TEXT
  		)
  		SQL
  	#DB[:conn].execute(sql)
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
  	dog_array = DB[:conn].execute(sql, id)[0]
  	Dog.new_from_db(dog_array)
  end

  def self.drop_table
  	sql = <<-SQL
  		DROP TABLE dogs
  		SQL
  	DB[:conn].execute(sql)
  end

  def self.new_from_db(array)
  	dog_hash = {
  		:id => array[0],
  		:name => array[1],
  		:breed => array[2]
  	}
  	dog = Dog.new(dog_hash)
  end

  def self.find_by_name(name)
  	sql = <<-SQL
  		SELECT * FROM dogs
  		WHERE name = ?
  		SQL
  	dog_array = DB[:conn].execute(sql, name)[0]
  	Dog.new_from_db(dog_array)
  end

  def self.find_or_create_by(hash)
  	sql = <<-SQL
  		SELECT * FROM dogs
  		WHERE name = ? AND breed = ?
  		SQL
  	dog = DB[:conn].execute(sql, hash[:name], hash[:breed])
  	if !dog.empty?
  		dog_data = dog[0]
  		new_dog = Dog.new_from_db(dog_data)
  	else
  		new_dog = Dog.create(name: hash[:name], breed: hash[:breed])
  	end
  	new_dog
  end

  def save
  	sql = <<-SQL
  		INSERT INTO dogs(name, breed) 
  		VALUES (?, ?)
  		SQL
  	DB[:conn].execute(sql, self.name, self.breed)
  	@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
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
end