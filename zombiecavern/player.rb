module ZombieCavern
	class Player < Entity

		attr_accessor :current_weapon, :weapons

		def initialize texture, game
			super(texture)
			@game = game
			@speed = 0.001
			@velocity = Vec2.new

			@weapons = {
				:gun => Weapon.new(game.load_sound('fire_gun'), :gun, 100, -1, 5),
				:smg => Weapon.new(game.load_sound('fire_smg'), :smg, 30, 500, 1, 0.2),
				:cannon => Weapon.new(game.load_sound('fire_cannon'), :cannon, 1000, 10, 100, 0)
			}
			@current_weapon = :gun
		end

		def reset
			@weapons.each do |k, v|
				v.reload
			end
		end

		def switch_weapon weapon
			if @current_weapon != weapon
				@game.sound_manager.play(:switch_weapon, 1.5)
				@current_weapon = weapon
			end	
		end

		def selected_weapon_index
			@weapons.each_with_index do |(k, v), index|
				if k == @current_weapon
					return index
				end
			end
			return 0
		end

		def update dt

			# switch weapons
			if @game.button_down? Gosu::Kb1
				switch_weapon(:gun)
			elsif @game.button_down? Gosu::Kb2
				switch_weapon(:smg)
			elsif @game.button_down? Gosu::Kb3
				switch_weapon(:cannon)
			end

			@weapons[@current_weapon].update(dt)

			# input
			if @game.button_down?Gosu::KbA
				@velocity.x -= @speed * dt
			end
			if @game.button_down?Gosu::KbD
				@velocity.x += @speed * dt
			end
			if @game.button_down?Gosu::KbW
				@velocity.y -= @speed * dt
			end
			if @game.button_down?Gosu::KbS
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
				@position.y = $HEIGHT
				@velocity.y *= -1
			end

			# bullets
			if @game.button_down? Gosu::MsLeft
				@rotation = Math::atan2(@game.mouse_y - position.y, 
									   @game.mouse_x - position.x)	
				if @weapons[@current_weapon].fire(@game.bullet_manager, @position, @rotation)
					@weapons[@current_weapon].sound.play()
				end
			elsif @game.button_down?(Gosu::KbLeft) || @game.button_down?(Gosu::KbRight) || @game.button_down?(Gosu::KbUp) || @game.button_down?(Gosu::KbDown)
				if @game.button_down? Gosu::KbLeft
					@rotation = -180.to_radians
					if @game.button_down? Gosu::KbUp
						@rotation += 45.to_radians
					elsif @game.button_down? Gosu::KbDown
						@rotation -= 45.to_radians 
					end						
				elsif @game.button_down? Gosu::KbRight
					rotation = 0.to_radians
					if @game.button_down? Gosu::KbUp
						@rotation -= 45.to_radians
					elsif @game.button_down? Gosu::KbDown
						@rotation += 45.to_radians 
					end						
				elsif @game.button_down? Gosu::KbUp
					@rotation = -90.to_radians
				elsif @game.button_down? Gosu::KbDown
					@rotation = 90.to_radians
				end
				if @weapons[@current_weapon].fire(@game.bullet_manager, @position, @rotation)
					@weapons[@current_weapon].sound.play()
				end
			end
		
		end
	end
end