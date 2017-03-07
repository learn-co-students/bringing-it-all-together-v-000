class Dog

	attr_accessor :id,:name,:breed

	def initialize(id: id=nil, name: name, breed: breed)
		@id=id
		@name=name
		@breed=breed	
	end

	def self::create_table
#		DB[:conn].execute('CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)')	
	end

	def self::drop_table
		DB[:conn].execute('DROP TABLE IF EXISTS dogs')
	end

	def save
		DB[:conn].execute('INSERT INTO dogs (name, breed) VALUES (?,?)',self.name,self.breed)
		@id=DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
		self
	end

	def self::create(hash)
		self.new(hash).save
	end

	def self::find_by_id(id)
		result = DB[:conn].execute('SELECT * FROM dogs WHERE id = ?', id)[0]
		self.new(id: result[0], name: result[1], breed: result[2])
	end

	def self::find_or_create_by(name: name, breed: breed)
		id=DB[:conn].execute('SELECT id FROM dogs WHERE name = ? AND breed = ?', name, breed)[0]
		if nil!=id
			self.find_by_id(id)
		else
			self.new(name: name, breed: breed).save
		end
	end

	def self::new_from_db(row)
		self.new(id:row[0],name:row[1],breed:row[2])
	end

	def self::find_by_name(name)
		sql='SELECT * FROM dogs WHERE name = ? LIMIT 1'
		result = DB[:conn].execute(sql, name)[0]
		self.new_from_db(result)
	end

	def update
		DB[:conn].execute('UPDATE dogs SET name = ?, breed = ? WHERE id = ?', self.name, self.breed, self.id)
	end

end
	
