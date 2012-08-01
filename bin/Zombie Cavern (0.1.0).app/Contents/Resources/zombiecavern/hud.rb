module ZombieCavern
	class Hud

		attr_accessor :message_box
		
		def initialize game 
			@game = game

			@font = Gosu::Font.new(game, Gosu::default_font_name, 18)
			@large_font = Gosu::Font.new(game, Gosu::default_font_name, 64)
			@message_box = MessageBox.new(@large_font)

			@reload_bar_tex = game.load_image('reload_bar')
			@reload_bar_fill_tex = game.load_image('reload_bar_fill')

			@guns_tex = game.load_image('guns')
			@selected_weapon_tex = game.load_image('selected_weapon')
			@cover_color = Gosu::Color::BLACK
			@cover_color.alpha = 150

			@time = 0.0
		end
		
		def update dt
			@message_box.update dt
			@time += dt
		end

		def draw		
			@guns_tex.draw(16, 16, 0)
			@selected_weapon_tex.draw(16 + (16 * @game.player.selected_weapon_index), 16, 0)

			# reload
			@reload_bar_tex.draw(16, 42, 0)
			@reload_bar_fill_tex.draw_rot(17, 43, 0, 0, 0.0, 0.0, @game.player.weapons[@game.player.current_weapon].progress * 2.0, 1.0)
			
			# ammo
			@reload_bar_tex.draw(16, 64, 0)
			@reload_bar_fill_tex.draw_rot(17, 65, 0, 0, 0.0, 0.0, @game.player.weapons[@game.player.current_weapon].ammo_left * 2.0, 1.0)

			@font.draw("DPS: #{@game.player.weapons[@game.player.current_weapon].dps.to_i}", 16, 86, 0)

			@font.draw_rel("Time: #{(@game.total_time / 1000).to_i}", $WIDTH - 16, 16, 0, 1.0, 0.0)
			@font.draw_rel("Zombies killed: #{@game.kill_count}", $WIDTH - 16, 32, 0, 1.0, 0.0)
			@font.draw_rel("Wave: #{@game.zombie_manager.wave}", $WIDTH - 16, 48, 0, 1.0, 0.0)

			if @game.paused
				@game.draw_quad(
			     0,     0,      @cover_color,
			     $WIDTH, 0,      @cover_color,
			     0,     $HEIGHT, @cover_color,
			     $WIDTH, $HEIGHT, @cover_color,
			     0)
				@large_font.draw_rel("Paused", $WIDTH / 2.0, $HEIGHT / 2.0, 0, 0.5, 0.5)
			else
				@message_box.draw	
			end		
		end

		def draw_start_screen
			scale = 0.8 + Math::sin(@time * 0.005) * 0.2

			@large_font.draw_rel("Zombie Cavern", $WIDTH / 2.0, 100, 0, 0.5, 0.5, scale, scale)
			@font.draw_rel("Controls:", $WIDTH / 2.0, 150, 0, 0.5, 0.5)

			@font.draw_rel("W, A, S, D - ", $WIDTH / 2.0, 170, 0, 1.0, 0.5)
			@font.draw_rel("Move", $WIDTH / 2.0, 170, 0, 0.0, 0.5)
			@font.draw_rel("Mouse - ", $WIDTH / 2.0, 186, 0, 1.0, 0.5)
			@font.draw_rel("Aim & Shoot", $WIDTH / 2.0, 186, 0, 0.0, 0.5)
			@font.draw_rel("1, 2, 3, 4 ... - ", $WIDTH / 2.0, 204, 0, 1.0, 0.5)
			@font.draw_rel("Change weapons", $WIDTH / 2.0, 204, 0, 0.0, 0.5)
			@font.draw_rel("Goal:", $WIDTH / 2.0, 244, 0, 0.5, 0.5)
			@font.draw_rel("SURVIVE", $WIDTH / 2.0, 262, 0, 0.5, 0.5)

			@large_font.draw_rel("Press SPACE to start", $WIDTH / 2.0, 300, 0, 0.5, 0.5, scale, scale)
		end
	end
end