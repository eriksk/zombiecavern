module ZombieCavern
	class Zombie < Entity

		attr_accessor :health, :type		
		TYPES = [:normal, :runner, :brute]

		def initialize texture, type, game
			super(texture)
			@type = type

			@legs = Legs.new(game, 200)
			case type
				when :normal
					@speed = 0.05
					@health = 10
				when :runner
					@speed = 0.2
					@health = 2
				when :brute
					@speed = 0.03
					@health = 20
				else
					@speed = 0.05
					@health = 10
			end
			@life_time = 0.0
		end

		def update dt, player			
			target_angle = Math::atan2(player.position.y - @position.y, player.position.x - @position.x)
			@life_time += dt
			# wiggle
			if @type == :normal 
				#target_angle += Math::sin(@life_time * 0.02) / 2.0
			end
			if @type == :runner 
				#target_angle += Math::sin(@life_time * 0.03) / 2.0
			end
			if @type == :brute 
				#target_angle += Math::sin(@life_time * 0.01) / 2.0
			end
			@position.x += Math::cos(target_angle) * @speed * dt
			@position.y += Math::sin(target_angle) * @speed * dt
			@rotation = target_angle
			@legs.update dt
		end

		def before_draw
			@legs.draw @position, @rotation
		end
	end
end