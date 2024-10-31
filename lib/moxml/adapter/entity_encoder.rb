module Moxml
  module Adapter
    class EntityEncoder
      ORD_AMP = "&".ord
      ORD_LT = "<".ord
      ORD_GT = ">".ord
      ORD_APOS = "'".ord
      ORD_QUOT = '"'.ord
      ORD_NEWLINE = "\n".ord
      ORD_CARRIAGERETURN = "\r".ord

      def self.encode(text, attr = false)
        text.to_s.chars.map(&:ord).map do |i|
          if i == ORD_AMP
            "&amp;"
          elsif i == ORD_LT
            "&lt;"
          elsif i == ORD_GT
            "&gt;"
          elsif i == ORD_QUOT && attr
            "&quot;"
          elsif i == ORD_APOS && attr
            "&apos;"
          elsif i == ORD_NEWLINE || i == ORD_CARRIAGERETURN
            i.chr("utf-8")
          elsif i < 0x20
            "&#x#{i.to_s(16).rjust(4, "0")};"
          else
            i.chr("utf-8")
          end
        end.join
      end

      def self.decode(text)
        text.to_s.gsub(/&([a-zA-Z0-9#]+);/) do |entity|
          case entity
          when "&lt;" then "<"
          when "&gt;" then ">"
          when "&amp;" then "&"
          when "&quot;" then '"'
          when "&apos;" then "'"
          else
            if entity.start_with?("&#x")
              [entity[3..-2].to_i(16)].pack("U")
            elsif entity.start_with?("&#")
              [entity[2..-2].to_i].pack("U")
            else
              entity
            end
          end
        end
      end
    end
  end
end
