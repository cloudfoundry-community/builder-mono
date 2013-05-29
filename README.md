# OpenJDK Builder
[![Dependency Status](https://gemnasium.com/cloudfoundry/builder-openjdk.png)](https://gemnasium.com/cloudfoundry/builder-openjdk)

This project is a set of scripts that automate the creation of OpenJDK builds using EC2.

## Usage
To run the builder do the following:

```bash
bundle install
bundle exec ./build-openjdk.rb [OPTIONS]
```

The options are as follows and, unless otherwise specified, required:

| Switch | Description
| ------ | -----------
| `-a`, `--access_key` | AWS access key to use
| `-b`, `--bucket` | AWS S3 bucket name to upload the distribution to
| `-k`, `--key_name` | The name of the EC2 keypair to use when creating the instance.  This is optional and defaults to `Cloud Foundry`
| `-n`, `--build_number` | The build number of the JDK to create
| `-s`, `--secret_access_key` | AWS secret access key to use
| `-t`, `--tag` | The repository tag to build from
| `-v`, `--version` | The version of the JDK to create

### Credentials
Pivotal employees should contact Ben Hale for AWS credentials if they have not already been issued.

## Build Details
These are the details used for the currently existing builds.  This list _should_ be kept up to date, but may not be.  Check before doing anything dangerous.

| JDK Version | Build Number | Tag
| ----------- | ------------ | ---
| `1.6.0_21` | `b21` | `jdk6-b21`
| `1.6.0_22` | `b22` | `jdk6-b22`
| `1.6.0_23` | `b23` | `jdk6-b23`
| `1.6.0_24` | `b24` | `jdk6-b24`
| `1.6.0_25` | `b25` | `jdk6-b25`
| `1.6.0_26` | `b26` | `jdk6-b26`
| `1.6.0_27` | `b27` | `jdk6-b27`
| `1.7.0_01` | `b08` | `jdk7u1-b08`
| `1.7.0_02` | `b21` | `jdk7u2-b21`
| `1.7.0_03` | `b04` | `jdk7u3-b04`
| `1.7.0_04` | `b31` | `jdk7u4-b31`
| `1.7.0_05` | `b30` | `jdk7u5-b30`
| `1.7.0_06` | `b31` | `jdk7u6-b31`
| `1.7.0_07` | `b31` | `jdk7u7-b31`
| `1.7.0_08` | `b05` | `jdk7u8-b05`
| `1.7.0_09` | `b32` | `jdk7u9-b32`
| `1.7.0_10` | `b31` | `jdk7u10-b31`
| `1.7.0_11` | `b33` | `jdk7u11-b33`
| `1.7.0_12` | `b09` | `jdk7u12-b09`
| `1.7.0_13` | `b30` | `jdk7u13-b30`
| `1.7.0_14` | `b22` | `jdk7u14-b22`
| `1.7.0_15` | `b33` | `jdk7u15-b33`
| `1.7.0_17` | `b31` | `jdk7u17-b31`
| `1.7.0_21` | `b30` | `jdk7u21-b30`
| `1.7.0_25` | `b11` | `jdk7u25-b11`
| `1.8.0_M6` | `b75` | `jdk8-b75`
| `1.8.0_M7` | `b91` | `jdk8-b91`
