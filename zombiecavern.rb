require 'gosu'
require_relative 'zombiecavern/helpers'
require_relative 'zombiecavern/entity'
require_relative 'zombiecavern/player'
require_relative 'zombiecavern/zombie'
require_relative 'zombiecavern/vec2'
require_relative 'zombiecavern/bullet'
require_relative 'zombiecavern/bullet_manager'
require_relative 'zombiecavern/particle'
require_relative 'zombiecavern/particle_manager'
require_relative 'zombiecavern/timer'
require_relative 'zombiecavern/weapon'
require_relative 'zombiecavern/zombie_manager'
require_relative 'zombiecavern/blood_splat'
require_relative 'zombiecavern/message_box'

$WIDTH = 800
$HEIGHT = 600

module ZombieCavern
	class Game < Gosu::Window


		def initialize
			super $WIDTH, $HEIGHT, false
			self.caption = "Zombie Cavern"

			@font = Gosu::Font.new(self, Gosu::default_font_name, 18)

			@total_time = 0.0
			@kill_count = 0

			@bg = load_image('bg')
			@filter = load_image('filter')

			@corsair = load_image('corsair')
			@corsair_rotation = 0.0

			@player = Player.new(load_image('player'), self)
			@player.position.x = $WIDTH / 2.0
			@player.position.y = $HEIGHT / 2.0

			@bullet_textures = {
				:gun => load_image('bullet_gun'),
				:smg => load_image('bullet_smg'),
				:cannon => load_image('bullet_cannon'),
			}
			@bullet_manager = BulletManager.new(@bullet_textures)
			@particle_manager = ParticleManager.new(load_image('particle'))
			zombie_textures = {
				:normal => load_image('zombie'),
				:runner => load_image('zombie_runner'),
				:brute => load_image('zombie_brute'),
			}
			@zombie_manager = ZombieManager.new(zombie_textures)

			@guns_tex = load_image('guns')
			@selected_weapon_tex = load_image('selected_weapon')

			@splat_tex = load_image('splat')
			@splats = []

			@reload_bar_tex = load_image('reload_bar')
			@reload_bar_fill_tex = load_image('reload_bar_fill')

			@sounds = {
				:hit => load_sound('zombie_hit'),
				:switch_weapon => load_sound('switch_weapon'),
				:wilhelm_scream => load_sound('wilhelm_scream'),
				:blood_1 => load_sound('blood_1'),
				:blood_2 => load_sound('blood_2'),
			}

			@song = load_song('song', 'mp3')
			@song.volume = 0.3
			#@song.play(true)

			large_font = Gosu::Font.new(self, Gosu::default_font_name, 64)
			@message_box = MessageBox.new(large_font)

			reset()
		end

		def switch_weapon weapon
			if @player.current_weapon != weapon
				@sounds[:switch_weapon].play(1.5)
				@player.switch_weapon(weapon)		
			end	
		end

		def add_splat(position)
			@splats.push BloodSplat.new(position, rand(20.0))
		end

		def load_image name
			Gosu::Image.new(self, "content/gfx/#{name}.png", false)
		end

		def load_sound name
			Gosu::Sample.new(self, "content/audio/#{name}.wav")
		end

		def load_song name, extension = "wav"
			Gosu::Song.new(self, "content/audio/#{name}.#{extension}")
		end

		def reset
			@zombie_manager.clear
			@bullet_manager.clear
			@player.position.x = $WIDTH / 2.0
			@player.position.y = $HEIGHT / 2.0
			@splats.clear
			@player.reset
			@zombie_manager.spawn_zombies()
			@total_time = 0.0
			@kill_count = 0
			@message_box.show_message("Survive!")
		end

		def update
			if button_down? Gosu::KbEscape
				exit
			end

			dt = 16.0
			@total_time += dt
			@corsair_rotation += 0.15 * dt

			# switch weapons
			if button_down? Gosu::Kb1
				switch_weapon(:gun)
			elsif button_down? Gosu::Kb2
				switch_weapon(:smg)
			elsif button_down? Gosu::Kb3
				switch_weapon(:cannon)
			end
			
			
			# player
			@player.update dt	

			# bullets
			if button_down? Gosu::MsLeft
				@player.rotation = Math::atan2(mouse_y - @player.position.y, 
											   mouse_x - @player.position.x)	
				angle = @player.rotation
				if @player.weapons[@player.current_weapon].fire(@bullet_manager, @player.position, angle)
					@player.weapons[@player.current_weapon].sound.play()
				end
			elsif button_down?(Gosu::KbLeft) || button_down?(Gosu::KbRight) || button_down?(Gosu::KbUp) || button_down?(Gosu::KbDown)
				if button_down? Gosu::KbLeft
					@player.rotation = -180.to_radians
					if button_down? Gosu::KbUp
						@player.rotation += 45.to_radians
					elsif button_down? Gosu::KbDown
						@player.rotation -= 45.to_radians 
					end						
				elsif button_down? Gosu::KbRight
					@player.rotation = 0.to_radians
					if button_down? Gosu::KbUp
						@player.rotation -= 45.to_radians
					elsif button_down? Gosu::KbDown
						@player.rotation += 45.to_radians 
					end						
				elsif button_down? Gosu::KbUp
					@player.rotation = -90.to_radians
				elsif button_down? Gosu::KbDown
					@player.rotation = 90.to_radians
				end
				angle = @player.rotation
				if @player.weapons[@player.current_weapon].fire(@bullet_manager, @player.position, angle)
					@player.weapons[@player.current_weapon].sound.play()
				end
			end
		
			@zombie_manager.update(dt, @player)
			@bullet_manager.update dt
			@particle_manager.update dt

			# collision
			@bullet_manager.bullets.each do |b|
				@zombie_manager.zombies.each do |z|
					if z.intersect? b
						z.health -= b.damage
						@particle_manager.fire(z.position, 2)
						@bullet_manager.bullets.delete b
						@sounds[:hit].play()
						if z.health <= 0
							case z.type
								when :normal
									@particle_manager.fire(z.position, 26, 1.0)
									@sounds[:blood_1].play()
								when :runner
									@particle_manager.fire(z.position, 16, 2.0)
									@sounds[:blood_2].play()
								when :brute 
									@sounds[:blood_2].play()
									@sounds[:wilhelm_scream].play()
									@particle_manager.fire(z.position, 26, 1.0)
									@particle_manager.fire(z.position, 128, 5.0, 2.0)
									@zombie_manager.spawn_children(z.position)
								else
							end				
							add_splat(z.position.clone)			
							@zombie_manager.zombies.delete z
							@kill_count += 1
						end
					end
				end
			end

			# zombies
			@zombie_manager.zombies.each do |z|
				if z.intersect? @player
					reset()
					break
				end
			end	

			@message_box.update dt
		end

		def draw
			@bg.draw(0,0,0)

			@splats.each do |splat|
				@splat_tex.draw_rot(splat.position.x, splat.position.y, 0, splat.rotation.to_degrees)
			end

			@zombie_manager.draw
			@bullet_manager.draw
			@particle_manager.draw

			@player.draw
			@filter.draw(0, 0, 0)

			@corsair.draw_rot(mouse_x, mouse_y, 0.0, @corsair_rotation)
			@corsair.draw_rot(mouse_x, mouse_y, 0.0, -@corsair_rotation, 0.5, 0.5, 0.6, 0.6)

			draw_hud()
		end

		def draw_hud
			@guns_tex.draw(16, 16, 0)
			@selected_weapon_tex.draw(16 + (16 * @player.selected_weapon_index), 16, 0)

			@reload_bar_tex.draw(16, 42, 0)
			@reload_bar_fill_tex.draw_rot(17, 43, 0, 0, 0.0, 0.0, @player.weapons[@player.current_weapon].progress * 2.0, 1.0)

			@font.draw("DPS: #{@player.weapons[@player.current_weapon].dps.to_i}", 16, 60, 0)

			@font.draw_rel("Time: #{(@total_time / 1000).to_i}", $WIDTH - 16, 16, 0, 1.0, 0.0)
			@font.draw_rel("Zombies killed: #{@kill_count}", $WIDTH - 16, 32, 0, 1.0, 0.0)
			@font.draw_rel("Wave: #{@zombie_manager.wave}", $WIDTH - 16, 48, 0, 1.0, 0.0)

			@message_box.draw
		end
	end
end

# entry point
$game = ZombieCavern::Game.new
$game.show