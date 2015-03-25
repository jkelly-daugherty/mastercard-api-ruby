require_relative '../../../../common/connector'
require_relative '../../../../common/environment'
require_relative '../../../../common/url_util'
require_relative '../../../../services/locations/domain/common/countries/Country'
require_relative '../../../../services/locations/domain/common/countries/countries'

require 'rexml/document'
include REXML
include Mastercard::Common
include Mastercard::Services::Locations

module Mastercard
  module Services
    module Locations

      class CountryMerchantLocationService < Connector

        SANDBOX_URL = 'https://sandbox.api.mastercard.com/merchants/v1/country?Format=XML'
        PRODUCTION_URL = 'https://api.mastercard.com/merchants/v1/country?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_countries(options)
          url = get_url(options)
          doc = Document.new(do_request(url, 'GET'))
          generate_return_object(doc)
        end

        def get_url(options)
          url_util = URLUtil.new
          url = SANDBOX_URL.dup
          if @environment == PRODUCTION
            url = PRODUCTION_URL.dup
          end
          url = url_util.add_query_parameter(url, 'Details', options.details)
        end

        def generate_return_object(xml_body)
          xml_countries = xml_body.elements.to_a('Countries/Country')
          country_array = Array.new
          xml_countries.each do|xml_country|
            country = Country.new
            country.name = xml_country.elements['Name'].text
            country.code = xml_country.elements['Code'].text
            country.geo_coding = xml_country.elements['Geocoded'].text
            country_array.push(country)
          end
          countries = Countries.new(country_array)
        end

      end

    end
  end
end