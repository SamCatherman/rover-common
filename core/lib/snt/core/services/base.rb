module SNT
  module Core
    module Services
      class Base
        delegate :invalidate!, :add_error, :add_validation_error, :add_validation_errors, :add_active_record_errors, :merge_result, :merge_result!,
                 :publish_events, to: :result

        # Provide class level call method as convenience over calling new, then call
        def self.call(*args, &block)
          new(*args, &block).call
        end

        # @params
        # - options [Hash] attributes:
        #   - no_transaction [boolean] Do not start a transaction
        # @return [Services::Result]
        def call(options = {})
          if options[:no_transaction]
            # Don't start a transaction if no_transaction is true
            call_delegate
          else
            # Start a transaction around the service call. Use requires_new to ensure sub transactions can be rolled back without impacting parent
            # transaction. Services can optionally be invalidated and its transaction rolled back, when a sub-service fails and its sub-transaction is
            # rolled back.
            ActiveRecord::Base.transaction(requires_new: true) do
              call_delegate
            end
          end

          if result.status
            publish_events if ActiveRecord::Base.connection.open_transactions.zero?
          else
            execute_error_callbacks
          end

          result
        rescue InvalidException
          execute_error_callbacks

          result
        rescue ActiveRecord::RecordInvalid => e
          add_active_record_errors(e.record)
          execute_error_callbacks

          result
        ensure
          execute_completion_callbacks
        end

        # All services should override call_delegate
        def call_delegate; end

        # Get the result object. Initialize if not present.
        def result
          @result ||= Result.new
        end

        def self.on_error(method_name)
          error_callbacks << method_name
        end

        def self.on_completion(method_name)
          completion_callbacks << method_name
        end

        def self.error_callbacks
          @error_callbacks ||= []
        end

        def self.completion_callbacks
          @completion_callbacks ||= []
        end

        def execute_error_callbacks
          Base.error_callbacks.each { |method| send(method) }
        end

        def execute_completion_callbacks
          Base.completion_callbacks.each { |method| send(method) }
        end

        # Call another service by passing the class, its attributes, and options. Invalidate this service if the other service failed.
        # options [Hash] attributes:
        # - ignore_errors [boolean] Do not add other service's errors to this service's errors
        def call_service!(service_class, attributes, options = {})
          merge_result!(service_class.new(attributes).call, options)
        end

        # Call another service by passing the class, its attributes, and options. If other service fails, ignore the errors by default.
        # options [Hash] attributes:
        # - ignore_errors [boolean] Do not add other service's errors to this service's errors
        def call_service(service_class, attributes, options = { ignore_errors: true })
          merge_result(service_class.new(attributes).call, options)
        end
      end
    end
  end
end
