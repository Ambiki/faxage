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
        data = []
        response.parsed_response.split("\n").each do |received_fax|
          # <recvid><tab><recvdate>(OPTIONAL:
          # <tab><starttime>)
          # <tab><CID><tab><DNIS>(OPTIONAL:
          # <tab><filename>)(OPTIONAL:
          # <tab><pagecount>)(OPTIONAL: <tab><tsid>)
          individual_fax = Hash.new
          received_fax.split("\t").each_with_index do |item, index|
            if options[:starttime].nil?
              case index
              when 0
                individual_fax[:recvid] = item
              when 1
                individual_fax[:revdate] = item
              when 2
                individual_fax[:cid] = item
              when 3
                individual_fax[:dnis] = item
              when 4 && !options[:filename].nil?
                individual_fax[:filename] = item
              when 4 && options[:filename].nil? && !options[:pagecount].nil?
                individual_fax[:pagecount] = item
              when 4 && options[:filename].nil? && options[:pagecount].nil? && !options[:tsid].nil?
                individual_fax[:tsid] = item
              when 5 && !options[:filename].nil? && !options[:pagecount].nil?
                individual_fax[:pagecount] = item
              when 5 && !options[:filename].nil? && options[:pagecount].nil? && !options[:tsid].nil?
                individual_fax[:tsid] = item
              when 6 && !options[:filename].nil? && !options[:pagecount].nil? && !options[:tsid].nil?
                individual_fax[:tsid] = item
              end
            else
              case index
              when 0
                individual_fax[:recvid] = item
              when 1
                individual_fax[:revdate] = item
              when 2
                individual_fax[:starttime] = item
              when 3
                individual_fax[:cid] = item
              when 4
                individual_fax[:dnis] = item
              when 5 && !options[:filename].nil?
                individual_fax[:filename] = item
              when 5 && options[:filename].nil? && !options[:pagecount].nil?
                individual_fax[:pagecount] = item
              when 5 && options[:filename].nil? && options[:pagecount].nil? && !options[:tsid].nil?
                individual_fax[:tsid] = item
              when 6 && !options[:filename].nil? && !options[:pagecount].nil?
                individual_fax[:pagecount] = item
              when 6 && !options[:filename].nil? && options[:pagecount].nil? && !options[:tsid].nil?
                individual_fax[:tsid] = item
              when 7 && !options[:filename].nil? && !options[:pagecount].nil? && !options[:tsid].nil?
                individual_fax[:tsid] = item
              end
            end
            data << individual_fax
          end
        end
        return data
      end
    end
  end
end