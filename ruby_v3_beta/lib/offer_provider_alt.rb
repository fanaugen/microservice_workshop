#!/usr/bin/env ruby
# encoding: utf-8

require 'securerandom'
require 'rapids_rivers'

# Understands the complete stream of messages on an event bus
class OfferProviderAlt
  attr_reader :service_name

  OFFER = {
    id: 1,
    need: 'car_rental_offer',
    solution: {
      model: 'Audi',
      price: 1000
    }
  }

  def initialize(host_ip, port)
    @service_name = 'offer_provider_ruby_' + SecureRandom.uuid

    rapids_connection = RapidsRivers::RabbitMqRapids.new(host_ip, port)
    @river = RapidsRivers::RabbitMqRiver.new(rapids_connection)

    @river.require_values("need" => OFFER[:need]);  # filter car rental needs
  end

  def start
    puts " [*] #{@service_name} waiting for rental needs... To exit press CTRL+C"
    @river.register(self)
  end

  def packet(rapids_connection, packet, warnings)
    rapids_connection.publish(rental_offer(packet))
    puts " [<] publishing rental offer: #{OFFER[:id]}"
  end

  private

  def rental_offer(packet)
    RapidsRivers::Packet.new(OFFER)
  end
end

OfferProviderAlt.new(ARGV.shift, ARGV.shift).start
