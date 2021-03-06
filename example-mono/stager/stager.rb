#!/usr/bin/env ruby

# The API is located at: https://github.com/apcera/continuum-stager-api-ruby
#
# To delete the stager:
#     apc staging pipeline delete /apcera::mono --batch 
#     apc stager delete /apcera/stagers::mono --batch
#
# Create the stager & pipeline:
#     apc stager create mono --start-command="./stager.rb" --staging=/apcera::ruby --batch --namespace /apcera/stagers
#     apc staging pipeline create /apcera/stagers::mono --name mono  --namespace /apcera --batch
#
# Use the stager:
#     apc app create my-app --staging=/apcera::mono --start
#
# OR- if you specify staging_pipeline: "/apcera::mono" in the manifest, just:
#     apc app create my-app --start
#

require "bundler"
Bundler.setup

require "apcera-stager-api"

# Make sure stdout is sync'd.
#
STDOUT.sync = true
stager = Apcera::Stager.new

puts "Adding dependencies"

if stager.dependencies_add("runtime", "mono")
  stager.relaunch
end

# Download the package from the staging coordinator.
# 
puts "Downloading Package..."
stager.download

# Extract the package to the "app" directory so we don't overwrite 
# anything in /
#
puts "Extracting Package..."
stager.extract("app")

# Set the start path.
# 
start_path = "/app"
puts "Setting start path to '#{start_path}'"
stager.start_path = start_path

# Set the start command.
# There is a built-in server for mono:
#    "xsp4 --port $PORT --verbose --nonstop"
# However it is better to use nginx+fastcgi, so we have wrapped that
# in a script (startMonoFastcgi.sh) as part of the runtime:
#
start_cmd = "/bin/startMonoFastcgi.sh $PORT"
puts "Setting start command to '#{start_cmd}'"
stager.start_command = start_cmd

# Finish staging, this will upload your final package to the
# staging coordinator.
# 
puts "Completed Staging..."
stager.complete
