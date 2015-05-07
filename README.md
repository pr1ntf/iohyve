# iocage
FreeBSD bhyve manager utilizing ZFS.

So far FreeBSD guests work with relativly no hassle. Linux guests can be a bit more tricky, but with a little help you can make them persist. 

I'm in the middle of writing some man pages for this.

Just read the man page built in for now. 

Or the readme. I know, I know, this is also a reamdme. 

But read that one.



    iohyve  
        version
        setup [pool]
        list
        isolist
        vmmlist
        running
        fetch [URL]
        remove [ISO]
        create [name] [size] [console]
        install [name] [ISO]
        load [name]
        boot [name] [ISO]
        start [name]
        stop [name]
        off [name]
        scram
        destroy [name]
        delete [name]
        set [name] [prop=value]
        get [name] [prop]
        getall [name]
        conlist
        console [name]
        readme
        help
        man 

