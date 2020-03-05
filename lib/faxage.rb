require "faxage/version"
require "faxage/send_fax"
require "faxage/information_gathering"

class LoginError < StandardError
end

class FaxageInternalError < StandardError
end

class UnknownOperationError < StandardError
end

class NoResponseError < StandardError
end

class InvalidJobIdError < StandardError
end

class InvalidFaxNoError < StandardError
end

class NoFilesError < StandardError
end

class BlockedNumberError < StandardError
end