## Run Map Matching with FMM

Install map matching program with C++ and Python following these [instructions](https://fmm-wiki.github.io/docs/installation/).
-Note: We found the Ubuntu software to be successful in running the fmm program

The map network of Provo, Utah using OSMNX.py is compatible with FMM [input](https://fmm-wiki.github.io/docs/documentation/input/)

# Running the FMM program

Due to the large map network it is recommended to use STMATCH function
GPS Points will need to be a GDAL trajectory file, a CSV trajectory file or CSV point file.
In this example we use GDAL trajectory file

'stmatch --network ./data/edges.shp --gps ./gps_linestring.shp -k 10 -r 40 -e 1 --output mr.txt --source u --target v --gps_id ID --network_idd osmid --reverse_tolerance 1'
