#!/usr/bin/env ruby

require 'rubygems'
require 'aws-sdk'
require 'yaml'

STDOUT.sync = true

SOURCE_ROOT = '/tmp/mono'
`echo "mono compile build output goes here..." > /tmp/build-output.txt`
TO_LOG = '>> /tmp/build-output.txt 2>&1'

def clone(repository)

  puts "Cloning #{repository} to #{SOURCE_ROOT}..."
  system "git clone #{repository} #{SOURCE_ROOT} #{TO_LOG}"

  abort "FAIL" unless $? == 0
end

def checkout_tag(tag)
  puts "Checking out #{tag}..."
  system <<-EOF
cd #{SOURCE_ROOT}
git checkout #{tag} #{TO_LOG}
git submodule init #{TO_LOG}
git submodule update --recursive #{TO_LOG}
  EOF

  abort "FAIL" unless $? == 0
end

def build(version)
  puts "Building #{name version}..."
  system <<-EOF
cd #{SOURCE_ROOT}

MONO_PREFIX=/app/runtimes/mono
export DYLD_LIBRARY_FALLBACK_PATH=$MONO_PREFIX/lib:$DYLD_LIBRARY_FALLBACK_PATH
export LD_LIBRARY_PATH=$MONO_PREFIX/lib:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=$MONO_PREFIX/include
export ACLOCAL_PATH=$MONO_PREFIX/share/aclocal
export PKG_CONFIG_PATH=$MONO_PREFIX/lib/pkgconfig:
export PATH=$MONO_PREFIX/bin:$PATH

sudo mkdir -p $MONO_PREFIX

./autogen.sh --prefix=$MONO_PREFIX #{TO_LOG}
./configure --prefix=$MONO_PREFIX --with-profile4=yes --with-profile4_5=no --with-moonlight=no --disable-boehm --enable-minimal=aot --disable-libraries --with-mcs-docs=no #{TO_LOG}
make get-monolite-latest #{TO_LOG}
make EXTERNAL_MCS="${PWD}/mcs/class/lib/monolite/gmcs.exe" #{TO_LOG}
make install #{TO_LOG}

tar --transform='s,^app/runtimes/,,' -czvf #{dist version} /app/runtimes/mono/ #{TO_LOG}
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
  "mono/#{codename}/#{architecture}"
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
  "mono-#{version}"
end

def uri(bucket, version)
  "http://#{bucket}.s3.amazonaws.com/#{key version}"
end

clone '@@REPOSITORY@@'
checkout_tag '@@TAG@@'
build '@@VERSION@@'
upload '@@ACCESS_KEY@@', '@@SECRET_ACCESS_KEY@@', '@@BUCKET@@', '@@VERSION@@'

system `shutdown -h now`
