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

#### Sending a fax
```ruby
Faxage::SendFax.new(
  username: # Assigned FAXAGE username
  company: # Assigned FAXAGE company credential
  password: # Assigned FAXAGE password
  recipname: # Recipient Name – 32 characters max
  faxno: # Fax Number – 10 digits, numeric only
  faxfilenames: # Array of file names. These must end in a
  # supported extension – see the table above for a list
  faxfiledata: # Corresponding array of file locations. E.g.: if faxfilenames[0] is
  # test.doc, then faxfiledata[0] should be the location
  # of test.doc
  debug: # A debugging URL is also provided that is equivalent to
  # the httpsfax.php URL, except that
  # it also returns the contents of your POST:
  # Note that the debugging URL is still live and identical to the
  # regular/production URL.
  # For example, if you send a fax using the sendfax operation with
  # the debugging URL, the fax will still get sent as normal.
).send_fax()
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
  password: # Assigned FAXAGE password'
).handlecount

# Example response: {
  total_count: 10,
  handled_count: 5
}
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
