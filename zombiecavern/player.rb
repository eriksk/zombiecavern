module ZombieCavern
	class Player < Entity

		def initialize texture
			super(texture)
			@speed = 0.001
			@velocity = Vec2.new
		end

		def update dt

			# input
			if $game.button_down?Gosu::KbA
				@velocity.x -= @speed * dt
			end
			if $game.button_down?Gosu::KbD
				@velocity.x += @speed * dt
			end
			if $game.button_down?Gosu::KbW
				@velocity.y -= @speed * dt
			end
			if $game.button_down?Gosu::KbS
				@velocity.y += @speed * dt
			end

			@velocity.x *= 0.9
			@velocity.y *= 0.9
			@position.x += @velocity.x * dt
			@position.y += @velocity.y * dt

			# boundaries
			if @position.x < 0
				@position.x = 0
				@velocity.x *= -1
			end
			if @position.x > $WIDTH
				@position.x = $WIDTH
				@velocity.x *= -1
			end
			if @position.y < 0
				@position.y = 0
				@velocity.y *= -1
			end
			if @position.y > $HEIGHT
				@position.y = $HEIGHTw
				@velocity.y *= -1
			end
		end
	end
end