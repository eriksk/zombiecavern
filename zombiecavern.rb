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

$WIDTH = 800
$HEIGHT = 600

module ZombieCavern
	class Game < Gosu::Window


		def initialize
			super $WIDTH, $HEIGHT, false
			self.caption = "Zombie Cavern"

			@font = Gosu::Font.new(self, Gosu::default_font_name, 24)

			@bg = load_image('bg')
			@filter = load_image('filter')

			@corsair = load_image('corsair')
			@corsair_rotation = 0.0

			@player = Player.new(load_image('player'))
			@player.position.x = $WIDTH / 2.0
			@player.position.y = $HEIGHT / 2.0

			@bullet_manager = BulletManager.new(load_image('bullet'))
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

			reset()
		end


		def add_splat(position)
			@splats.push position
		end

		def load_image name
			Gosu::Image.new(self, "content/gfx/#{name}.png", false)
		end

		def reset
			@zombie_manager.clear
			@bullet_manager.clear
			@player.position.x = $WIDTH / 2.0
			@player.position.y = $HEIGHT / 2.0
			@splats.clear
			@player.reset
			@zombie_manager.spawn_zombies()
		end

		def update
			if button_down? Gosu::KbEscape
				exit
			end

			dt = 16.0
			@corsair_rotation += 0.15 * dt

			# switch weapons
			if button_down? Gosu::Kb1
				@player.switch_weapon(:gun)
			elsif button_down? Gosu::Kb2
				@player.switch_weapon(:smg)
			elsif button_down? Gosu::Kb3
				@player.switch_weapon(:cannon)
			end
			
			# bullets
			if button_down? Gosu::MsLeft
				angle = @player.rotation
				@player.weapons[@player.current_weapon].fire(@bullet_manager, @player.position, angle)
			end

			# player
			@player.update dt	
			@player.rotation = Math::atan2(mouse_y - @player.position.y, 
										   mouse_x - @player.position.x)	
		
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
						if z.health <= 0
							case z.type
								when :normal
									@particle_manager.fire(z.position, 26, 1.0)
								when :runner
									@particle_manager.fire(z.position, 16, 2.0)
								when :brute 
									@particle_manager.fire(z.position, 26, 1.0)
									@particle_manager.fire(z.position, 128, 5.0, 2.0)
									spawn_children(z.position)
								else
							end				
							add_splat(z.position.clone)			
							@zombie_manager.zombies.delete z
						end
					end
				end
			end
		end

		def draw
			@bg.draw(0,0,0)

			@splats.each do |vec|
				@splat_tex.draw_rot(vec.x, vec.y, 0, 0)
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

			@font.draw("DPS: #{@player.weapons[@player.current_weapon].dps}", 16, 64, 0)
		end
	end
end

# entry point
$game = ZombieCavern::Game.new
$game.show