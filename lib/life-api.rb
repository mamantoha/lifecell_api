# encoding: utf-8

require 'uri'
require 'cgi'
require 'net/https'
require 'openssl'
require 'base64'

require 'xmlsimple'

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
#   life = Life::API.new(msisdn: msisdn, password: password, lang: 'uk')
#   life.log = Logger.new($stderr)
#   life.sign_in
#   life.get_summary_data
#   life.sign_out
#
module Life

  class MethodError < ArgumentError; end

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
    '-21474833648' => 'INTERNAL_APPLICATION_ERROR',
  }

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
    # == Required parameters
    #
    # * +:msisdn+ - telephone number in format '38063*******'
    # * +:password+ - life:) super password
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

    def request(method, params = {})
      params = { accessKeyCode: @access_key_code }.merge(params)
      url = create_signed_url(method, params)

      log.debug("[#{method}] url: #{url}") if log

      uri = URI(url)
      request = Net::HTTP::Get.new(uri.request_uri)

      response = Net::HTTP.start(uri.host, uri.port,
        :use_ssl => uri.scheme == 'https') {|http|
        http.request(request)
      }

      xml =  parse_xml(response.body)

      if xml['responseCode']
        if xml['responseCode'] == '0'
          return xml
        else
          error_message = Life::RESPONSE_CODES[xml['responseCode']]
          error_message ||= "Unknown error code #{xml['responseCode']}"
          raise MethodError, error_message
        end
      else
        raise MethodError, "Unknown error: #{xml}"
      end

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
      return XmlSimple.xml_in(str, { 'ForceArray' => false })
    end

    def base_api_parameters
      return { msisdn: @msisdn, languageId: @lang, osType: @os_type, token: @token }
    end

  end
end
