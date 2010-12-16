require 'boned'
#Bone.debug = true
Bone.source = "http://localhost:3073"  
Bone.credentials = "11_signature:crystal"

## Bone.register
Bone.register Bone.token, Bone.secret
#=> '11_signature'


Bone.destroy Bone.token