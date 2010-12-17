## Boned - 0.3 ##

**Remote environment variables**

*NOTE: This version is not compatible with previous versions of Bone.*

## Running
    
    $ redis-server path/2/redis-server.conf
    $ export BONED_SOURCE=redis://localhost:6379/
    
    $ boned -e prod start
    
## Running as a daemon ##
    
    $ boned -e prod -d start
    $ boned -e prod -d stop
    
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