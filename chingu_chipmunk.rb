#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
Bundler.require :default

class ShipLoader
  def self.random_ship
    @@ship_tiles ||= load_ships
    @@ship_tiles.sample
  end

  def self.load_ships
    @@ship_tiles = Gosu::Image.load_tiles($window, Gosu::Image["ship_tiles.png"], 28, 28, true)
  end
end


class BohShmup < Chingu::Window
  def setup
    self.input = {escape: :close}
    push_game_state Level
  end
end


class Ship < Chingu::GameObject
  def setup
    self.image = ShipLoader.random_ship
    self.x = rand $window.width
    self.y = rand $window.height
    self.angle = rand 360
  end
end

class RandomShip < Ship
end

class PlayerShip < Ship
  def setup
    # turny shooty input here
  end

end

class HomingMissile < Chingu::GameObject
end


# TODO make larger than screeeeeeeeeeeen
class Level < Chingu::GameState
  def setup
    rand(50).times{ RandomShip.create }
  end
end


BohShmup.new.show
