rm bin/main

odin build src -out:bin/main -use-separate-modules -show-timings -o:minimal -linker:lld

./bin/main
