module ZombieCavern
	class Bullet < Entity

		attr_accessor :velocity, :damage
		
		def initialize texture
			super(texture)
			@velocity = Vec2.new
			@damage = 1
		end

		def update dt
			@position.x += @velocity.x * dt
			@position.y += @velocity.y * dt
		end
	end
end