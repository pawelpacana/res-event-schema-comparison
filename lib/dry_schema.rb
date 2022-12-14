require "ruby_event_store"
require "forwardable"
require "securerandom"
require "dry-struct"

module DrySchema
  module Types
    include Dry.Types()
  end

  class Schema < Dry::Struct
    transform_keys(&:to_sym)
  end

  module ClassMethods
    extend Forwardable
    def_delegators :schema, :attribute, :attribute?
    
    def schema
      @schema ||= Class.new(Schema)
    end
  end

  module Initializer
    def initialize(event_id: SecureRandom.uuid, metadata: nil, data: {})
      by_schema = self.class.schema.new(data).to_h
      super(event_id:, metadata:, data: data.merge(by_schema))
    end
  end

  class OrderPlaced < RubyEventStore::Event
    extend  ClassMethods 
    include Initializer

    attribute :order_id, Types::Strict::String
    attribute :placed_at, Types::Params::Time
    attribute :total_amount, Types::Params::Decimal
  end
end
