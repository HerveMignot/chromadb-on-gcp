#!/bin/bash

# Generate a random 32 characters alphanumeric token and output it
token=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
echo $token
