module ZombieCavern
	class Bullet < Entity

		attr_accessor :velocity
		
		def initialize texture
			super(texture)
			@velocity = Vec2.new
		end

		def update dt
			@position.x += @velocity.x * dt
			@position.y += @velocity.y * dt
		end
	end
end