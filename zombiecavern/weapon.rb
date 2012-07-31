module ZombieCavern
	class Weapon

		attr_accessor :sound

		def initialize sound, type, interval, damage = 1, spread = 0.0
			@current = 0.0
			@type = type
			@interval = interval
			@spread = spread
			@damage = damage
			@sound = sound
		end

		def fire bullet_manager, position, angle
			if @current > @interval
				@current = 0.0
				angle += (-0.5 + rand()) * @spread
				bullet_manager.fire(
					position.clone, 
					Vec2.new(Math::cos(angle), Math::sin(angle)) * 0.5,
					@damage,
					@type
				)
				return true
			end
			return false
		end

		def reload
			@current = @interval + 1
		end

		def progress
			if @current > @interval
				return 1.0
			else
				@current / @interval
			end
		end

		def dps
			(@interval / @damage) * 60.0
		end

		def update dt
			@current += dt
		end
	end
end