#!/usr/bin/env ruby

require 'rubygems'
require 'aws-sdk'
require 'yaml'

STDOUT.sync = true

CACERTS_FILE = '/tmp/cacerts'
CACERTS_URI = 'http://curl.haxx.se/ca/cacert.pem'
FOREST_URI = 'https://bitbucket.org/pmezard/hgforest-crew/overview/'
SOURCE_ROOT = '/tmp/openjdk'
TO_LOG = '>> /tmp/build-output.txt 2>&1'

def clone(repository)
  puts "Cloning #{FOREST_URI} to /tmp/forest..."
  system "hg clone #{FOREST_URI} /tmp/forest #{TO_LOG}"
  system "printf \"[extensions]\nforest = /tmp/forest/forest.py\" >> /etc/mercurial/hgrc"

  puts "Cloning #{repository} to #{SOURCE_ROOT}..."
  system "hg fclone #{repository} #{SOURCE_ROOT} #{TO_LOG}"

  abort "FAIL" unless $? == 0
end

def checkout_tag(tag)
  puts "Checking out #{tag}..."
  system <<-EOF
cd #{SOURCE_ROOT}
hg fcheckout #{tag} #{TO_LOG}
  EOF

  abort "FAIL" unless $? == 0
end

def create_cacerts
  puts "Creating cacerts..."
  system <<-EOF
mkdir /tmp/cacerts-staging
cd /tmp/cacerts-staging
curl -s #{CACERTS_URI} | nawk '
/-----BEGIN CERTIFICATE-----/ { N++ ; P=1 }
{ if (P) { print > N ".pem" } }
/-----END CERTIFICATE-----/ { P=0 }
' -

for I in `ls` ; do
  keytool -importcert -noprompt -keystore #{CACERTS_FILE} -storepass changeit -file $I -alias $I
done
  EOF
end

def build(version, build_number)
  puts "Building #{name version}..."
  system <<-EOF
cd #{SOURCE_ROOT}
export LANG=C ALT_BOOTDIR=/usr/lib/jvm/java-6-openjdk ALT_CACERTS_FILE=#{CACERTS_FILE}
. jdk/make/jdk_generic_profile.sh
make MILESTONE=fcs JDK_VERSION=#{version} BUILD_NUMBER=#{build_number} ALLOW_DOWNLOADS=true #{TO_LOG}

tar czvf #{dist version} --exclude=*.debuginfo --exclude=*.diz -C build/linux-amd64/j2re-image . #{TO_LOG}
  EOF

  abort "FAIL" unless $? == 0
end

def upload(access_key, secret_access_key, bucket, version)
  puts "Uploading #{dist version} to s3://#{bucket}/#{key version}..."

  s3 = AWS::S3.new(
    :access_key_id => access_key,
    :secret_access_key => secret_access_key
  )

  objects = s3.buckets[bucket].objects
  objects.create key(version), Pathname.new(dist(version))

  index = objects[index()]
  if index.exists?
    versions = YAML::load(index.read)
  else
    versions = {}
  end

  versions[version] = uri bucket, version
  index.write(versions.to_yaml)
end

def base_path
  architecture = `uname -m`.strip
  codename = `lsb_release -cs`.strip
  "openjdk/#{codename}/#{architecture}"
end

def artifact(version)
  "#{name version}.tar.gz"
end

def dist(version)
  "/tmp/#{artifact version}"
end

def index
  "#{base_path}/index.yml"
end

def key(version)
  "#{base_path}/#{artifact version}"
end

def name(version)
  "openjdk-#{version}"
end

def uri(bucket, version)
  "http://#{bucket}.s3.amazonaws.com/#{key version}"
end

clone '@@REPOSITORY@@'
checkout_tag '@@TAG@@'
create_cacerts
build '@@VERSION@@', '@@BUILD_NUMBER@@'
upload '@@ACCESS_KEY@@', '@@SECRET_ACCESS_KEY@@', '@@BUCKET@@', '@@VERSION@@'

system `shutdown -h now`
