# frozen_string_literal: true

require 'uri'
require 'cgi'
require 'net/https'
require 'openssl'
require 'base64'

require 'xmlsimple'

require 'lifecell_api/methods'
require 'lifecell_api/version'

# The Lifecell::API library is used for interactions with a https://api.life.com.ua.
# lifecell - GSM operator in Ukraine
#
# == Example
#
#   require 'lifecell_api'
#   require 'logger'
#
#   life = Lifecell::API.new(msisdn: msisdn, password: password, lang: 'uk')
#   life.log = Logger.new($stderr)
#   life.sign_in
#   life.get_summary_data
#   life.sign_out
#
module Lifecell
  class MethodError < ArgumentError; end
  class StatusError < ArgumentError; end

  RESPONSE_CODES = {
    '0' => 'SUCCESSFULY_PERFORMED',
    '-1' => 'METHOD_INVOCATION_TIMEOUT',
    '-2' => 'INTERNAL_ERROR',
    '-3' => 'INVALID_PARAMETERS_LIST',
    '-4' => 'VENDOR_AUTHORIZATION_FAILED',
    '-5' => 'VENDOR_ACCESS_KEY_EXPIRED',
    '-6' => 'VENDOR_AUTHENTICATION_FAILED',
    '-7' => 'SUPERPASS_CHECKING_FAILED',
    '-8' => 'INCORRECT_SUBSCRIBER_ID',
    '-9' => 'INCORRECT_SUBSRIBER_STATE',
    '-10' => 'SUPERPASS_BLOCKED',
    '-11' => 'SUBSCRIBER_ID_NOT_FOUND',
    '-12' => 'TOKEN_EXPIRED',
    '-13' => 'CHANGE_TARIFF_FAILED',
    '-14' => 'SERVICE_ACTIVATION_FAILED',
    '-15' => 'OFFER_ACTIVATION_FAILED',
    '-16' => 'GET_TARIFFS_FAILED',
    '-17' => 'GET_SERVICES_FAILED',
    '-18' => 'REMOVE_SERVICE_FROM_PREPROCESSING_FAILED',
    '-19' => 'LOGIC_IS_BLOCKING',
    '-20' => 'TOO_MANY_REQUESTS',
    '-40' => 'PAYMENTS_OR_EXPENSES_MISSED',
    '-21474833648' => 'INTERNAL_APPLICATION_ERROR'
  }.freeze

  # :nodoc:
  class API
    attr_accessor :token, :sub_id

    class << self
      # Default logger for all Lifecell::API instances
      #
      #   Lifecell::API.log = Logger.new($stderr)
      #
      attr_accessor :log
    end

    # Create a new API object using the given parameters.
    #
    # == Required parameters
    #
    # * +:msisdn+ - telephone number in format '38063*******'
    # * +:password+ - super password
    # * +:lang+ - 'uk', 'ru' or 'en'
    #
    def initialize(params = {})
      @msisdn   = params.delete(:msisdn)
      @password = params.delete(:password)
      @lang     = params.delete(:lang) || 'uk'

      @log = nil

      @os_type = 'ANDROID'

      @api_url         = 'https://api.life.com.ua/mobile/'
      @access_key_code = '7'
      @application_key = 'E6j_$4UnR_)0b'
    end

    # The current logger. If no logger has been set Lifecell::API.log is used.
    #
    def log
      @log || Lifecell::API.log
    end

    # Sets the +logger+ used by this instance of Lifecell::API
    #
    attr_writer :log

    def request(method, params = {})
      params = { accessKeyCode: @access_key_code }.merge(params)
      url = create_signed_url(method, params)

      log&.debug("[#{method}] request: #{url}")

      response = response(url)

      raise StatusError, "Received status code #{response.code} from server" unless response.code == '200'

      log&.debug("[#{method}] response: #{response.body}")

      xml = parse_xml(response.body)
      return xml if xml['responseCode'] == '0'

      raise_error!(xml)
    end

    private

    def raise_error!(xml)
      raise MethodError, "Unknown error: #{xml}" unless xml['responseCode']

      error_message = Lifecell::RESPONSE_CODES[xml['responseCode']]
      error_message ||= "Unknown error code #{xml['responseCode']}"
      raise MethodError, error_message
    end

    def response(url)
      uri = URI(url)
      request = Net::HTTP::Get.new(uri.request_uri)

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
    end

    def create_signed_url(method, params)
      query = create_param(params)
      str = method + '?' + query + '&signature='

      digest = OpenSSL::Digest.new('sha1')
      hash = OpenSSL::HMAC.digest(digest, @application_key, str)

      hash = Base64.encode64(hash).chomp

      str += urlencode(hash)

      @api_url + str
    end

    # Returns a string representation of the receiver suitable for use
    # as a URL query string
    def create_param(params)
      params.map do |key, value|
        "#{urlencode(key)}=#{urlencode(value)}"
      end.sort * '&'
    end

    # URL-encode a string
    def urlencode(str)
      CGI.escape(str.to_s)
    end

    def parse_xml(str)
      XmlSimple.xml_in(str, 'ForceArray' => false)
    end

    def base_api_parameters
      { msisdn: @msisdn, languageId: @lang, osType: @os_type, token: @token }
    end
  end
end
