# encoding: utf-8

require 'uri'
require 'cgi'
require 'net/https'
require 'openssl'
require 'base64'

require 'nori'

require "life-api/methods"
require "life-api/version"

# The Life::API library is used for interactions with a api.life.com.ua website.
# life:) — GSM operator in Ukraine
#
# == Example
#
#   require 'life-api'
#   require 'logger'
#
#   life = Life::API.new(msisdn: msisdn, password: password)
#   life.log = Logger.new($stderr)
#   life.sign_in
#   life.get_summary_data
#   life.sign_out
#
module Life
  class API
    attr_accessor :token, :sub_id

    class << self
      # Default logger for all Life::API instances
      #
      #   Life::API.log = Logger.new($stderr)
      #
      attr_accessor :log
    end

    # Create a new API object using the given parameters.
    #
    # @param [String] msisdn
    # @param [String] password
    # @param [String] lang
    #
    def initialize(params = {})
      @msisdn   = params.delete(:msisdn)
      @password = params.delete(:password)
      @lang     = params.delete(:lang) || 'uk'

      @log = nil

      @api_url         = 'https://api.life.com.ua/mobile/'
      @access_key_code = '7'
      @application_key = 'E6j_$4UnR_)0b'
    end

    # The current logger. If no logger has been set Life::API.log is used.
    #
    def log
      @log || Life::API.log
    end

    # Sets the +logger+ used by this instance of Life::API
    #
    def log= logger
      @log = logger
    end

    def request(method, params)
      params.merge!(accessKeyCode: @access_key_code)
      url = create_signed_url(method, params)

      log.debug("[#{method}] url: #{url}") if log

      uri = URI(url)
      request = Net::HTTP::Get.new(uri.request_uri)

      response = Net::HTTP.start(uri.host, uri.port,
        :use_ssl => uri.scheme == 'https') {|http|
        http.request(request)
      }

      puts response.body

      return parse_xml(response.body)['response']
    end

    private

    def create_signed_url(method, params)
      query = create_param(params)
      str = method + '?' + query + '&signature='

      digest = OpenSSL::Digest::Digest.new('sha1')
      hash = OpenSSL::HMAC.digest(digest, @application_key, str)

      hash = Base64.encode64(hash).chomp

      str += urlencode(hash)

      return @api_url + str
    end

    # Returns a string representation of the receiver suitable for use as a URL query string
    #
    def create_param(params)
      params.map do |key, value|
        "#{urlencode(key)}=#{urlencode(value)}"
      end.sort * '&'
    end

    # URL-encode a string
    #
    def urlencode(str)
      return CGI.escape(str.to_s)
    end

    def parse_xml(str)
      parser = Nori.new
      return parser.parse(str)
    end

    def base_api_parameters
      return { msisdn: @msisdn, languageId: @lang, osType: 'ANDROID', token: @token }
    end

  end
end
