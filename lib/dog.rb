class DOG

	attr_accessor :name, :breed, :id

	def initialize(hash)
		hash.each {|key, value| self.send(("#{key}="), value)}
	end


end