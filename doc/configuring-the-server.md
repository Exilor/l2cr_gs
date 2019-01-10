# Configuration files
l2cr uses the same ```.properties``` files that L2J uses. These should be in a folder called ```config``` in the folder of the executable.
There are settings that are not used by l2cr because they involve Java-specific things.

# Common settings
Among the most relevant settings are:

- ```Server.properties```
  - ```LoginHost``` The IP at which the game server will try to connect to the login server
  - ```LoginPort``` The port at which the game server will try to connect to the login server
  - ```GameserverHostname``` The IP which players will connect to
  - ```GameserverPort``` The port which players will connect to
  - ```URL``` The URL that will be used to connect to the database
  - ```DatapackRoot``` The path to the datapack
  
- ```General.properties```
  - ```EverybodyHasAdminRights``` if set to True all players will be GMs
- ```Geodata.properties```
  - ```Pathfinding``` Enabling it will make characters fnd a route through obstacles. Only 0 (disabled) and 2 (using geodata) are implemented.
  - ```GeoDataPath``` The path to the geodata files
  -```TryLoadUnspecifiedRegions``` This setting is what makes the server try to load an enable the geodata


Settings are used in the server code through the ```Config``` module as class methods.
