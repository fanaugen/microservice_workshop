#!/usr/bin/env ruby
# encoding: utf-8

# Copyright (c) 2017 by Fred George.
# May be used freely except for training; license required for training.

# For debugging...
# require 'pry'
# require 'pry-nav'

require 'securerandom'
require 'rapids_rivers'

# Understands the complete stream of messages on an event bus
class JoinOffer
  attr_reader :service_name

  def initialize(host_ip, port)
    rapids_connection = RapidsRivers::RabbitMqRapids.new(host_ip, port)
    @river = RapidsRivers::RabbitMqRiver.new(rapids_connection)
    @river.require('user_id')
    @river.forbid('offer')
    @service_name = 'join_offer_' + SecureRandom.uuid
  end

  def start
    puts " [*] #{@service_name} waiting for traffic on RabbitMQ event bus ... To exit press CTRL+C"
    @river.register(self)
  end

  def packet(rapids_connection, packet, warnings)
    return if packet.user_id.even?
    packet.offer = join_offer
    rapids_connection.publish(packet)
    puts " [<] Published a join offer need on the bus:\n\t     #{packet.to_json}"
  end

  def join_offer
    { 
      name: 'Join Membership and BMW 5i',
      price: 10_000,
      chance: 0.8
    }
  end
end

JoinOffer.new(ARGV.shift, ARGV.shift).start
