module ZombieCavern
	class ParticleManager

		attr_accessor :particles

		def initialize particle_tex
			@particles = []
			@particle_tex = particle_tex
		end

		def fire position, count, power = 1.0, duration = 1.0
			count.times do
				p = Particle.new(@particle_tex, (200 + rand() * 200) * duration)
				p.position.x = position.x
				p.position.y = position.y
				angle = 10.0 * rand()
				force = (0.5 + rand()) * power
				p.velocity.x = Math::cos(angle) * force
				p.velocity.y = Math::sin(angle) * force
				p.rotation = rand()
				@particles.push(p)
			end
		end

		def update dt
			@particles.each do |b|
				b.update dt

				die = false
				# boundaries				
				if b.position.x < 0
					die = true
				end
				if b.position.x > $WIDTH
					die = true
				end
				if b.position.y < 0
					die = true
				end
				if b.position.y > $HEIGHT
					die = true
				end
				if die || !b.alive
					@particles.delete b
				end
			end

		end

		def draw
			@particles.each do |b|
				b.draw
			end
		end
	end
end