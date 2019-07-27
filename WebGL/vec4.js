function vec4(x, y, z, w) {
	var self = this;
	self.coord = [x || 0, y || 0, z || 0, w || 0];

	self.add = function(v) {
		return new vec4(
			self.coord[0] + v.coord[0],
			self.coord[1] + v.coord[1],
			self.coord[2] + v.coord[2],
			self.coord[3] + v.coord[3]
		);
	};

	self.sub = function(v) {
		return new vec4(
			self.coord[0] - v.coord[0],
			self.coord[1] - v.coord[1],
			self.coord[2] - v.coord[2],
			self.coord[3] - v.coord[3]
		);
	};

	self.mul = function(v) {
		return new vec4(
			self.coord[0] * v,
			self.coord[1] * v,
			self.coord[2] * v,
			self.coord[3] * v
		);
	};

	self.div = function(v) {
		return new vec4(
			self.coord[0] / v,
			self.coord[1] / v,
			self.coord[2] / v,
			self.coord[3] / v
		);
	};

	self.dot = function(v) {
		return self.coord[0] * v.coord[0] + self.coord[1] * v.coord[1] + self.coord[2] * v.coord[2] + self.coord[3] * v.coord[3];
	};

	self.length = function() {
		return Math.sqrt(self.dot(self));
	};

	self.copy = function() {
		return new vec4(
			self.coord[0],
			self.coord[1],
			self.coord[2],
			self.coord[3]
		);
	};
}
