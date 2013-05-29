#!/usr/bin/env ruby

require 'aws-sdk'
require 'slop'

KEY_NAME = 'Cloud Foundry'

VERSION_SPECIFIC = {
  :six => {
    :repository => 'http://hg.openjdk.java.net/jdk6/jdk6',
    :cloud_config => 'cloud-config-6and7.yml',
    :remote_build => 'remote-build-6and7.rb'
  },
  :seven => {
    :repository => 'http://hg.openjdk.java.net/jdk7u/jdk7u',
    :cloud_config => 'cloud-config-6and7.yml',
    :remote_build => 'remote-build-6and7.rb'
  },
  :eight => {
    :repository => 'http://hg.openjdk.java.net/jdk8/jdk8',
    :cloud_config => 'cloud-config-8.yml',
    :remote_build => 'remote-build-8.rb'
  }
}

def build_multipart(options, version_specific)
  multipart = <<-EOF
Content-Type: multipart/mixed; boundary="===============7910318705544163955=="
MIME-Version: 1.0

--===============7910318705544163955==
MIME-Version: 1.0
Content-Type: text/cloud-config; charset="UTF-8"
Content-Disposition: attachment

#{File.read(version_specific[:cloud_config])}
--===============7910318705544163955==
MIME-Version: 1.0
Content-Type: text/x-shellscript; charset="UTF-8"
Content-Disposition: attachment

#!/usr/bin/env bash
gem install aws-sdk --no-ri --no-rdoc

--===============7910318705544163955==
MIME-Version: 1.0
Content-Type: text/x-shellscript; charset="UTF-8"
Content-Disposition: attachment

#{File.read(version_specific[:remote_build])}
--===============7910318705544163955==--

  EOF

  multipart
    .gsub(/@@ACCESS_KEY@@/, options[:access_key])
    .gsub(/@@BUCKET@@/, options[:bucket])
    .gsub(/@@BUILD_NUMBER@@/, options[:build_number])
    .gsub(/@@VERSION@@/, options[:version])
    .gsub(/@@REPOSITORY@@/, version_specific[:repository])
    .gsub(/@@SECRET_ACCESS_KEY@@/, options[:secret_access_key])
    .gsub(/@@TAG@@/, options[:tag])
end

def version_specific(version)
  if version =~ /^1.6/
    version_specific = VERSION_SPECIFIC[:six]
  elsif version =~ /^1.7/
    version_specific = VERSION_SPECIFIC[:seven]
  elsif version =~ /^1.8/
    version_specific = VERSION_SPECIFIC[:eight]
  else
    raise "Unable to process version '#{version}'"
  end

  version_specific
end

def parse_command_line
  Slop.parse :help => true do
    banner "Usage: bundle exec #{$0} [OPTIONS]"

    on :a, :access_key=, 'AWS access key', :argument => true, :required => true
    on :b, :bucket=, 'AWS S3 bucket name to upload the distribution to', :argument => true, :required => true
    on :k, :key_name=, 'The name of the EC2 keypair to use when creating the instance.  This is optional and defaults to Cloud Foundry', :argument => true, :required => false, :default => KEY_NAME
    on :n, :build_number=, 'The build number of the JDK to create', :argument => true, :required => true
    on :s, :secret_access_key=, 'AWS secret access key to use', :argument => true, :required => true
    on :t, :tag=, 'The repository tag to build from', :argument => true, :required => true
    on :v, :version=, 'The version of the JDK to create', :argument => true, :required => true
  end
end

def start_instance(options)
  ec2 = AWS::EC2.new(
    :access_key_id => options[:access_key],
    :secret_access_key => options[:secret_access_key],
    :region => 'eu-west-1'
  )

  print 'Starting instance... '
  instance = ec2.instances.create(
    :image_id => 'ami-881d13fc',
    :instance_type => 'm1.small',
    :security_groups => 'default',
    :key_name => options[:key_name],
    :user_data => build_multipart(options, version_specific(options[:version]))
  )

  instance.tags['Name'] = "openjdk-#{options[:version]}-#{options[:build_number]}"
  puts 'OK'
end

# Main execution
options = parse_command_line
start_instance options
