#!/bin/sh

echo 'Initialising bitcoin wallet "default"'
bitcoin-cli createwallet default
bitcoin-cli loadwallet default
bitcoin-cli generatetoaddress 1 $(bitcoin-cli getnewaddress)
