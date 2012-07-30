module ZombieCavern
	class Zombie < Entity

		def initialize texture
			super(texture)
			@speed = 0.05
		end

		def update dt, player
			
			target_angle = Math::atan2(player.position.y - @position.y, player.position.x - @position.x)
			@position.x += Math::cos(target_angle) * @speed * dt
			@position.y += Math::sin(target_angle) * @speed * dt
			@rotation = target_angle
		end
	end
end