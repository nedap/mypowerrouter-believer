module Believer
  module Test
    class Database

      # Drop and create the keyspace. If options contains classes, creates all tables
      # @param options [Hash] the options
      # @option options :environment the environment to use. Must be a subclass of Believer::Environment::BaseEnv
      # @option options :classes an array of classes to create tables for. Items can be strings or class constants
      def self.setup(options = {})
        env = options[:environment] || Believer::Base.environment
        keyspace = ::Believer::KeySpace.new(env)
        begin
          keyspace.drop
        rescue Cassandra::Error
          # Bullocks
        end
        keyspace.create({})

        ::Believer::Base.environment = env

        classes = options[:classes]
        classes.each do |cl|

          if cl.is_a?(String)
            clazz = cl.split('::').inject(Kernel) { |scope, const_name| scope.const_get(const_name) }
          elsif cl.is_a?(Class)
            clazz = cl
          end

          if clazz.ancestors.include?(Believer::Base)
            clazz.create_table()
          end

        end if classes.present?

      end

    end
  end
end
