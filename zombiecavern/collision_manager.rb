module ZombieCavern
	class CollisionManager

		def initialize game
			@game = game			
		end

		def update dt
			@game.bullet_manager.bullets.each do |b|
				@game.zombie_manager.zombies.each do |z|
					if z.intersect? b
						z.health -= b.damage
						@game.particle_manager.fire(z.position, 2)
						@game.bullet_manager.bullets.delete b
						@game.sound_manager.play(:hit)
						if z.health <= 0
							case z.type
								when :normal
									@game.particle_manager.fire(z.position, 26, 1.0)
									@game.sound_manager.play(:blood_1)
								when :runner
									@game.particle_manager.fire(z.position, 16, 2.0)
									@game.sound_manager.play(:blood_2)
								when :brute 
									@game.sound_manager.play(:blood_2)
									@game.sound_manager.play(:wilhelm_scream)
									@game.particle_manager.fire(z.position, 26, 1.0)
									@game.particle_manager.fire(z.position, 128, 5.0, 2.0)
									@game.zombie_manager.spawn_children(z.position)
								else
							end				
							@game.add_splat(z.position.clone)			
							@game.zombie_manager.zombies.delete z
							@game.zombie_killed
						end
					end
				end
			end

			# zombies
			@game.zombie_manager.zombies.each do |z|
				if z.intersect? @game.player
					#game.reset()
					break
				end
			end	

			@game.pickup_manager.pickups.each do |p|
				if p.intersect? @game.player
					p.pickup(@game.player)
					@game.sound_manager.play(:pickup)
					# TODO: throw some particles
					@game.pickup_manager.pickups.delete p
				end
			end
		end
	end
end