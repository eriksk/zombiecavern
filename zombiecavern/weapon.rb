module ZombieCavern
	class Weapon

		attr_accessor :sound, :ammo, :max_ammo

		def initialize sound, type, interval, max_ammo, damage = 1, spread = 0.0
			@current = 0.0
			@type = type
			@interval = interval
			@spread = spread
			@damage = damage
			@sound = sound
			@max_ammo = max_ammo.to_f
			@ammo = @max_ammo
		end

		def fire bullet_manager, position, angle
			if @ammo == 0
				return false
			end
			if @current > @interval
				@current = 0.0
				angle += (-0.5 + rand()) * @spread
				bullet_manager.fire(
					position.clone, 
					Vec2.new(Math::cos(angle), Math::sin(angle)) * 0.5,
					@damage,
					@type
				)
				@ammo -= 1 unless @ammo == -1
				return true
			end
			return false
		end

		def reload
			@current = @interval + 1
			fill_ammo()
		end

		def fill_ammo
			@ammo = @max_ammo
		end

		def ammo_left
			if @ammo == -1
				return 1.0
			end
			@ammo / @max_ammo
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