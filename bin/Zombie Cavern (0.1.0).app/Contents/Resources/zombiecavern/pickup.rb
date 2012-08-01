module ZombieCavern
	class Pickup < Entity

		attr_accessor :type

		def initialize textures, type
			super(textures[0])
			@textures = textures
			@type = type
			@color = Gosu::Color::WHITE
			@duration = 0.0
		end

		def pickup player
			case @type
				when 0
					player.add_ammo(:gun)
				when 1
					player.add_ammo(:smg)
				when 2
					player.add_ammo(:cannon)
				when 3 
					# player.add_ammo(:granade)
				else
			end
		end

		def update dt
			@duration += dt
			@rotation = Math::sin(@duration * 0.005) * 0.5
			@scale = (2.0 + Math::sin(@duration * 0.008)) * 0.5 
		end

		def draw
			@textures[type].draw_rot(@position.x, @position.y, 0.0, @rotation.to_degrees, @origin.x, @origin.y, @scale, @scale)
		end
	end
end