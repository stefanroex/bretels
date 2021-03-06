require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module Bretels
  class AppGenerator < Rails::Generators::AppGenerator
    class_option :database, :type => :string, :aliases => '-d', :default => 'postgresql',
      :desc => "Preconfigure for selected database (options: #{DATABASES.join('/')})"

    class_option :heroku, :type => :boolean, :aliases => '-H', :default => false,
      :desc => 'Create staging and production Heroku apps'

    class_option :skip_test_unit, :type => :boolean, :aliases => '-T', :default => true,
      :desc => 'Skip Test::Unit files'

    def finish_template
      invoke :bretels_customization
      super
    end

    def bretels_customization
      invoke :remove_files_we_dont_need
      invoke :customize_gemfile
      invoke :setup_development_environment
      invoke :setup_test_environment
      invoke :setup_production_environment
      invoke :setup_staging_environment
      invoke :create_suspenders_views
      invoke :setup_database
      invoke :configure_app
      invoke :setup_stylesheets
      invoke :customize_error_pages
      invoke :remove_routes_comment_lines
      invoke :remove_turbolinks
      invoke :setup_git
      invoke :create_heroku_apps
      invoke :outro
    end

    def remove_files_we_dont_need
      build :remove_rails_logo_image
    end

    def setup_development_environment
      say 'Setting up the development environment'
      build :raise_delivery_errors
      build :initialize_on_precompile
      build :lib_in_load_path
      build :install_spring_gem
    end

    def setup_test_environment
      say 'Setting up the test environment'
      build :enable_factory_girl_syntax
      build :test_factories_first
      build :generate_rspec
      build :configure_rspec
      build :generate_factories_file
    end

    def setup_production_environment
      say 'Setting up the production environment'
      build :configure_smtp
      build :enable_force_ssl
      build :add_cdn_settings
      build :enable_rack_deflater
    end

    def setup_staging_environment
      say 'Setting up the staging environment'
      build :setup_staging_environment
    end

    def create_suspenders_views
      say 'Creating suspenders views'
      build :create_partials_directory
      build :create_shared_flashes
      build :create_application_layout
    end

    def customize_gemfile
      build :replace_gemfile
      build :set_ruby_to_version_being_used
    end

    def setup_database
      say 'Setting up database'

      if 'postgresql' == options[:database]
        build :use_postgres_config_template
      end
    end

    def configure_app
      say 'Configuring app'
      build :configure_action_mailer
      build :raise_unpermitted_params
      build :configure_time_zone
      build :configure_time_formats
      build :configure_dutch_language
      build :configure_rack_timeout
      build :add_airbrake_configuration
      build :add_email_validator
      build :setup_default_rake_task
      build :setup_foreman
    end

    def setup_stylesheets
      say 'Set up stylesheets'
      build :setup_stylesheets
    end

    def setup_git
      say 'initializing git'
      invoke :setup_gitignore
      invoke :init_git
    end

    def create_heroku_apps
      if options[:heroku]
        say 'Creating Heroku apps'
        build :create_heroku_apps
      end
    end

    def setup_gitignore
      build :gitignore_files
    end

    def init_git
      build :init_git
    end

    def customize_error_pages
      say 'Customizing the 500/404/422 pages'
      build :customize_error_pages
    end

    def remove_turbolinks
      build :remove_turbolinks
    end

    def remove_routes_comment_lines
      build :remove_routes_comment_lines
    end

    def outro
      say 'Done. Congratulations!'
      say '1. Run bundle install'
      say '2. Run rake db:create'
      say "3. Update config/initializers/airbrake.rb"
    end

    def run_bundle
      # Let's not: We'll bundle manually at the right spot
    end

    protected

    def get_builder_class
      Bretels::AppBuilder
    end

  end
end
