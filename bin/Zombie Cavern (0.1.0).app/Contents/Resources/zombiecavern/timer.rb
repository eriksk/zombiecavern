module ZombieCavern
	class Timer

		def initialize interval, callback_lambda
			@interval = interval
			@current = 0.0
			@callback = callback_lambda
		end

		def update dt
			@current += dt
			if @current > @interval
				@current = 0.0
				@callback.call()
			end
		end
	end
end