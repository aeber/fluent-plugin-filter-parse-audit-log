require 'fluent_plugin_filter_parse_audit_log/version'
require 'audit_log_parser'

class FluentParseAuditLogFilter < Fluent::Filter
  Fluent::Plugin.register_filter('parse_audit_log', self)

  config_param :key, :string, default: 'message'
  config_param :flatten, :bool, default: false
  config_param :keep_keys, :array, default: nil

  def filter(tag, time, record)
    line = record[@key]
    return record unless line
    new_record = AuditLogParser.parse_line(line, flatten: @flatten)
    @keep_keys.each do |k|
      new_record[k] = record[k] if record.has_key?(k)
    end if @keep_keys

    new_record
  rescue => e
    log.warn "failed to parse a audit log: #{line}", error_class: e.class, error: e.message
    log.warn_backtrace
    record
  end
end
