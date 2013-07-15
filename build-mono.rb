#!/usr/bin/env ruby

require 'aws-sdk'
require 'slop'

KEY_NAME = 'Cloud Foundry'

VERSION_SPECIFIC = {
  :three => {
    :repository => 'https://github.com/mono/mono.git',
    :cloud_config => 'cloud-config-3.yml',
    :remote_build => 'remote-build-3.rb'
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
    .gsub(/@@SECRET_ACCESS_KEY@@/, options[:secret_access_key])
    .gsub(/@@BUCKET@@/, options[:bucket])
    .gsub(/@@VERSION@@/, options[:version])
    .gsub(/@@TAG@@/, options[:tag])
    .gsub(/@@REPOSITORY@@/, version_specific[:repository])
end

def version_specific(version)
  if version =~ /^3./
    version_specific = VERSION_SPECIFIC[:three]
  else
    raise "Unable to process version '#{version}'"
  end

  version_specific
end

def parse_command_line
  Slop.parse :help => true do
    banner "Usage: bundle exec #{$0} [OPTIONS]"

    on :a, :access_key=, 'AWS access key', :argument => true, :required => true
    on :s, :secret_access_key=, 'AWS secret access key to use', :argument => true, :required => true
    on :b, :bucket=, 'AWS S3 bucket name to upload the distribution to', :argument => true, :required => true
    on :k, :key_name=, 'The name of the EC2 keypair to use when creating the instance.  This is optional and defaults to Cloud Foundry', :argument => true, :required => false, :default => KEY_NAME
    on :v, :version=, 'The version of the JDK to create', :argument => true, :required => true
    on :t, :tag=, 'The [github.com/mono/mono] repository tag to build from', :argument => true, :required => true

  end
end

def start_instance(options)
  ec2 = AWS::EC2.new(
    :access_key_id => options[:access_key],
    :secret_access_key => options[:secret_access_key],
    :region => 'us-east-1'
  )

  print 'Starting instance... '
  instance = ec2.instances.create(
    :image_id => 'ami-1ab3ce73', # us-east-1 lucid 10.04 LTS amd64 instance-store  20130704  ami-1ab3ce73
    :instance_type => 'm1.small',
    :security_groups => 'default',
    :key_name => options[:key_name],
    :user_data => build_multipart(options, version_specific(options[:version]))
  )

  instance.tags['Name'] = "builder-mono-#{options[:version]}"
  puts "Instance running at: #{instance.dns_name}"
  puts "After about 5 minutes you can see build progress by running:"
  puts "ssh ubuntu@#{instance.dns_name} -i ~/.ssh/#{options[:key_name]}.pem 'tail -f /tmp/build-output.txt'"
end

# Main execution
options = parse_command_line
start_instance options
