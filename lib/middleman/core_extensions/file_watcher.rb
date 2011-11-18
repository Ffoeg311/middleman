require "find"

module Middleman::CoreExtensions::FileWatcher
  class << self
    def registered(app)
      app.extend ClassMethods
      app.send :include, InstanceMethods
      app.before_configuration do
        Find.find(settings.root) do |path|
          next if File.directory?(path)
          file_did_change(path.sub("#{settings.root}/", ""))
        end
      end

    end
    alias :included :registered
  end
  
  module ClassMethods
    def file_changed(matcher=nil, &block)
      @_file_changed ||= []
      @_file_changed << [block, matcher] if block_given?
      @_file_changed
    end
    
    def file_deleted(matcher=nil, &block)
      @_file_deleted ||= []
      @_file_deleted << [block, matcher] if block_given?
      @_file_deleted
    end
    
    def file_did_change(path)
      file_changed.each do |callback, matcher|
        next if path.match(%r{^#{build_dir}/})
        next if !matcher.nil? && !path.match(matcher)
        instance_exec(path, &callback)
      end
    end

    def file_did_delete(path)
      file_deleted.each do |callback, matcher|
        next if path.match(%r{^#{build_dir}/})
        next unless matcher.nil? || path.match(matcher)
        instance_exec(path, &callback)
      end
    end
  end
  
  module InstanceMethods
    def file_did_change(path)
      settings.file_did_change(path)
    end
    
    def file_did_delete(path)
      settings.file_did_delete(path)
    end
  end
end