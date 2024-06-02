# frozen_string_literal: true

require "yaml"
require "set"

require_relative "envy/version"
require_relative "envy/error"

module Envy
  extend self

  def from_file(*files, perm: nil)
    load_wrap do
      set_perms(files, perm: perm)

      if found = files.find { |file| File.readable?(file) }
        return load_yaml(found, force: false)
      end

      raise Error, "Env file(s) not found or not readable"
    end
  end

  def from_file!(*files, perm: nil)
    load_wrap do
      set_perms(files, perm: perm)

      if found = files.find { |file| File.readable?(file) }
        return load_yaml(found, force: true)
      end

      raise Error, "Env file(s) not found or not readable"
    end
  end

  private

  def load_yaml(path, force:)
    File.open(path) { |file| set_envs YAML.safe_load(file), force: force }
    nil
  end

  def set_perms(files, perm: nil)
    perm ||= 0o600
    File.chmod(perm, *files)
  rescue SystemCallError # rubocop:disable Lint/SuppressedException
  end

  # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
  def set_envs(yaml, prev_key = "", force:)
    case yaml
    when Hash
      yaml.each do |key, value|
        env_key = "#{prev_key}_#{key.to_s.upcase}".sub(/\A_/, "")
        set_envs(value, env_key, force: force)
      end
    when Array, Set
      yaml.each_with_index do |value, index|
        env_key = "#{prev_key}_#{index}".sub(/\A_/, "")
        set_envs(value, env_key, force: force)
      end
    else
      return if prev_key.empty?

      ENV[prev_key] = yaml.to_s if force || ENV[prev_key].nil?
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

  def load_wrap
    var = "ENVY_LOADED"
    return if ENV[var] == "yes"

    begin
      yield
    ensure
      ENV[var] = "yes"
    end
  end
end
