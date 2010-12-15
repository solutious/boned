# try try/10_basics_try.rb

require 'boned'
#Bone.debug = true
Bone.source = "http://localhost:3073"  
Bone.credentials = 'atoken:crystal'

## Bone.register_token
Bone.register_token Bone.token, Bone.secret
#=> 'atoken'

## Bone.register_token is not possible for existing key
Bone.register_token Bone.token, Bone.secret
#=> nil

## Bone.generate
@token = Bone.generate(Bone.secret) || ''
@token.size
#=> 40

## Can destroy a token
Bone.destroy_token @token
#=> true

## Cannot destroy a token that doesn't exist
Bone.destroy_token 'bogus'
#=> false

## Bone.get returns nil for bad key
Bone['bogus']
#=> nil

## Bone.keys returns empty array
Bone.keys
#=> []

## Bone.set 
Bone['akey1'] = 'value1'
Bone['akey2'] = 'value2'
Bone['akey2']
#=> 'value2'

## Bone.get
Bone['akey1']
#=> 'value1'

## Bone.keys
Bone.keys.sort
#=> ['akey1', 'akey2']


Bone.keys
Bone.destroy_token Bone.token
