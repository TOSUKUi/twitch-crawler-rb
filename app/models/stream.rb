class Stream < ApplicationRecord
  enum :status,  { ongoing: 1, stopped: 10 }
end
