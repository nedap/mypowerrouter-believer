require 'connection_pool'

module Believer
  module Connection
    extend ::ActiveSupport::Concern

    module ClassMethods

      def reset_connection(conn)
        unless conn.nil?
          conn.close
        end
      end

      def connection_pool
        Believer::Connection::Pool.instance.connection
      end

    end

    class Pool
      include ::Singleton

      def initialize
        env = Believer::Base.environment
        pool_config = env.connection_pool_configuration
        if pool_config.nil?
          pool_config = {
              :size => 1,
              :timeout => 10
          }
        end
        @connection_pool = ConnectionPool.new(pool_config.symbolize_keys) do
          env.create_connection(:connect_to_keyspace => true)
        end
      end

      # Retrieve a connection from the pool
      def connection
        @connection_pool
      end

    end

  end

end