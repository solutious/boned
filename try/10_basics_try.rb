# try try/10_basics_try.rb

# An instance of boned must be running:
# ruby -rubygems bin/boned -e dev -d start

require 'boned'
#Bone.debug = true
Bone.source = "http://localhost:3073"  
Bone.credentials = 'atoken:crystal'

## Bone.register
Bone.register Bone.token, Bone.secret
#=> 'atoken'

## Bone.register is not possible for existing key
Bone.register Bone.token, Bone.secret
#=> nil

## Bone.generate
@token, @secret = *Bone.generate
@token.size
#=> 24

## Can destroy a token
Bone.destroy @token
#=> true

## Cannot destroy a token that doesn't exist
Bone.destroy 'bogus'
#=> false

## Bone.get returns nil for bad key
Bone['bogus']
#=> nil

## Bone.keys returns empty array
Bone.keys
#=> []

Bone.destroy Bone.token
