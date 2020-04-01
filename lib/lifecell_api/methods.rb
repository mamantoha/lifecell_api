# frozen_string_literal: true

# The list of available API method names:
# (16/22)
#
# [-] activateDeactivateService
# [+] callMeBack
# [+] changeLanguage
# [+] changeSuperPassword
# [-] changeTariff
# [+] getAvailableTariffs
# [+] getBalances
# [+] getExpensesSummary
# [+] getLanguages
# [+] getPaymentsHistory
# [-] getSeparateBalances
# [+] getServices
# [+] getSummaryData
# [+] getToken
# [+] getUIProperties
# [-] offerAction
# [+] refillBalanceByScratchCard
# [-] removeFromPreProcessing
# [+] requestBalanceTransfer
# [+] signIn
# [+] signOut
# [-] transferBalance

# :nodoc:
module Lifecell
  # :nodoc:
  class API
    def sign_in
      xml = request('signIn', msisdn: @msisdn, superPassword: @password)
      @token = xml['token']
      @sub_id = xml['subId']
      xml
    end

    def sign_out
      request(
        'signOut',
        msisdn: @msisdn,
        subId: @sub_id
      )
    end

    def change_super_password(old_password, new_password)
      request(
        'changeSuperPassword',
        base_api_parameters.merge(
          oldPassword: old_password,
          newPassword: new_password
        )
      )
    end

    def token
      request(
        'getToken',
        msisdn: @msisdn, subId: @sub_id
      )
    end

    # +last_date_update+ is DateTime object
    #
    def ui_properties(language_id, last_date_update)
      request(
        'getUIProperties',
        accessKeyCode: @access_key_code,
        languageId: language_id,
        osType: @os_type,
        lastDateUpdate: last_date_update
      )
    end

    def summary_data
      request(
        'getSummaryData',
        base_api_parameters
      )
    end

    def services
      request('getServices', base_api_parameters)
    end

    def available_tariffs
      request(
        'getAvailableTariffs',
        base_api_parameters
      )
    end

    def balances
      request(
        'getBalances',
        base_api_parameters
      )
    end

    def languages
      request(
        'getLanguages',
        base_api_parameters
      )
    end

    def change_language(new_language_id)
      request(
        'changeLanguage',
        base_api_parameters.merge(newLanguageId: new_language_id)
      )
    end

    def call_me_back(msisdn_b)
      request(
        'callMeBack',
        base_api_parameters.merge(msisdnB: msisdn_b)
      )
    end

    def request_balance_transfer(msisdn_b)
      request(
        'requestBalanceTransfer',
        base_api_parameters.merge(msisdnB: msisdn_b)
      )
    end

    # Payments history for calendar month +month_period+
    #
    # +month_period+ - A string like 'yyyy-MM' that represent month of year
    #
    def payments_history(month_period)
      request(
        'getPaymentsHistory',
        base_api_parameters.merge(monthPeriod: month_period)
      )
    end

    # Summary expenses report for calendar month +month_period+
    #
    # +month_period+ - A string like 'yyyy-MM' that represent month of year
    #
    def expenses_summary(month_period)
      request(
        'getExpensesSummary',
        base_api_parameters.merge(monthPeriod: month_period)
      )
    end

    def refill_balance_by_scratch_card(secret_code)
      request(
        'refillBalanceByScratchCard',
        base_api_parameters.merge(secretCode: secret_code)
      )
    end
  end
end
