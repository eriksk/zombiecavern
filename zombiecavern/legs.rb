module ZombieCavern
	class Legs

		def initialize game, interval
			@current_leg = 0
			@timer = Timer.new interval, lambda{
				@current_leg = @current_leg == 0 ? 1 : 0
			}
			@textures = [
				game.load_image('legs_1'),
				game.load_image('legs_2')
			]
		end

		def update dt
			@timer.update dt
		end

		def draw position, rotation
			@textures[@current_leg].draw_rot(position.x, position.y, 0.0, rotation.to_degrees)
		end
	end
end