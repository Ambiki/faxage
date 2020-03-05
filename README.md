# Faxage

Faxage is a Ruby wrapper for the [faxage.com](https://www.faxage.com/internet-fax-api.php) API.

The Faxage API can be used to send and receive faxes, gather sent fax images and transmittal pages, provision DIDs, enable and disable (busy out) DIDs, access CDRs, get realtime status, can be polled or can push sent and received fax notifications, check local number portability, manage users, retrieve system audit logs and more.

The author of this gem is not affliated with Faxage. The Faxage API docs can be found [here](https://www.faxage.com/docdl.php?docid=6).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'faxage'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install faxage

## Usage

#### Supported File Types

As of this writing, the following file types are supported for sending, others may become
available over time, so please check with us if the type of content you wish to send is not
listed here. An automatically updated list (based on what FAXAGE is configured to
support) is available at the following URL: http://www.faxage.com/learn_faxage_send_faxes_email_website_api.php

Click the link for ‘Q: What types of files can I send?’ on the above URL to get the list.

| Description                          | Extension(s) |
|--------------------------------------|--------------|
| Adobe PDF                            | PDF          |
| Adobe PostScript                     | PS           |
| Microsoft Word                       | DOC or DOCX  |
| Microsoft Word Template              | DOT          |
| Microsoft Works                      | WPS          |
| WordPerfect                          | WPD          |
| OpenOffice / LibreOffice Document    | ODT          |
| Rich Text                            | RTF          |
| Microsoft Excel                      | XLS or XLSX  |
| Microsoft Powerpoint                 | PPT or PPTX  |
| OpenOffice / LibreOffice Spreadsheet | ODS          |
| Comma-separated CSV                  | CSV          |
| HTML                                 | HTM, HTML    |
| Bitmap Image                         | BMP          |
| GIF Image                            | GIF          |
| JPEG Image                           | JPG, JPEG    |
| TIFF Image                           | TIF, TIFF    |
| PNG Image                            | PNG          |
| HP Printer Control Language          | PCL          |
| Plain Text                           | TXT          |

#### Error Types

```ruby
class LoginError < StandardError
  # "One or more of username, company, password is incorrect or your account is disabled for some reason."
end

class FaxageInternalError < StandardError
  # "Internal FAXAGE error."
end

class UnknownOperationError < StandardError
  # "Either operation is not correctly hard coded or the POST was bad, the POST contents are returned for debugging purposes. #{response.parsed_response}"
end

class NoResponseError < StandardError
  # "An empty response was returned from Faxage."
end

class InvalidJobIdError < StandardError
  # "Internal FAXAGE error – the job was not properly inserted into our database."
end

class InvalidFaxNoError < StandardError
  # "The faxno variable does not contain a 10-digit numeric only string."
end

class NoFilesError < StandardError
  # "No valid files were found in faxfilenames[] and/or faxfiledata[]."
end

class BlockedNumberError < StandardError
  # "The number you tried to fax to was blocked (outside of continental US, Canada and Hawaii or a 555, 911, or other invalid/blocked type of number)."
end

class NoIncomingFaxesError < StandardError
  # "There are no incoming faxes to list for you."
end

class FaxIdNotFoundError < StandardError
  # The faxid passed in is invalid or is an ID that does not belong to your company.
end
```


#### Sending a fax

##### sendfax

This operation is used to send a fax.

```ruby

Faxage::SendFax.new(
  username: # Assigned FAXAGE username
  company: # Assigned FAXAGE company credential
  password: # Assigned FAXAGE password
  recipname: # Recipient Name – 32 characters max
  faxno: # Fax Number – 10 digits, numeric only
  faxfilenames: # Array of file names. These must end in a
  # supported extension – see the table above for a list
  faxfiledata: # Corresponding array of base64-encoded strings that are the
  # contents/data of the file in faxfilenames. E.g.: if faxfilenames[0] is
  # test.doc, then faxfiledata[0] should be the base64-encoded contents
  # of test.doc
  debug: # A debugging URL is also provided that is equivalent to
  # the httpsfax.php URL, except that
  # it also returns the contents of your POST:
  # Note that the debugging URL is still live and identical to the
  # regular/production URL.
  # For example, if you send a fax using the sendfax operation with
  # the debugging URL, the fax will still get sent as normal.
).sendfax()

# Practical example of faxing a template from your Rails app:
# html = ActionController::Base.new().render_to_string(template: 'path-to-your-template')
# encoded_file_data = Base64.encode64(html)

Faxage::SendFax.new(
  username: "your-username", # string
  company: "your-faxage-company-id", # string
  password: "your-faxage-password", # string
  recipname: "ABC company", #string
  faxno: "5555555555", # string (no hyphens, parenthesis, or spaces)
  faxfilenames: ['my-file.html'],
  faxfiledata: [encoded_file_data],
  debug: false
).sendfax()

# Expected response:

# {
#   job_id: 543211
# }


```

#### Receiving a fax

##### listfax
This operation is used to gather a list of incoming faxes for your account.

```ruby
Faxage::ReceiveFax.new(
  username: # Assigned FAXAGE username
  company: # Assigned FAXAGE company credential
  password: # Assigned FAXAGE password
).listfax()
```

##### getfax
This operation is used to download a received fax image.
```ruby
Faxage::ReceiveFax.new(
  username: # Assigned FAXAGE username
  company: # Assigned FAXAGE company credential
  password: # Assigned FAXAGE password
).getfax(recvid:) # The numeric ID of the fax to get, retrieved from the listfax operation (the recvid in listfax)

# The actual data returned will be the binary contents of the fax itself.

# A practical example of uploading the file to AWS S3 in a Rails application could look like:

get_fax = Faxage::ReceiveFax.new(
  username: # Assigned FAXAGE username
  company: # Assigned FAXAGE company credential
  password: # Assigned FAXAGE password
).getfax(recvid:)

creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
s3_resource = Aws::S3::Resource.new(region: ENV['AWS_S3_REGION'], credentials: creds)
obj = s3_resource.bucket(ENV['AWS_BUCKET_NAME']).object("path-to-your-file-on-S3/your-file-name.pdf")
obj.put(body: get_fax)

```

#### Information Gathering Operations

These operations relate to gathering information that helps with managing and/or
monitoring your overall FAXAGE account.

##### handlecount
This operation allows you to see how many incoming faxes are stored within FAXAGE and, of those, how many you have marked as handled using the handled operation.

```ruby
Faxage::InformationGathering.new(
  username: # Assigned FAXAGE username
  company: # Assigned FAXAGE company credential
  password: # Assigned FAXAGE password
).handlecount

# Example response:
# {
#   total_count: 10,
#   handled_count: 5
# }
```

##### pendcount
This operation allows you to see how many outgoing faxes are currently pending to be sent on your FAXAGE account.

```ruby
Faxage::InformationGathering.new(
  username: # Assigned FAXAGE username
  company: # Assigned FAXAGE company credential
  password: # Assigned FAXAGE password
).pendcount

# Example response:
# {
#   pending_count: 10
# }
```

##### qstatus
This operation allows you to gather details about how your outgoing pending faxes are currently queued. When you have more than one line on your FAXAGE account, the system automatically load-levels outgoing faxes across however many lines you have. Using this operation, you can see all of your pending outgoing faxes and which line(s) they are queued on, in order to analyze how your outgoing traffic is being distributed for sending by FAXAGE.

```ruby
Faxage::InformationGathering.new(
  username: # Assigned FAXAGE username
  company: # Assigned FAXAGE company credential
  password: # Assigned FAXAGE password
).qstatus
```

##### incomingcalls
This operation allows you to see how many incoming calls are currently in progress to your account and how many maximum total simultaneous calls your account is currently configured to allow without sending a busy signal.

```ruby
Faxage::InformationGathering.new(
  username: # Assigned FAXAGE username
  company: # Assigned FAXAGE company credential
  password: # Assigned FAXAGE password
).incomingcalls

# Example response:
# {
#   incoming_count: 0,
#   allocated_count: 1
# }
```

##### busycalls
This operation allows you to see incoming calls that have experienced a busy signal because more calls were in progress at the time the call came than your account was configured to support.

```ruby
Faxage::InformationGathering.new(
  username: # Assigned FAXAGE username
  company: # Assigned FAXAGE company credential
  password: # Assigned FAXAGE password
).busycalls
```

##### portstatus
This operation allows you to see the status of port requests you have in progress or that have been completed with FAXAGE.

```ruby
Faxage::InformationGathering.new(
  username: # Assigned FAXAGE username
  company: # Assigned FAXAGE company credential
  password: # Assigned FAXAGE password
).portstatus
```

##### auditlog
This operation allows you to retrieve audit logs for your FAXAGE account. The FAXAGE auditing system is a comprehensive system that keeps a trail of all activities within your account. See the FAXAGE Internet Fax Auditing Documentation for details as to the structure of audit logs and what data is contained within each type of auditable operation.

```ruby
Faxage::InformationGathering.new(
  username: # Assigned FAXAGE username
  company: # Assigned FAXAGE company credential
  password: # Assigned FAXAGE password
).auditlog
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/diasks2/faxage. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Faxage project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/diasks2/faxage/blob/master/CODE_OF_CONDUCT.md).
