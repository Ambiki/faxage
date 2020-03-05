require 'httparty'

module Faxage
  class ReceiveFax
    include HTTParty
    base_uri "https://api.faxage.com"

    attr_reader :username, # Assigned FAXAGE username
                :company, # Assigned FAXAGE company credential
                :password # Assigned FAXAGE password

    def initialize(username:, company:, password:)
      @username = username
      @company = company
      @password = password
    end

    def listfax(**options)
      # This operation is used to gather a list of incoming faxes for your account.

      subdirectory = "/httpsfax.php"

      body = {
        operation: "listfax",
        username: username,
        company: company,
        password: password
      }.merge!(options)

      response = self.class.post(subdirectory,
        body: body
      )

      if response.parsed_response.nil?
        raise NoResponseError.new("An empty response was returned from Faxage.")
      elsif response.parsed_response.include?("ERR01: Database connection failed")
        raise FaxageInternalError.new("Internal FAXAGE error.")
      elsif response.parsed_response.include?("ERR02: Login incorrect")
        raise LoginError.new("One or more of username, company, password is incorrect or your account is disabled for some reason.")
      elsif response.parsed_response.include?("ERR08: Unknown operation")
        raise UnknownOperationError.new("Either operation is not correctly hard coded or the POST was bad, the POST contents are returned for debugging purposes. #{response.parsed_response}")
      elsif response.parsed_response.include?("ERR11: No incoming faxes available")
        raise NoIncomingFaxesError.new("There are no incoming faxes to list for you.")
      else
        return response.parsed_response
      end
    end
  end
end