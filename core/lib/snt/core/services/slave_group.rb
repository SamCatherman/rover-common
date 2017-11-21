# Module used to declare that the entire service execution should route reads to the selected slave group
module SNT
  module Core
    module Services
      module SlaveGroup
        def using_slave_group(name)
          @slave_group = name
        end

        def slave_group
          @slave_group
        end
      end
    end
  end
end
