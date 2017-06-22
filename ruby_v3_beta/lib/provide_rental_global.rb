#!/usr/bin/env ruby
# encoding: utf-8

require 'securerandom'
require 'rapids_rivers'

# Understands the complete stream of messages on an event bus
class ProvideRentalGlobal
  attr_reader :service_name

  NEED = "car_rental_offer"
  OFFER = "car_rental"

  def initialize(host_ip, port)
    rapids_connection = RapidsRivers::RabbitMqRapids.new(host_ip, port)
    @river = RapidsRivers::RabbitMqRiver.new(rapids_connection)

    @river.require_values("need" => NEED);  # filter car rental needs

    @service_name = 'provide_rental_global_ruby_' + SecureRandom.uuid
  end

  def start
    puts " [*] #{@service_name} waiting for rental needs... To exit press CTRL+C"
    @river.register(self)
  end

  def packet(rapids_connection, packet, warnings)
    rapids_connection.publish(rental_offer(packet))
    puts " [<] Published rental offer"
  end

  def on_error rapids_connection, errors
    # ignore the error
  end

  private

  def rental_offer(packet)
    offer = { solution: OFFER }
    RapidsRivers::Packet.new(offer)
  end

end

ProvideRentalGlobal.new(ARGV.shift, ARGV.shift).start
