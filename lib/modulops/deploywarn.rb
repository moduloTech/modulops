# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

require_relative 'error'
require_relative 'configreader'

module Modulops

  class Deploywarn

    BASE_URL     = 'https://mandrillapp.com'
    ENDPOINT     = '/api/1.0/messages/send'
    HTML_MESSAGE = <<~HTML
      <h1>Nouveau déploiement pour [[PROJECT_NAME]]</h1>

      <p>Bonjour,</p>
      <p>Un déploiement vient de se terminer avec succès pour le projet [[PROJECT_NAME]].</p>
      <br/><br/>
      <p>Bonne journée,</p>

      <p>Modulobot</p>
    HTML
    TEXT_MESSAGE = <<~TEXT
      Nouveau déploiement pour [[PROJECT_NAME]]


      Bonjour,


      Un déploiement vient de se terminer avec succès pour le projet [[PROJECT_NAME]].


      Bonne journée,

      Modulobot
    TEXT
    SUBJECT = 'Nouveau déploiement pour [[PROJECT_NAME]]'

    def initialize(project, key)
      super()

      @project = project
      @key     = key
      @config  = Configreader.call
    end

    def self.call(project, key)
      new(project, key).call
    end

    def call
      validate_self

      response = send_mail

      raise Modulops::Error, "No emails were sent: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      emails = JSON.parse(response.body)

      rejected_emails = emails.reject { |email| email['status'] == 'sent' }
                              .map { |email| email['email'] }

      raise Modulops::Error, "Emails were not sent to #{rejected_emails.join(', ')}" if rejected_emails.size.positive?
    end

    private

    def validate_self
      raise Modulops::Error, 'Unknown project' if @project.nil?

      raise Modulops::Error, 'No Mandrill API Key given' if @key.nil?
    end

    def send_mail
      @emails = @config.dig('deploywarn', @project)

      raise Modulops::Error, "No emails for project #{@project}" if @emails.nil? || @emails.empty?

      send_mandrill_request
    end

    def send_mandrill_request
      uri     = URI(BASE_URL)
      http    = Net::HTTP.start(uri.host, uri.port, use_ssl: true)
      request = make_request

      http.request(request)
    end

    def make_request
      request                 = Net::HTTP::Post.new(ENDPOINT)
      request.body            = make_payload.to_json
      request['User-Agent']   = 'warnForDeployment lambda AWS'
      request['Content-Type'] = 'application/json'

      request
    end

    def make_payload
      {
        'key'     => @key,
        'message' => {
          'html'       => HTML_MESSAGE.gsub('[[PROJECT_NAME]]', @project),
          'text'       => TEXT_MESSAGE.gsub('[[PROJECT_NAME]]', @project),
          'subject'    => SUBJECT.gsub('[[PROJECT_NAME]]', @project),
          'from_email' => 'noreply@modulotech.fr', 'from_name' => 'Modulobot',
          'to'         => @emails.map { |email| { 'email' => email } }
        }
      }
    end

  end

end
