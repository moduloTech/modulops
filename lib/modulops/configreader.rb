# frozen_string_literal: true

require 'pathname'
require 'json'

require_relative 'error'

module Modulops

  class Configreader

    def initialize
      super()

      configpath  = ENV.fetch('MODULOPS_CONFIG_FILE', "#{Dir.home}/.modulops_database.json")
      @configpath = Pathname.new(configpath)
    end

    def self.call
      new.call
    end

    def call
      JSON.parse(@configpath.read)
    rescue Errno::ENOENT
      raise Error, "No configuration found at #{@configpath}"
    end

  end

end
