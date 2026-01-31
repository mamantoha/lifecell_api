# frozen_string_literal: true

require 'spec_helper'
require 'lifecell_api'

RSpec.describe Lifecell::API do
  let(:msisdn) { '380630000000' }
  let(:password) { 'passw0rd' }
  let(:token) { 'T0KEN' }

  it 'initialize' do
    lifecell_api = described_class.new(msisdn: '380xxxxxxxxx', password: 'xxxxxx', lang: 'uk')
    expect(lifecell_api).to be_a(described_class)
    expect(lifecell_api.token).to be_nil
  end

  it 'sign_in', :vcr do
    lifecell_api = described_class.new(msisdn:, password:, lang: 'uk')
    lifecell_api.sign_in

    expect(lifecell_api.token).to eq(token)
  end

  it 'summary_data', :vcr do
    lifecell_api = described_class.new(msisdn:, password:, lang: 'uk')
    lifecell_api.sign_in

    expect(lifecell_api.token).to eq(token)

    summary_data = lifecell_api.summary_data

    expect(summary_data['subscriber']['tariff']['name']).to eq('Internet Heat')
  end
end
