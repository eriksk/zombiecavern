module ZombieCavern
	class Weapon

		attr_accessor

		def initialize interval, damage = 1, spread = 0.0
			@current = 0.0
			@interval = interval
			@spread = spread
			@damage = damage
		end

		def fire bullet_manager, position, angle
			if @current > @interval
				@current = 0.0
				angle += (-0.5 + rand()) * @spread
				bullet_manager.fire(
					position.clone, 
					Vec2.new(Math::cos(angle), Math::sin(angle)) * 0.5,
					@damage
				)
			end
		end

		def reload
			@current = @interval + 1
		end

		def dps
			(@interval / @damage) * 60.0
		end

		def update dt
			@current += dt
		end
	end
end