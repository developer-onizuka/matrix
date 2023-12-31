```
$ time ./matrix.o 1024

real	0m9.438s
user	0m9.408s
sys 	0m0.012s

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
sys	 0m0.481s

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
<Quadro P1000>
$ time ./matrix.co 1024

real    0m0.218s
user    0m0.083s
sys     0m0.074s

<Quadro P620>
$ time ./matrix.co 1024

real    0m0.332s
user    0m0.116s
sys     0m0.154s

<Quadro P400>
$ time ./matrix.co 1024

real     0m0.424s
user     0m0.282s
sys      0m0.093s

<Quadro K1200>
$ time ./matrix.co 1024

real     0m0.232s
user     0m0.169s
sys      0m0.053s

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
sys	 0m0.156s

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
