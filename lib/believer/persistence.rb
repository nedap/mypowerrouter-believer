module Believer

  # Defines persistence functionality for a class
  module Persistence
    extend ::ActiveSupport::Concern

    module ClassMethods

      # Creates 1 or more new instances, and persists them to the database.
      # An optional block can be provided which is called for each created model.
      #
      # @param attributes [Enumerable] the attributes. If this is an array, it is assumed multiple models should be created
      def create(attributes = nil, &block)
        if attributes.is_a?(Array)
          attributes.collect { |attr| create(attr, &block) }
        else
          object = new(attributes, &block)
          object.save
          object
        end
      end

    end

    # Saves the model.
    def save
      if persisted? || is_counter_instance?
        Update.create(self).execute
      else
        Insert.new(:record_class => self.class, :values => self).execute
      end
      persisted!
      self
    end

    # Destroys the model.
    def destroy
      res = self.delete
      @persisted = false
      res
    end

    # Deletes the Cassandra row.
    def delete
      Delete.new(:record_class => self.class).where(key_values).execute
    end

    def persisted!
      @persisted = true
    end

    def persisted?
      @persisted == true
    end

  end
end
