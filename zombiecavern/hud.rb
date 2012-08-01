module ZombieCavern
	class Hud

		attr_accessor :message_box
		
		def initialize game 
			@game = game

			@font = Gosu::Font.new(game, Gosu::default_font_name, 18)
			large_font = Gosu::Font.new(game, Gosu::default_font_name, 64)
			@message_box = MessageBox.new(large_font)

			@reload_bar_tex = game.load_image('reload_bar')
			@reload_bar_fill_tex = game.load_image('reload_bar_fill')

			@guns_tex = game.load_image('guns')
			@selected_weapon_tex = game.load_image('selected_weapon')
		end
		
		def update dt
			@message_box.update dt
		end

		def draw		
			@guns_tex.draw(16, 16, 0)
			@selected_weapon_tex.draw(16 + (16 * @game.player.selected_weapon_index), 16, 0)

			@reload_bar_tex.draw(16, 42, 0)
			@reload_bar_fill_tex.draw_rot(17, 43, 0, 0, 0.0, 0.0, @game.player.weapons[@game.player.current_weapon].progress * 2.0, 1.0)

			@font.draw("DPS: #{@game.player.weapons[@game.player.current_weapon].dps.to_i}", 16, 60, 0)

			@font.draw_rel("Time: #{(@game.total_time / 1000).to_i}", $WIDTH - 16, 16, 0, 1.0, 0.0)
			@font.draw_rel("Zombies killed: #{@game.kill_count}", $WIDTH - 16, 32, 0, 1.0, 0.0)
			@font.draw_rel("Wave: #{@game.zombie_manager.wave}", $WIDTH - 16, 48, 0, 1.0, 0.0)

			@message_box.draw			
		end
	end
end