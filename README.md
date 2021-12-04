# open_computers_programs

This repo is a storage spot for my various open computers programs. A short
summary of what is what is below. 

mine.lua - a good mid-tier mining program. This is a single robot mining 
           program that moves in a straight line gathering materials. It
           uses a scaffolding system for movement (thus no hover required)
           and an ender-chest for item transport. Moderate additional 
           infrestructure is required to maintain the chest. 
           I would consider this to be moderatly reliable. Robots should
           bring in well more than their cost before ultimatly getting
           stuck. 
## Ideas
- **Continous Mining:** Mine in a straight line off into the sunset
- **Skip Drive Missiles:** Very small jump drive ships equiped with just a warp drive and nuke. Move to a destination, dissasemble the warp drive (ship back if possible), and drop the nuke. Could be good for handling laggy spots.
- **Remote Control Turtle:** A turtle that can be wirelessly controlled, great for many things I assume, but in particular as the actuators of a mining platform. This would let most of the key code live on the platform with the robots as disposable / replacable units. The ability to auto-aquire on the base station side would be a particularly critical piece, as would the ability to automatically manufacture robots with the correct eeprom. 
- **Automatic Shipyard:** A platform that manufactures simple ships (perhaps skip missiles, or mining skiffs) layer by layer using a robot. 
- **Jump Ship Stargate Hub:** A stargate controller that can record and update the addresses of remote gates. Ships (or just new bases) could then dial in periodically to update the hub with their address. Optionally info could flow both ways to keep the entire network up to date. A redstone controller would allow the computer to handle update requests and provide a standardized way to handle iris passwords. 
