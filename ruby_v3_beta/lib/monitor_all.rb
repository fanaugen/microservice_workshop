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
class MonitorAll
  attr_reader :service_name

  def initialize(host_ip, port)
    rapids_connection = RapidsRivers::RabbitMqRapids.new(host_ip, port)
    @river = RapidsRivers::RabbitMqRiver.new(rapids_connection)
    # @river.require_values("key"=>"value");  // Reject packet unless it has key:value pair
    # @river.require("key1", "key2");   # Reject packet unless it has key1 and key2
    # @river.forbid("key1", "key2");    # Reject packet if it does have key1 or key2
    # @river.interested_in("key1", "key2");  // Allows key1 and key2 to be queried and set in a packet
    # For any keys required, forbidden, or deemed interesting, accessor methods are created in Packet
@service_name = 'monitor_all_ruby_' + SecureRandom.uuid
  end

  def start
    puts " [*] #{@service_name} waiting for traffic on RabbitMQ event bus ... To exit press CTRL+C"
    @river.register(self)
  end

  def packet rapids_connection, packet, warnings
    puts " [*] #{warnings}"
  end

  def on_error rapids_connection, errors
    puts " [x] #{errors}"
  end

end

MonitorAll.new(ARGV.shift, ARGV.shift).start
