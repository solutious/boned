require 'boned'
#Bone.debug = true
Bone.source = "http://localhost:3073"  
Bone.credentials = "#{__FILE__}:crystal"

## Bone.register
Bone.register Bone.token, Bone.secret
#=> 'atoken'



Bone.destroy_token Bone.token