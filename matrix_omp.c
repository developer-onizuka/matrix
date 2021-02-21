#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

#define N 1024
#define NUM_THREADS 4

void vector_matrix(int *x, int *y, int *z, int n) {
	for (unsigned int col_idx=0; col_idx<n; col_idx++) { 
		for (unsigned int row_idx=0; row_idx<n; row_idx++) {
			int ans[NUM_THREADS] = {0};
			omp_set_num_threads(NUM_THREADS);
			#pragma omp parallel
			{	unsigned int scan_idx;
				int id;
				id = omp_get_thread_num();
				/* printf("id:%d\n",id); */
			#pragma omp for
				for (scan_idx=0; scan_idx<n; scan_idx++) {
					ans[id] += x[col_idx * n + scan_idx] * y[scan_idx * n + row_idx];
				}
			}
			for(int i=0; i<NUM_THREADS; i++) { 
				z[col_idx * n + row_idx] += ans[i];
			}
		}
	}
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

        fpx = fopen("./matrix_a.bin", "r");
        fpy = fopen("./matrix_b.bin", "r");
        fpz = fopen("./matrix_c.bin", "w+");
        fread(matrixX, sizeof(int), n*n, fpx);
        fread(matrixY, sizeof(int), n*n, fpy);

	vector_matrix(matrixX, matrixY, matrixZ, n);

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
}
