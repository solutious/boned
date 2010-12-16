# try try/10_basics_try.rb

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
@token = Bone.generate(Bone.secret) || ''
@token.size
#=> 40

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
