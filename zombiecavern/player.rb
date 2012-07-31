module ZombieCavern
	class Player < Entity

		attr_accessor :current_weapon, :weapons

		def initialize texture, game
			super(texture)
			@speed = 0.001
			@velocity = Vec2.new

			@weapons = {
				:gun => Weapon.new(game.load_sound('fire_gun'), :gun, 100, 5),
				:smg => Weapon.new(game.load_sound('fire_smg'), :smg, 30, 1, 0.2),
				:cannon => Weapon.new(game.load_sound('fire_cannon'), :cannon, 1000, 100, 0)
			}
			@current_weapon = :smg
		end

		def reset
			@weapons.each do |k, v|
				v.reload
			end
		end

		def switch_weapon weapon
			@current_weapon = weapon
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
			@weapons[@current_weapon].update(dt)

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
				@position.y = $HEIGHT
				@velocity.y *= -1
			end
		end
	end
end