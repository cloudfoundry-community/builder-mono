# Mono Builder

This project is a set of scripts that automate the creation of Mono builds for Cloud Foundry using EC2.

## Usage
To run the builder do the following:

```bash
bundle install
bundle exec ./build-mono.rb --version=3.0.12 --tag=mono-3.0.12 --access_key=$AWS_ACCESS_KEY --secret_access_key=$AWS_SECRET_KEY --bucket=ci-labs-buildpack-downloads --key_name=labs-commander
```

The options are as follows and, unless otherwise specified, required:

| Switch | Description
| ------ | -----------
| `-a`, `--access_key` | AWS access key to use
| `-s`, `--secret_access_key` | AWS secret access key to use
| `-b`, `--bucket` | AWS S3 bucket name to upload the distribution to
| `-k`, `--key_name` | The name of the EC2 keypair to use when creating the instance.  This is optional and defaults to `Cloud Foundry`
| `-v`, `--version` | The version of the Mono to create

## Build Details
These are the details used for the currently existing builds.  This list _should_ be kept up to date, but may not be.  Check before doing anything dangerous.

|repo tag                                                                                 | Mono Version | Tag          | Profile(s)            | Size(gz)
|-----------------------------------------------------------------------------------------| ------------ | -------------| ----------------------| ---------------------
|[3.0.10-full](https://github.com/cloudfoundry-community/builder-mono/tree/3.0.10-full)   | `3.0.10`     | `mono-3.0.10`| net2,net35,net4,net45 | 100 MB
|[3.0.12-full](https://github.com/cloudfoundry-community/builder-mono/tree/3.0.12-full)   | `3.0.12`     | `mono-3.0.12`| net2,net35,net4,net45 | 60 MB
|[3.1.2-full](https://github.com/cloudfoundry-community/builder-mono/tree/3.1.2-full)     | `3.1.2`      | `mono-3.1.2` | net2,net35,net4,net45 | 60 MB
|[3.1.2-net4](https://github.com/cloudfoundry-community/builder-mono/tree/3.1.2-net4)     | `3.1.2`      | `mono-3.1.2` | net2,net35,net4       | 33 MB
