module ZombieCavern
	class MessageBox

		attr_accessor

		def initialize font
			@font = font
			@text = ""
			@duration = 3000
			@current = @duration
		end

		def show_message text
			@text = text
			@current = 0.0
		end

		def update dt
			@current += dt
		end

		def draw
			if @current < @duration
				factor = ZombieCavern::lerp(1.2, 0, @current / @duration)
				@font.draw_rel(@text, $WIDTH / 2.0, 128, 0, 0.5, 0.5, factor, factor)
			end
		end
	end
end