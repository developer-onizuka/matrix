#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <fcntl.h>
#include <unistd.h>

#include "cufile.h"

#define N 1024

__global__ void hello(int *x) {
		unsigned int col_idx = blockIdx.x * blockDim.x + threadIdx.x;
		printf("x:%d\n", x[col_idx]); 
}

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
	/* printf("z:%d\n", z[0]); */
}

int main(int argc, char *argv[])
{
	FILE *fpa,*fpb,*fpc;
	int fpx,fpy,fpz,fpzz;
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
        CUfileDescr_t cf_desc_x;
        CUfileDescr_t cf_desc_y;
        CUfileDescr_t cf_desc_z;
        CUfileHandle_t cf_handle_x;
        CUfileHandle_t cf_handle_y;
        CUfileHandle_t cf_handle_z;
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
        	fpa = fopen("./matrix_a.bin", "w");
        	fpb = fopen("./matrix_b.bin", "w");
        	fpc = fopen("./matrix_c.bin", "w");
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

	cuFileDriverOpen();
        fpx = open("./matrix_a.bin", O_RDONLY | O_DIRECT);
        fpy = open("./matrix_b.bin", O_RDONLY | O_DIRECT);
        fpz = open("./matrix_c.bin", O_RDWR | O_DIRECT);
        fpzz = open("./matrix_cc.bin", O_RDWR | O_CREAT, 0777);
        cf_desc_x.handle.fd = fpx;
        cf_desc_y.handle.fd = fpy;
        cf_desc_z.handle.fd = fpz;
        cf_desc_x.type = CU_FILE_HANDLE_TYPE_OPAQUE_FD;
        cf_desc_y.type = CU_FILE_HANDLE_TYPE_OPAQUE_FD;
        cf_desc_z.type = CU_FILE_HANDLE_TYPE_OPAQUE_FD;
        cuFileHandleRegister(&cf_handle_x, &cf_desc_x);
        cuFileHandleRegister(&cf_handle_y, &cf_desc_y);
        cuFileHandleRegister(&cf_handle_z, &cf_desc_z);
        cuFileBufRegister((int*)matrixX_d, sizeof(int)*n*n, 0);
        cuFileBufRegister((int*)matrixY_d, sizeof(int)*n*n, 0);
        cuFileBufRegister((int*)matrixZ_d, sizeof(int)*n*n, 0);

        cuFileRead(cf_handle_x, (int*)matrixX_d, sizeof(int)*n*n, 0, 0);
        cuFileRead(cf_handle_y, (int*)matrixY_d, sizeof(int)*n*n, 0, 0);
        cuFileRead(cf_handle_z, (int*)matrixZ_d, sizeof(int)*n*n, 0, 0);

        int blocksize = 16;
        int gridsize = n/blocksize;
        dim3 dimGrid(gridsize,gridsize);
        dim3 dimBlock(blocksize,blocksize);
        vector_matrix<<<dimGrid,dimBlock>>>(matrixX_d,matrixY_d,matrixZ_d,n);
	/* hello<<<2,4>>>(matrixX_d); */

	for(int i=0;i<n*n/512;i++) {
		cuFileWrite(cf_handle_z, matrixZ_d, sizeof(int)*512, sizeof(int)*512*i, 0);
	}
	/*
        cudaMemcpy(matrixZ, matrixZ_d, sizeof(int)*n*n, cudaMemcpyDeviceToHost); 
	printf("z:%d\n", matrixZ[0]);
	int ret=0;
	ret=pwrite(fpzz, matrixZ, sizeof(int)*n*n, 0); 
	printf("ret:%d\n",ret);
	*/

        cuFileBufDeregister((int*)matrixX_d);
        cuFileBufDeregister((int*)matrixY_d);
        cuFileBufDeregister((int*)matrixZ_d);

        close(fpx);
        close(fpy);
        close(fpz);

	cuFileDriverClose();

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
