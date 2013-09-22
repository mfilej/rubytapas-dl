[![Code Climate](https://codeclimate.com/github/mfilej/rubytapas-dl.png)](https://codeclimate.com/github/mfilej/rubytapas-dl)
[![Build Status](https://travis-ci.org/mfilej/rubytapas-dl.png?branch=master)](https://travis-ci.org/mfilej/rubytapas-dl)

# rubytapas-dl

## Usage

Download RubyTapas episodes from the CLI.

    Usage: ./download_rubytapas.rb -u USERNAME -p PASSWORD [-r] <TARGET>
        -u, --username USERNAME          RubyTapas username (required)
        -p, --password PASSWORD          RubyTapas password (required)
        -r, --recent-only                Only download recent episodes
        -h, --help                       Show usage

Download all RubyTapas episodes:

    ./download_rubytapas.rb -u TAPAS_USER -p TAPAS_PASS ~/RubyTapas

Only download new episodes (stops when an older episode is found at target location):

    ./download_rubytapas.rb -u TAPAS_USER -p TAPAS_PASS -r ~/RubyTapas


## Coming up

* further extracting of logic from `download_rubytapas.rb`
* installation options
* man page
