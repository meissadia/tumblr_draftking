# Patch for Thor long_desc display
class Thor
  # Thor::Shell Patch
  module Shell
    # Eliminate awkward text wrapping
    class Basic
      def print_wrapped(message, _options = {})
        stdout.puts message
       end
    end
  end
end
