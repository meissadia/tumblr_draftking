module DK
  class CLI < Thor
    desc 'console', 'Loads irb with $dk available in simulation mode.'
    def console
      configured?
      self.class.launch_console
    end

    # Launch IRB with tumblr_draftking loaded as $dk
    def self.launch_console
      require 'irb'
      require 'irb/completion'
      ARGV.clear
      $dk = DK::Client.new simulate: true
      IRB.start
    end
  end
end
