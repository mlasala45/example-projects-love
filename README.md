# example-projects-love
A few old projects made for the LÖVE2D framework.

These will require an installation of the [LÖVE2D](https://love2d.org/) framework to run, located at `C://LOVE`.

There are various batch files in each project, which were used as a simple build toolkit.
In general, `compile.bat` packs the code (using 7-Zip) into a `*.love` file, and `run.bat` runs the file.

The batch files may not all be consistent with the expected path of Love2D and 7-Zip; the process is easy to glean from the scripts, so fixes should be easy if there is an issue.

All of these programs can be closed by pressing the Escape key.

#### Civilization
A incomplete game made in the style of Civilization 5.

Left Click - Select Units.
Right Click - Move. Hold to show path.
Shift + Left Click - Show Tile Information

#### MSE-TTS Network Interface
A tool for presenting MSE card set exports to a Tabletop Simulator importer script, using a local server.

MSE is a program for designing custom Magic: The Gathering cards. This tool uses a slightly modified version of an importer script, which collects data for a MTG deck and spawns objects to represent it into Tabletop Simulator. The script exclusively downloads information from a remote source, so this tool reformats the exports from MSE and presents them on a local server that the importer can access.

See INSTRUCTIONS.txt for operating instructions.]

#### Hacking
A simple UI proof-of-concept for a hacking game. Mousing over a node plays an animation, and displays an IP address.

#### Coastline Gen v2 - Voronoi
One of a series of experiments with procedural generation. A Voronoi graph is generated, and cells are marked as inside or outside of the island using a hardcoded formula.

R - Reset the simulation.
Space - Pause and unpause.
G - Toggle Grayscale/Color
W - Toggle Single Shade