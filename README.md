## Boned - 0.3 ##

**Rudimentary Redis over HTTP(S) (the HTTP server companion for Bone)**

*NOTE: This version is not compatible with previous versions of Bone.*

## Running
    
    $ redis-server path/2/redis-server.conf
    
    $ BONED_SOURCE=redis://localhost:6379/   boned -e prod start
    
## Running as a daemon ##
    
    $ BONED_SOURCE=redis://localhost:6379/   boned -e prod -d start
    $ boned -e prod -d stop

## Updating bone configuration ##

You need to tell bone to use the HTTP API. In your .bashrc or equivalent, add:
    
    export BONE_SOURCE=http://127.0.0.1:3073/

## The Bonery ##

You can use the Bone daemon hosted at [The Bonery](http://bonery.com/). You'll need to [generate a token](https://api.bonery.com/signup/alpha) and set your BONE_SOURCE to ttps://api.bonery.com/.
    
## Installation

    $ sudo gem install boned

You also need to install [redis](http://code.google.com/p/redis/). 


## More Information

See [bone](https://github.com/solutious/bone). 


## Credits

* [Delano Mandelbaum](http://solutious.com)


## Thanks 

* Kalin Harvey for the early feedback. 


## License

See LICENSE.txt