require 'cassandra'

module Believer
  class Command

    attr_accessor :record_class, :consistency_level

    def initialize(attrs = {})
      attrs.each do |name, value|
        send("#{name}=", value)
      end if attrs.present?
    end

    def execution_options
      @execution_options ||= {}
      exec_global_opts = ::Believer::Base.environment.believer_configuration[:execution]
      unless exec_global_opts.nil?
        @execution_options.merge!(exec_global_opts.symbolize_keys)
      end
      @execution_options
    end

    def execution_options=(opts)
      execution_options.merge!(opts)
    end

    def override_execution_options(opts = {})
      @execution_options = opts
    end

    def clone
      self.class.new(query_attributes)
    end

    def consistency(level)
      c = clone
      c.consistency_level = level
      c
    end

    def query_attributes
      { :record_class => @record_class, :consistency_level => @consistency_level }
    end

    def command_name
      self.class.name.split('::').last.underscore
    end

    def can_execute?
      true
    end

    def execute(name = nil)
      return false unless can_execute?

      @record_class.connection_pool.with do |connection|
        cql = to_cql

        name = "#{@record_class.name} #{command_name}" if name.nil?
        ActiveSupport::Notifications.instrument('cql.believer', :cql => cql, :name => name) do
          exec_opts = execution_options
          begin
            connection.execute(cql, exec_opts)
          rescue Cassandra::Errors::HostError, Cassandra::Errors::TimeoutError
            # connection.connect
            connection.execute(cql, exec_opts)
          end
        end
      end

    end

  end

end
