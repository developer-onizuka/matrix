```
$ time ./matrix.o 1024

real	0m19.293s
user	0m19.277s
sys	0m0.013s

$ od -i matrix_a.bin
0000000           1           1           1           1
*
20000000

$ od -i matrix_b.bin
0000000           1           1           1           1
*
20000000

$ od -i matrix_c.bin
0000000        1024        1024        1024        1024
*
20000000
```

```
$ time ./matrix_omp.o 1024

real	0m2.700s
user	0m10.163s
sys	0m0.481s

$ od -i matrix_a.bin 
0000000           1           1           1           1
*
20000000

$ od -i matrix_b.bin 
0000000           1           1           1           1
*
20000000

$ od -i matrix_c.bin 
0000000        1024        1024        1024        1024
*
20000000
```

```
$ time ./matrix.co 1024

real	0m0.424s
user	0m0.282s
sys	0m0.093s

$ od -i matrix_a.bin
0000000           1           1           1           1
*
20000000

$ od -i matrix_b.bin
0000000           1           1           1           1
*
20000000

$ od -i matrix_c.bin
0000000        1024        1024        1024        1024
*
20000000
```

```
$ time ./matrix_gds.co 1024

real	0m1.827s
user	0m0.320s
sys	0m0.156s

$ od -i matrix_a.bin
0000000           1           1           1           1
*
20000000

$ od -i matrix_b.bin
0000000           1           1           1           1
*
20000000

$ od -i matrix_c.bin
0000000        1024        1024        1024        1024
*
20000000
```
