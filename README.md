# Mono Builder

This project is a set of scripts that automate the creation of Mono builds for Cloud Foundry using EC2.

## Existing Mono builds

See https://ci-labs-buildpack-downloads.s3.amazonaws.com/mono/lucid/x86_64/index.yml

## Usage
To run the builder do the following:

```bash
bundle install
bundle exec ./build-mono.rb --version=3.2.3_full --tag=mono-3.2.3 --access_key=$AWS_ACCESS_KEY --secret_access_key=$AWS_SECRET_KEY --bucket=ci-labs-buildpack-downloads --key_name=labs-commander
```

:exclamation: Make sure that the files uploaded to S3 are public!

The options are as follows and, unless otherwise specified, required:

| Switch | Description
| ------ | -----------
| `-a`, `--access_key` | AWS access key to use
| `-s`, `--secret_access_key` | AWS secret access key to use
| `-b`, `--bucket` | AWS S3 bucket name to upload the distribution to
| `-k`, `--key_name` | The name of the EC2 keypair to use when creating the instance.  This is optional and defaults to `Cloud Foundry`
| `-t`, `--tag` | the `github.com/mono/mono` tag to build
| `-v`, `--version` | The version number we label the build with.  NB: must not contain -

## Build Details
These are the details used for the currently existing builds.  This list _should_ be kept up to date, but may not be.  Check before doing anything dangerous.

|repo tag                                                                                 | Mono Version | Tag          | Profile(s)            | Size(gz)
|-----------------------------------------------------------------------------------------| ------------ | -------------| ----------------------| ---------------------
|[3.1.2_net4](https://github.com/cloudfoundry-community/builder-mono/tree/3.1.2_net4)     | `3.1.2`      | `mono-3.1.2` | net2,net35,net4       | 33 MB
|[3.2.0_net4](https://github.com/cloudfoundry-community/builder-mono/tree/3.2.0_net4)     | `3.2.0`      | `mono-3.2.0` | net2,net35,net4       | 33 MB
|[3.2.0_full](https://github.com/cloudfoundry-community/builder-mono/tree/3.2.0_full)     | `3.2.0`      | `mono-3.2.0` | net2,net35,net4,net45 | 60 MB
|[3.2.3_full](https://github.com/cloudfoundry-community/builder-mono/tree/3.2.3_full)     | `3.2.2`      | `mono-3.2.3` | net2,net35,net4,net45 | 60 MB
