module ZombieCavern
	class Particle < Entity

		attr_accessor :velocity
		
		def initialize texture, duration
			super(texture)
			@velocity = Vec2.new
			@duration = duration
			@current = 0.0
		end

		def alive
			@current <= @duration
		end

		def update dt
			@current += dt
			@position.x += ZombieCavern::lerp(@velocity.x, 0.0, @current / @duration)
			@position.y += ZombieCavern::lerp(@velocity.y, 0.0, @current / @duration)
			@scale = ZombieCavern::lerp(2.0, 0.2, @current / @duration)
		end
	end
end