#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <cuda_runtime.h>

#define N 1024

__global__ void vector_matrix(int *x, int *y, int *z, int n) {
	unsigned int col_idx = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned int row_idx = blockIdx.y * blockDim.y + threadIdx.y;
	unsigned int scan_idx;
	unsigned int ans = 0;
	for (scan_idx=0; scan_idx<n; scan_idx++) {
		ans += x[col_idx * n + scan_idx] * y[scan_idx * n + row_idx];
		__syncthreads();
	}
	z[col_idx * n + row_idx] = ans; 
}

int main(int argc, char *argv[])
{
	FILE *fpa,*fpb,*fpc,*fpx,*fpy,*fpz;
	unsigned int col_idx, row_idx;
	int* matrixA;
	int* matrixB;
	int* matrixC;
	int* matrixX;
	int* matrixY;
	int* matrixZ;
	int* matrixX_d;
	int* matrixY_d;
	int* matrixZ_d;
	int n;
        if(argc < 2) {
                n = N;
        } else {
                n = atoi(argv[1]);
        }

	matrixA = (int*)malloc(sizeof(int)*n*n);
	matrixB = (int*)malloc(sizeof(int)*n*n);
	matrixC = (int*)malloc(sizeof(int)*n*n);

        if(argc < 2) {
		for (col_idx=0; col_idx<n; col_idx++) {
			for (row_idx=0; row_idx<n; row_idx++) {
				/* matrixA[col_idx * n + row_idx] = rand() % (1024*1024); */
				/* matrixB[col_idx * n + row_idx] = rand() % (1024*1024); */
				matrixA[col_idx * n + row_idx] = 1;
				matrixB[col_idx * n + row_idx] = 1;
				matrixC[col_idx * n + row_idx] = 0;
			}
		}
        	fpa = fopen("./matrix_a.bin", "wr");
        	fpb = fopen("./matrix_b.bin", "wr");
        	fpc = fopen("./matrix_c.bin", "wr");
        	fwrite(matrixA, sizeof(int), n*n, fpa);
        	fwrite(matrixB, sizeof(int), n*n, fpb);
        	fwrite(matrixC, sizeof(int), n*n, fpc);
        	fclose(fpa);
        	fclose(fpb);
        	fclose(fpc);
	}

	matrixX = (int*)malloc(sizeof(int)*n*n);
	matrixY = (int*)malloc(sizeof(int)*n*n);
	matrixZ = (int*)malloc(sizeof(int)*n*n);
	cudaMalloc(&matrixX_d, sizeof(int)*n*n);
	cudaMalloc(&matrixY_d, sizeof(int)*n*n);
	cudaMalloc(&matrixZ_d, sizeof(int)*n*n);

        fpx = fopen("./matrix_a.bin", "r");
        fpy = fopen("./matrix_b.bin", "r");
        fpz = fopen("./matrix_c.bin", "wr");
        fread(matrixX, sizeof(int), n*n, fpx);
        fread(matrixY, sizeof(int), n*n, fpy);

	cudaMemcpy(matrixX_d, matrixX, sizeof(int)*n*n, cudaMemcpyHostToDevice);
	cudaMemcpy(matrixY_d, matrixY, sizeof(int)*n*n, cudaMemcpyHostToDevice);
	cudaMemcpy(matrixZ_d, matrixZ, sizeof(int)*n*n, cudaMemcpyHostToDevice);

        int blocksize = 16;
        int gridsize = n/blocksize;
        dim3 dimGrid(gridsize,gridsize);
        dim3 dimBlock(blocksize,blocksize);
        vector_matrix<<<dimGrid,dimBlock>>>(matrixX_d,matrixY_d,matrixZ_d,n);

	cudaMemcpy(matrixZ, matrixZ_d, sizeof(int)*n*n, cudaMemcpyDeviceToHost);
        fwrite(matrixZ, sizeof(int), n*n, fpz);
        fclose(fpx);
        fclose(fpy);
        fclose(fpz);

	free(matrixA);
	free(matrixB);
	free(matrixC);
	free(matrixX);
	free(matrixY);
	free(matrixZ);
	cudaFree(matrixX_d);
	cudaFree(matrixY_d);
	cudaFree(matrixZ_d);
}
