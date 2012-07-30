class Numeric
	def to_degrees
		self * 180 / Math::PI
	end
end

module ZombieCavern
	def self.lerp(min, max, weight)
		min + (max - min) * weight
	end
end
