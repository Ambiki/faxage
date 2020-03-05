require 'httparty'

module Faxage
  class LoginError < StandardError
  end

  class FaxageInternalError < StandardError
  end

  class UnknownOperationError < StandardError
  end

  class NoResponseError < StandardError
  end

  class InformationGathering
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

    def handlecount
      # This operation allows you to see how many incoming faxes are stored within FAXAGE
      # and, of those, how many you have marked as handled using the handled operation.
      subdirectory = "/httpsfax.php"

      body = {
        operation: "handlecount",
        username: username,
        company: company,
        password: password
      }

      response = self.class.post(subdirectory,
        body: body
      )

      if response.parsed_response.nil?
        raise NoResponseError.new("An empty response was returned from Faxage.")
      elsif response.parsed_response.include?("ERR02: Login incorrect")
        raise LoginError.new("One or more of username, company, password is incorrect or your account is disabled for some reason.")
      elsif response.parsed_response.include?("ERR01: Database connection failed")
        raise FaxageInternalError.new("Internal FAXAGE error.")
      elsif response.parsed_response.include?("ERR08: Unknown operation")
        raise UnknownOperationError.new("Either operation is not correctly hard coded or the POST was bad, the POST contents are returned for debugging purposes.")
      else
        parsed_response = response.parsed_response.gsub("\n", "").split("~")
        data = {
          total_count: parsed_response[0].to_i,
          handled_count: parsed_response[1].to_i
        }
        return data
      end
    end

    def pendcount
      # This operation allows you to see how many outgoing faxes are currently pending to be
      # sent on your FAXAGE account.

      subdirectory = "/httpsfax.php"

      body = {
        operation: "pendcount",
        username: username,
        company: company,
        password: password
      }

      response = self.class.post(subdirectory,
        body: body
      )

      if response.parsed_response.nil?
        raise NoResponseError.new("An empty response was returned from Faxage.")
      elsif response.parsed_response.include?("ERR02: Login incorrect")
        raise LoginError.new("One or more of username, company, password is incorrect or your account is disabled for some reason.")
      elsif response.parsed_response.include?("ERR01: Database connection failed")
        raise FaxageInternalError.new("Internal FAXAGE error.")
      elsif response.parsed_response.include?("ERR08: Unknown operation")
        raise UnknownOperationError.new("Either operation is not correctly hard coded or the POST was bad, the POST contents are returned for debugging purposes.")
      else
        parsed_response = response.parsed_response.gsub("\n", "").to_i
        data = {
          pending_count: parsed_response
        }
        return data
      end
    end

    def qstatus
      # This operation allows you to gather details about how your outgoing pending faxes are
      # currently queued. When you have more than one line on your FAXAGE account, the
      # system automatically load-levels outgoing faxes across however many lines you have.
      # Using this operation, you can see all of your pending outgoing faxes and which line(s)
      # they are queued on, in order to analyze how your outgoing traffic is being distributed for
      # sending by FAXAGE.
      subdirectory = "/httpsfax.php"

      body = {
        operation: "qstatus",
        username: username,
        company: company,
        password: password
      }

      response = self.class.post(subdirectory,
        body: body
      )

      if response.parsed_response.nil?
        raise NoResponseError.new("An empty response was returned from Faxage.")
      elsif response.parsed_response.include?("ERR02: Login incorrect")
        raise LoginError.new("One or more of username, company, password is incorrect or your account is disabled for some reason.")
      elsif response.parsed_response.include?("ERR01: Database connection failed")
        raise FaxageInternalError.new("Internal FAXAGE error.")
      elsif response.parsed_response.include?("ERR08: Unknown operation")
        raise UnknownOperationError.new("Either operation is not correctly hard coded or the POST was bad, the POST contents are returned for debugging purposes.")
      else
        # TODO - parse response

        # New-line separated records, as follows:
        # <jobid><tab><callerID><tab><destination><tab><lineid
        # ><tab><pagecount>
        # See qstatus record definition below.

        # CallerID – The caller ID you have requested when making the sendfax request, or your
        # account’s default if you do not set separate caller ID’s for outgoing faxes
        # Destination – The destination fax number for this outgoing fax
        # LineID – Unique numeric ‘line’ ID. If you see more than one fax with the same LineID,
        # that means FAXAGE has queued those faxes to the same line to be sent and one will
        # have to wait for the other to finish before it will dial
        # Pagecount – The number of pages associated with a given fax
        return response.parsed_response
      end
    end

    def incomingcalls
      # This operation allows you to see how many incoming calls are currently in progress to
      # your account and how many maximum total simultaneous calls your account is currently
      # configured to allow without sending a busy signal.

      subdirectory = "/httpsfax.php"

      body = {
        operation: "incomingcalls",
        username: username,
        company: company,
        password: password
      }

      response = self.class.post(subdirectory,
        body: body
      )

      if response.parsed_response.nil?
        raise NoResponseError.new("An empty response was returned from Faxage.")
      elsif response.parsed_response.include?("ERR02: Login incorrect")
        raise LoginError.new("One or more of username, company, password is incorrect or your account is disabled for some reason.")
      elsif response.parsed_response.include?("ERR01: Database connection failed")
        raise FaxageInternalError.new("Internal FAXAGE error.")
      elsif response.parsed_response.include?("ERR08: Unknown operation")
        raise UnknownOperationError.new("Either operation is not correctly hard coded or the POST was bad, the POST contents are returned for debugging purposes.")
      else
        parsed_response = response.parsed_response.gsub("\n", "").split("~")
        data = {
          incoming_count: parsed_response[0].to_i,
          allocated_count: parsed_response[1].to_i
        }
        return data
      end
    end

    def busycalls
      # This operation allows you to see incoming calls that have experienced a busy signal
      # because more calls were in progress at the time the call came than your account was
      # configured to support.

      subdirectory = "/httpsfax.php"

      body = {
        operation: "busycalls",
        username: username,
        company: company,
        password: password
      }

      response = self.class.post(subdirectory,
        body: body
      )

      if response.parsed_response.nil?
        raise NoResponseError.new("An empty response was returned from Faxage.")
      elsif response.parsed_response.include?("ERR02: Login incorrect")
        raise LoginError.new("One or more of username, company, password is incorrect or your account is disabled for some reason.")
      elsif response.parsed_response.include?("ERR01: Database connection failed")
        raise FaxageInternalError.new("Internal FAXAGE error.")
      elsif response.parsed_response.include?("ERR08: Unknown operation")
        raise UnknownOperationError.new("Either operation is not correctly hard coded or the POST was bad, the POST contents are returned for debugging purposes.")
      else
        # TODO - parse response

        # New-line separated records, formatted as follows:
        # <number-called><tab><number-calling><tab><time>
        # Where:
        # Number-called – Your number that was called
        # Number-calling – The Caller ID for the caller
        # Time – YYYY-MM-DD HH:MM:SS format

        return response.parsed_response
      end
    end

    def portstatus
      # This operation allows you to see the status of port requests you have in progress or that
      # have been completed with FAXAGE.

      subdirectory = "/httpsfax.php"

      body = {
        operation: "portstatus",
        username: username,
        company: company,
        password: password
      }

      response = self.class.post(subdirectory,
        body: body
      )

      if response.parsed_response.nil?
        raise NoResponseError.new("An empty response was returned from Faxage.")
      elsif response.parsed_response.include?("ERR02: Login incorrect")
        raise LoginError.new("One or more of username, company, password is incorrect or your account is disabled for some reason.")
      elsif response.parsed_response.include?("ERR01: Database connection failed")
        raise FaxageInternalError.new("Internal FAXAGE error.")
      elsif response.parsed_response.include?("ERR08: Unknown operation")
        raise UnknownOperationError.new("Either operation is not correctly hard coded or the POST was bad, the POST contents are returned for debugging purposes.")
      else
        # TODO - parse response

        # New-line separated records, formatted as follows:
        # <number><tab><request-date><tab><duedate><tab><completedate><tab><status><tab><comment><tab><complete>
        # Where:
        # Number – The number you are porting
        # Request-date – YYYY-MM-DD date of request
        # Due-date – YYYY-MM-DD expected completion date
        # Complete-date – YYYY-MM-DD date actually
        # completed 0000-00-00 for requests in progress
        # Status – One of ‘Initial’, ‘SOA PEND’, ‘Reject’,
        # ‘Completed’ or ‘Canceled’. SOA PEND means the
        # carrier has accepted for completion on the Due-date
        # Comment – Free-form comment about the current
        # status. FAXAGE staff enters these as ports are worked
        # Complete – Yes or No

        return response.parsed_response
      end
    end

    def auditlog(**options)
      # This operation allows you to retrieve audit logs for your FAXAGE account. The
      # FAXAGE auditing system is a comprehensive system that keeps a trail of all activities
      # within your account. See the FAXAGE Internet Fax Auditing Documentation for details
      # as to the structure of audit logs and what data is contained within each type of auditable
      # operation.

      subdirectory = "/httpsfax.php"

      body = {
        operation: "auditlog",
        username: username,
        company: company,
        password: password
      }.merge!(options)

      response = self.class.post(subdirectory,
        body: body
      )

      if response.parsed_response.nil?
        raise NoResponseError.new("An empty response was returned from Faxage.")
      elsif response.parsed_response.include?("ERR02: Login incorrect")
        raise LoginError.new("One or more of username, company, password is incorrect or your account is disabled for some reason.")
      elsif response.parsed_response.include?("ERR01: Database connection failed")
        raise FaxageInternalError.new("Internal FAXAGE error.")
      elsif response.parsed_response.include?("ERR08: Unknown operation")
        raise UnknownOperationError.new("Either operation is not correctly hard coded or the POST was bad, the POST contents are returned for debugging purposes.")
      else
        # TODO - parse response

        # <audit-id><tab><timestamp><tab><login><tab><ipaddress><tab><interface><tab><web
        # sessid><tab><auditop><tab><opstat><tab><requestdetail><tab><response-detail>
        # Each of the above fields is defined in detail in the
        # Internet Fax Auditing Documentation as previously
        # noted

        return response.parsed_response
      end
    end
  end
end