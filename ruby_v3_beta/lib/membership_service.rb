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
class MembershipService
  attr_reader :service_name

  def initialize(host_ip, port)
    rapids_connection = RapidsRivers::RabbitMqRapids.new(host_ip, port)
    @river = RapidsRivers::RabbitMqRiver.new(rapids_connection)
    @river.forbid("membership_level", "offer")
    @river.require("user_id", "need")
    @service_name = 'membership_service_ruby_' + SecureRandom.uuid
  end

  def start
    puts " [*] #{@service_name} waiting for traffic on RabbitMQ event bus ... To exit press CTRL+C"
    @river.register(self)
  end

  def packet rapids_connection, packet, warnings
    return if packet.user_id.odd?
    packet.membership_level = membership_level
    rapids_connection.publish(packet)
  end

  private

  def membership_level
    case rand
    when 0..0.6
      "basic"
    when 0.6..0.8
      "silver"
    when 0.8..1
      "gold"
    end
  end
end

MembershipService.new(ARGV.shift, ARGV.shift).start
