require 'httparty'

module Faxage
  class SendFax
    include HTTParty
    base_uri "https://api.faxage.com"

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

    def send_fax(**options)
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

      self.class.post(subdirectory,
        body: body
      )
    end
  end
end