module Request
  module Multipart
    BOUNDARY = "--ruby-request--"
    DEFAULT_MIME = "application/octet-stream"

    def self.create files, data
      Fields.new(files, data)
    end

    class Fields
      def initialize files, data
        @files = files || []
        @params = data || []
      end

      def body
        @body ||= '' << @files.inject("") { |acc, file|
          acc << Attachment.new(*file).part
        } << @params.inject("") { |acc, param|
          acc << Param.new(*param).part
        } << "--#{BOUNDARY}--\r\n\r\n"
      end

      def header
        @header ||= {"Content-Length" => @body.bytesize.to_s,
                     "Content-Type"   => "multipart/form-data; boundary=#{BOUNDARY}"}
      end
    end

    class Attachment < Struct.new(:field, :file, :filename)
      def part
        return @part if @part
        type = ::MIME::Types.type_for(filename).first || DEFAULT_MIME
        @part = ''
        @part << "--#{BOUNDARY}\r\n"
        @part << "Content-Disposition: form-data; name=\"#{field}\"; filename=\"#{filename}\"\r\n"
        @part << "Content-Type: #{type}\r\n\r\n"
        @part << "#{file.read}\r\n"
      end
    end

    class Param < Struct.new(:field, :value)
      def part
        return @part if @part
        @part = ''
        @part << "--#{BOUNDARY}\r\n"
        @part << "Content-Disposition: form-data; name=\"#{field}\"\r\n"
        @part << "\r\n"
        @part << "#{value}\r\n"
      end
    end
  end
end
