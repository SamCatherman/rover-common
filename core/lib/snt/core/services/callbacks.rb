module SNT
  module Core
    module Services
      module Callbacks
        def on_error(*method_names)
          @error_callbacks ||= []
          @error_callbacks += method_names
        end

        def on_completion(*method_names)
          @completion_callbacks ||= []
          @completion_callbacks += method_names
        end
      end
    end
  end
end
