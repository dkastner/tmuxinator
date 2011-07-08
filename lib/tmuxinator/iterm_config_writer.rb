module Tmuxinator

  class ITermConfigWriter < ConfigWriter
    attr_accessor :file_name, :file_path, :project_name, :project_root, :rvm, :tabs, :pre

    include Tmuxinator::Helper

    def self.write_aliases(aliases)
      File.open("#{ENV["HOME"]}/.tmuxinator/scripts/tmuxinator", 'w') {|f| f.write(aliases.join("\n")) }
    end

    def initialize(this_full_path=nil)
      self.file_path = this_full_path if this_full_path
    end

    def file_path= full_path
      @file_path = full_path
      @file_name = File.basename full_path, '.yml'
      process_config! if full_path && File.exist?(full_path)
    end

    def write!
      raise "Unable to write with out a file_name defined" unless file_name
      erb         = ERB.new(IO.read(ITERM_TEMPLATE)).result(binding)
      tmp         = File.open(config_path, 'w') {|f| f.write(erb) }

      "alias start_#{file_name}='$SHELL #{config_path}'"
    end

    def config_path
      "#{root_dir}#{file_name}.AppleScript" if file_name
    end

    private

    def write_alias(stuff)
      File.open("#{root_dir}scripts/#{@filename}", 'w') {|f| f.write(stuff) }
    end

    def send_keys(cmd, window_number)
      return '' unless cmd
      "tmux send-keys -t #{window(window_number)} #{s cmd} C-m"
      return <<-APPLESCRIPT
      tell item <%= window_number %> of 
      %Q{tell application "System Events" to keystroke "#{cmd}"}
      APPLESCRIPT
    end
  end
end
