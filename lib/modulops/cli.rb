# frozen_string_literal: true

require 'thor'

require_relative 'deploywarn'

module Modulops

  # The command sending the email
  class CLI < Thor

    desc 'deploywarn PROJECT', 'Warn a team project about a successful deployment'
    def deploywarn(project)
      Modulops::Deploywarn.call(project, ENV.fetch('MODULOPS_MAILER_KEY', nil))
      puts 'Ok!'
    rescue Modulops::Error => e
      warn e.message
    end

  end

end
