# chef_server_wrapper

## Overview
Use this cookbook to install, configure and start a stand alone chef server

## Usage
Include this cookbook's default recipe in your run list.


## Attributes
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|channel|The name of the channel to use for the installation|symbol|:stable|no|
|version|The version of chef server to install|string|12.19.31|no|
|accept_license|Accept the chef server EULA|boolean|true|no|
|data_collector_url|The url of an automate server|string|nil|no|
|data_collector_token|The token to use when sending dta to the data collector url|string|nil|no|
