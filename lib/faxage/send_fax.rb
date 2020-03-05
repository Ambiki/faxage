require 'httparty'

module Faxage
  class SendFax
    include HTTParty
    base_uri "https://api.faxage.com"
    JOB_ID_REGEX = /(?<=JOBID:)\s+\d+/

    attr_reader :username, # Assigned FAXAGE username
                :company, # Assigned FAXAGE company credential
                :password, # Assigned FAXAGE password
                :recipname, # Recipient Name – 32 characters max
                :faxno, # Fax Number – 10 digits, numeric only
                :faxfilenames, # Array of file names. These must end in a
                # supported extension – see the table in the README for a list
                :faxfiledata, # Corresponding array of base64-encoded strings that are the
                # contents/data of the file in faxfilenames. E.g.: if faxfilenames[0] is
                # test.doc, then faxfiledata[0] should be the base64-encoded contents
                # of test.doc
                :debug # A debugging URL is also provided that is equivalent to
                # the httpsfax.php URL, except that
                # it also returns the contents of your POST:
                # Note that the debugging URL is still live and identical to the
                # regular/production URL.
                # For example, if you send a fax using the sendfax operation with
                # the debugging URL, the fax will still get sent as normal.
    def initialize(username:, company:, password:, recipname:, faxno:, faxfilenames:, faxfiledata:, debug:)
      @username = username
      @company = company
      @password = password
      @recipname = recipname
      @faxno = faxno
      @faxfilenames = faxfilenames
      @faxfiledata = faxfiledata
      @debug = debug
    end

    def sendfax(**options)
      if debug
        subdirectory = "/httpsfax-debug.php"
      else
        subdirectory = "/httpsfax.php"
      end

      body = {
        operation: "sendfax",
        username: username,
        company: company,
        password: password,
        recipname: recipname,
        faxno: faxno,
        faxfilenames: faxfilenames,
        faxfiledata: faxfiledata
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
      elsif response.parsed_response.include?("ERR03: No files to fax")
        raise NoFilesError.new("No valid files were found in faxfilenames[] and/or faxfiledata[].")
      elsif response.parsed_response.include?("ERR04: Fax number")
        raise InvalidFaxNoError.new("The faxno variable does not contain a 10-digit numeric only string.")
      elsif response.parsed_response.include?("ERR05")
        raise BlockedNumberError.new("The number you tried to fax to was blocked (outside of continental US, Canada and Hawaii or a 555, 911, or other invalid/blocked type of number).")
      elsif response.parsed_response.include?("ERR08: Unknown operation")
        raise UnknownOperationError.new("Either operation is not correctly hard coded or the POST was bad, the POST contents are returned for debugging purposes. #{response.parsed_response}")
      elsif response.parsed_response.include?("ERR15: Invalid Job ID")
        raise InvalidJobIdError.new("Internal FAXAGE error – the job was not properly inserted into our database.")
      else
        debug_output = response.parsed_response
        job_id = response.parsed_response.scan(JOB_ID_REGEX)[0].strip.to_i
        if debug
          data = {
            job_id: job_id,
            debug: debug_output
          }
        else
          data = {
            job_id: job_id
          }
        end
        return data
      end
    end
  end
end