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

$WIDTH = 800
$HEIGHT = 600

module ZombieCavern
	class Game < Gosu::Window


		def initialize
			super $WIDTH, $HEIGHT, false
			self.caption = "Zombie Cavern"

			@bg = load_image('bg')
			@filter = load_image('filter')

			@corsair = load_image('corsair')
			@corsair_rotation = 0.0

			@player = Player.new(load_image('player'))
			@player.position.x = $WIDTH / 2.0
			@player.position.y = $HEIGHT / 2.0

			@bullet_manager = BulletManager.new(load_image('bullet'))
			@particle_manager = ParticleManager.new(load_image('particle'))

			@zombies = []
			@zombie_textures = {
				:normal  => load_image('zombie'),
				:runner  => load_image('zombie_runner'),
				:brute  => load_image('zombie_brute'),
			}
			@zombie_spawn_timer = Timer.new(1000, lambda{
				spawn_zombies()
			})
			@zombie_count = 1
			spawn_zombies()
		end

		def spawn_zombies			
			@zombie_count.to_i.times do |i|
				type = :normal
				type_val = rand()
				if type_val > 0.9
					type = :brute
				elsif type_val > 0.8
					type = :runner
				end
				z = Zombie.new(@zombie_textures[type], type)
				left = rand() > 0.5
				if left
					z.position.x = -100 
					z.position.y = rand() * $HEIGHT
				else
					z.position.x = $WIDTH + 100 
					z.position.y = rand() * $HEIGHT
				end
				@zombies.push z
			end
			@zombie_count *= 1.05
		end

		def spawn_children position		
			4.times do |i|
				z = Zombie.new(@zombie_textures[:normal], :normal)
				z.position.x = position.x + (-0.5 + rand()) * 64
				z.position.y = position.y + (-0.5 + rand()) * 64
				@zombies.push z
			end
		end

		def load_image name
			Gosu::Image.new(self, "content/gfx/#{name}.png", false)
		end

		def reset
			@zombie_count = 1
			@zombies.clear
			@bullet_manager.clear
			@player.position.x = $WIDTH / 2.0
			@player.position.y = $HEIGHT / 2.0
		end

		def update
			if button_down? Gosu::KbEscape
				exit
			end

			dt = 16.0
			@corsair_rotation += 0.15 * dt
			@zombie_spawn_timer.update dt
			
			# bullets
			if button_down? Gosu::MsLeft
				angle = @player.rotation + (-0.5 + rand()) * 0.3
				@bullet_manager.fire(
					@player.position.clone, 
					Vec2.new(Math::cos(angle), 
						     Math::sin(angle)) * 0.5)
			end

			# player
			@player.update dt	
			@player.rotation = Math::atan2(mouse_y - @player.position.y, 
										   mouse_x - @player.position.x)	

			# zombies
			@zombies.each do |z|
				z.update dt, @player
				if z.intersect? @player
					reset()
					break
				end
			end	

			@bullet_manager.update dt
			@particle_manager.update dt

			# collision
			@bullet_manager.bullets.each do |b|
				@zombies.each do |z|
					if z.intersect? b
						z.health -= 1
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
							@zombies.delete z
						end
					end
				end
			end
		end

		def draw
			@bg.draw(0,0,0)

			@zombies.each do |z|
				z.draw
			end	

			@bullet_manager.draw
			@particle_manager.draw

			@player.draw

			@filter.draw(0,0,0)

			@corsair.draw_rot(mouse_x, mouse_y, 0.0, @corsair_rotation)
			@corsair.draw_rot(mouse_x, mouse_y, 0.0, -@corsair_rotation, 0.5, 0.5, 0.6, 0.6)
		end
	end
end

# entry point
$game = ZombieCavern::Game.new
$game.show