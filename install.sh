#!/bin/bash

bundle install --path vendor/bundle
bundle exec pod install --repo-update
open *space;
exit 0
