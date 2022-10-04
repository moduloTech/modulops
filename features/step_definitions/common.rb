require 'json'
require 'cucumber/rspec/doubles'
require 'modulops/cli_wrapper'

Given('the mandrill API key exists') do
  ENV['MODULOPS_MAILER_KEY'] = 'test'
end

Given('the mandrill response is valid') do
  body = [
    { 'status' => 'sent', 'email' => 'a@test.test' }
  ].to_json
  @response = instance_double(Net::HTTPSuccess, body: body, code: 200)
end

Given('the mandrill response is invalid') do
  body = [
    { 'status' => 'rejected', 'email' => 'foo@bar.baz' }
  ].to_json
  @response = instance_double(Net::HTTPSuccess, body: body, code: 200)
end

Given('the mandrill API key is valid') do
  aruba.config.command_launcher = :in_process
  aruba.config.main_class = Modulops::CLIWrapper

  double = instance_double(Net::HTTP)

  allow(@response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
  allow(double).to receive(:request).and_return(@response)
  allow(Net::HTTP).to receive(:start).and_return(double)
end

Given('the configuration path is {string}') do |string|
  ENV['MODULOPS_CONFIG_FILE'] = string
end
