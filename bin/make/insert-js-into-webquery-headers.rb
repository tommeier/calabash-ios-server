#!/usr/bin/env ruby
require 'fileutils'
require 'open3'
require "luffa"

this_dir = File.dirname(__FILE__)
calabash_js_dir = File.expand_path(File.join(this_dir, '..', '..', 'calabash-js'))

Dir.chdir(calabash_js_dir) do
  build_js_script = File.expand_path('./build.sh')
  unless File.exist?(build_js_script)
    Luffa.log_fail("FAIL: expected '#{build_js_script}' to exist")
    exit 1
  end

  options = {
    :pass_msg => 'Injected calabash-js into web view headers',
    :fail_msg => 'Could not inject calabash-js into web view headers'
  }

  exit_code = Luffa.unix_command(build_js_script, options)
  exit(exit_code)
end

