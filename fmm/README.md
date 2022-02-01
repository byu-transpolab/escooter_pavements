# Run Map Matching with FMM

Install map matching program with C++ and Python following these [instructions](https://fmm-wiki.github.io/docs/installation/).

-Note: We found the Ubuntu software to be successful in running the FMM program.

The map network of Provo, Utah using [OSMnx.py](../OSMNX/OSMNX.py) is compatible with FMM [input](https://fmm-wiki.github.io/docs/documentation/input/).

### Running the FMM program

Due to the large map network it is recommended to use STMATCH function because it does not need to be precomputed.\
GPS Points will need to be a GDAL trajectory file, a CSV trajectory file or CSV point file.\
If both the network and the gps data are projected in meters, a search radius (r) of `300` corresponds to 300 meters in reality.\
In this example we use a GDAL trajectory file:

`stmatch --network ./example_data/edges.shp --gps ./example_data/gps_linestring.shp -k 10 -r 40 -e 1 --output mr.txt --source u --target v --gps_id ID --network_idd osmid --reverse_tolerance 1`
