# frozen_string_literal: true

require 'spec_helper'
require 'lifecell_api'

RSpec.describe Lifecell::API do
  it 'initialize' do
    lifecell_api = Lifecell::API.new(msisdn: '380xxxxxxxxx', password: 'xxxxxx', lang: 'uk')
    expect(lifecell_api).to be_a(Lifecell::API)
    expect(lifecell_api.token).to be_nil
  end
end
