# Datapack

The datapack is a collection of xml, html, json and java files that L2J compiles to be used in conjunction with the game server. 
l2cr needs all of these files (except the java ones) which are parsed when the server loads.

By default, the datapack should be in a folder called ```data``` placed in the folder the executable is located at:
```
  /game_server/
    /game_server
    /bin/
    /src/
    /data/
      /buylists/
      /html/
      /multisell/
      [...]
    [...]
```

The path to the datapack can be configured in the ```Server.properties``` file.
