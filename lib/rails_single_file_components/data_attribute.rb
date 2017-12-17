require 'digest'

module RailsSingleFileComponents
  class DataAttribute
    def self.compute(filename)
      "data-sfc-#{Digest::MD5.hexdigest(filename)}"
    end
  end
end
