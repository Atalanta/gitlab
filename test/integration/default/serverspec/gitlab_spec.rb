require 'spec_helper'

describe 'Gitlab Cookbook' do

  it 'installs the Gitlab omnibus package' do
    expect(package('gitlab')).to be_installed
  end

  it 'run an http server on port 443' do
    expect(port(443)).to be_listening
    expect((command 'lsof -i TCP:https').stdout).to match /nginx/
  end
  
  it 'it has a self-signed SSL certificate' do
    expect((command 'echo | openssl s_client -connect localhost:443').stdout).to match /CN=gitlab\.devopsexchange/
  end

  it 'serves the Gitlab web interface' do
    expect((command 'curl -k -L https://localhost').stdout).to match /Manage git repositories/
    expect((command 'curl -k -L https://localhost').stdout).to match /Sign in/
  end

  it 'creates an admin user who can log into the webui' do

    require 'net/https'
    require 'uri'
    uri = URI.parse('https://localhost/')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth("root", "5iveL!fe")
    response = http.request(request)
    expect(response.body).to match /wobble/

  end
  
  it 'redirects HTTP traffic to HTTPS' do
    expect((command 'curl -k --head http://localhost').stdout).to match /Location: https/
  end

end
