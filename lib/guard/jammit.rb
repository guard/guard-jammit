# Do NOT require "guard/plugin"
# It will either be required or a stub will be supplied by the test class

require 'jammit'

module Guard
  # The Jammit Guard that gets notifications about the following
  # Guard events: `start`, `stop`, `reload`, `run_all` and `run_on_change`.
  #
  class Jammit < Plugin
    DEFAULT_OPTIONS = {
      config_path: ::Jammit::DEFAULT_CONFIG_PATH,
      output_folder: nil,
      base_url: nil,
      public_root: nil,
      force: false,
      package_names: nil,
      package_on_start: true,
      notification: true,
      hide_success: false
    }

    # Initialize Guard::Jammit.
    #
    # @param [Array<Guard::Watcher>] watchers the watchers in the Guard block
    # @param [Hash] options the options for the Guard
    # @option options [String] :output_folder the output folder
    # @option options [String] :base_url the base URL for the MHTML stylesheet
    # @option options [String] :public_root the public root folder
    # @option options [Boolean] :force force packaging
    # @option options [Array<String>] package_names the package names to package
    # @option options [Boolean] :package_on_start package when Guard starts
    # @option options [Boolean] :notification show notifications
    # @option options [Boolean] :hide_success hide success message notification
    #
    def initialize(options = {})
      options = DEFAULT_OPTIONS.merge(options)
      super
    end

    # Gets called once when Guard starts.
    #
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def start
      ensure_rails_env!

      ::Guard::UI.info "Using Jammit version #{::Jammit::VERSION}"

      jammit if @options[:package_on_start]
    end

    # Gets called when all files should be packaged.
    #
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def run_all
      jammit
    end

    # Gets called when watched paths and files have changes.
    #
    # @param [Array<String>] paths the changed paths and files
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def run_on_changes(_paths)
      jammit
    end

    # Runs Jammit to package the assets
    #
    def jammit
      Thread.current[:jammit_packager] = nil

      ::Jammit.package! @options

      ::Guard::UI.info 'Jammit successfully packaged the assets.'
      ::Guard::Notifier.notify('Jammit successfully packaged the assets.', title: 'Jammit') if @options[:notification] && !@options[:hide_success]

    rescue RuntimeError => e
      ::Guard::UI.error("Jammit failed to package the assets: #{e.message}")
      ::Guard::Notifier.notify('Jammit failed to package the assets.', title: 'Jammit', image: :failed) if @options[:notification]
    end

    private

    # Ensures that Rails env is available when Rails is only partially loaded
    #
    def ensure_rails_env!
      require 'rails' if defined?(::Rails) && !::Rails.respond_to?(:env)
    end
  end
end
