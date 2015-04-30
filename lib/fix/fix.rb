module Fix
  module Fields
    module Components
      include_package 'quickfix.field.component'
    end
    include_package 'quickfix.field'
  end
  module Fix42
    include_package 'quickfix.fix42'
  end
  include_package 'quickfix'
end