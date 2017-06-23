#!/usr/bin/env ruby
# encoding: utf-8

require 'securerandom'
require 'rapids_rivers'

# Listens for offers, chooses the best one per uuid
class CollectSolutions
  attr_reader :service_name, :offers

  def initialize(host_ip, port)
    @service_name = 'collect_solutions_ruby_' + SecureRandom.uuid
    @offers = {}

    rapids_connection = RapidsRivers::RabbitMqRapids.new(host_ip, port)
    @river = RapidsRivers::RabbitMqRiver.new(rapids_connection)

    @river.require("offer", "uuid") # collect offer messages from the bus
    @river.forbid("best_offer")
  end

  def start
    puts " [*] #{@service_name} collecting offers... To exit press CTRL+C"
    @river.register(self)
  end

  def packet(rapids_connection, packet, warnings)
    value = value_of(packet.offer)

    best_value_so_far = value_of(offers[packet.uuid])

    if value > best_value_so_far
      offers[packet.uuid] = packet.offer
      send_offer(rapids_connection, packet)
    end
  end

  private

  def send_offer(connection, packet)
    packet.best_offer = packet.offer
    connection.publish(packet)
  end

  def value_of(offer)
    return 0 if offer.nil?
    offer["price"] * offer["chance"]
  end
end

CollectSolutions.new(ARGV.shift, ARGV.shift).start
