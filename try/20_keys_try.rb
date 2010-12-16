require 'boned'
#Bone.debug = true
Bone.source = "http://localhost:3073"  
Bone.credentials = '20_keys_try:crystal'

## Bone.register
Bone.register Bone.token, Bone.secret
##=> '20_keys_try'

## Bone.set 
Bone['akey1'] = 'value1'
Bone['akey1']
#=> 'value1'

## Bone.set 
Bone['akey2'] = 'value2'
Bone['akey2']
##=> 'value2'

## Bone.get
Bone['akey1']
##=> 'value1'

## Bone.keys
Bone.keys.sort
##=> ['akey1', 'akey2']

## Bone.destroy
Bone.destroy Bone.token
## 
