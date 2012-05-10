require 'geocoder/lookups/base'
require "geocoder/results/google"

module Geocoder::Lookup
  class Google < Base

    def map_link_url(coordinates)
      "http://maps.google.com/maps?q=#{coordinates.join(',')}"
    end

    def query_url(query, reverse = false)
      params = {
        (reverse ? :latlng : :address) => query,
        :sensor => "false",
        :language => Geocoder::Configuration.language,
        :key => Geocoder::Configuration.api_key
      }
      "#{protocol}://maps.googleapis.com/maps/api/geocode/json?" + hash_to_query(params)
    end


    private # ---------------------------------------------------------------

    def results(query, reverse = false, cache_only = false)
      return [] unless doc = fetch_data(query, reverse, cache_only)
      case doc['status']; when "OK" # OK status implies >0 results
        cache[query_url(query, reverse)] = JSON.dump doc if cache
        return doc['results']
      when "OVER_QUERY_LIMIT"
        raise_error(Geocoder::OverQueryLimitError) ||
          warn("Google Geocoding API error: over query limit.")
      when "REQUEST_DENIED"
        warn "Google Geocoding API error: request denied."
      when "INVALID_REQUEST"
        warn "Google Geocoding API error: invalid request."
      end
      return []
    end
  end
end

