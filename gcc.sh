gcc matrix.c -o matrix.o -lm
gcc -O3 matrix_omp.c -o matrix_omp.o -lm -fopenmp 
nvcc matrix.cu -o matrix.co -lm
nvcc -I /usr/local/cuda/include/  -I /usr/local/cuda/targets/x86_64-linux/lib/ matrix_gds.cu -o matrix_gds.co -L /usr/local/cuda/targets/x86_64-linux/lib/ -lcufile -L /usr/local/cuda/lib64/ -lcuda -L   -Bstatic -L /usr/local/cuda/lib64/ -lcudart_static -lrt -lpthread -ldl -lcrypto -lssl

