module ZombieCavern
	class Vec2

		attr_accessor :x, :y
		
		def initialize x = 0, y = 0
			@x, @y = x, y
		end

		def clone
			Vec2.new(@x, @y)
		end

		def * scalar
			@x *= scalar
			@y *= scalar
			self
		end
	end
end