#include <iostream>
#include <stdlib.h>
#include <math.h>
#include <time.h> 
#include <stdio.h>
#define ROW 15 //filas Matriz 1
#define COL 15 // columna Matriz 2

#define N ROW*COL // Cantidad de elementos en Matriz 3

#define THREADS 5
using namespace std;

void createMatrixHost(float**& host, int row, int col, int size){
    host = (float **)malloc(row*sizeof(float*));
    host[0]=(float *)malloc(size);
	
    for (int i=1; i<row;++i){
        host[i]=host[i-1]+col;
    }

}

void createMatrixHostCUDA(float**& host, float**& device, float **& aux, int row, int col, int size){
    host = (float **)malloc(row*sizeof(float*));
    host[0]=(float *)malloc(size);
    aux =(float **)malloc(row*sizeof(float*));

    cudaMalloc((void **)&aux[0],size);
    cudaMalloc((void **)&device,row*sizeof(float*));

    for (int i=1; i<row;++i){
        host[i]=host[i-1]+col;
        aux[i]=aux[i-1]+col;
    }
    cudaMemcpy(device, aux, row*sizeof(float*), cudaMemcpyHostToDevice);
}

void Multiplicacion(float** A, float** B, float** P){
        for(int i=0;i<ROW;i++){
                for(int j=0;j<COL;j++){
                        float Sum=0.0;
                        for(int k=0;k<COL;k++){
                                Sum += A[i][k]*B[k][j];
                        }
                        P[i][j] = Sum;
                }
        }
}

__global__ void MatrixMulKernel2(float** A, float** B, float** P)
{
        __shared__ float A_b[THREADS][THREADS];
        __shared__ float B_b[THREADS][THREADS];
        __shared__ float B_b2[THREADS][THREADS];

        __shared__ float R_b[THREADS][THREADS];
	__shared__ float R_b2[THREADS][THREADS];

        int Row = blockIdx.y * THREADS + threadIdx.y;
        int Col = blockIdx.x * THREADS * 2 + threadIdx.x;

	R_b[threadIdx.y][threadIdx.x] = 0.0;
	R_b2[threadIdx.y][threadIdx.x] = 0.0;
        __syncthreads(); 

	for(int i = 0;i < ceil(COL/(float)THREADS);i++){
		A_b[threadIdx.y][threadIdx.x] = 0.0;
		B_b[threadIdx.y][threadIdx.x] = 0.0;
		B_b2[threadIdx.y][threadIdx.x] = 0.0;
		__syncthreads();

		if ((Row<ROW) && (i*THREADS + threadIdx.x<COL)){
	                A_b[threadIdx.y][threadIdx.x] = A[Row] [i*THREADS + threadIdx.x];
			
		}

		if ((i*THREADS + threadIdx.y<COL) && (Col<COL)){
	                B_b[threadIdx.y][threadIdx.x] = B[i*THREADS + threadIdx.y][Col]; 
		}

		if ((i*THREADS + threadIdx.y<COL) && (Col+THREADS<COL)){
			B_b2[threadIdx.y][threadIdx.x] = B[i*THREADS + threadIdx.y][Col+THREADS]; 
		}

                __syncthreads();

                for (int k = 0; k < THREADS; k++) {
                        R_b[threadIdx.y][threadIdx.x] += A_b[threadIdx.y][k] * B_b[k][threadIdx.x];
			R_b2[threadIdx.y][threadIdx.x] += A_b[threadIdx.y][k] * B_b2[k][threadIdx.x];
                }
                __syncthreads();
	 }

	 if((Row<ROW) && (Col<COL)){
	         P[Row][Col] = R_b[threadIdx.y][threadIdx.x];
	}

	 if((Row<ROW) && (Col+THREADS<COL)){
  		 P[Row][Col+THREADS] = R_b2[threadIdx.y][threadIdx.x];
	}
}

void llenarVector(float **V, int row, int col){
    for(int i=0;i<row;i++){
	for(int j=0;j<col;j++){
	        V[i][j]=rand()%11;
	}
    }
}

void imprimir(float **M, int row, int col){
        for(int i=0;i<row;i++){
                for(int j=0;j<col;j++){
                        cout<<M[i][j]<<" ";
                }
                cout<<endl;
        }
        cout<<endl;
}


int main(){
	float **a, **b, **c3,**c2;
	//////////////////////////////////////////
	float **d_a, **d_b, **d_c3;
	float **a_aux, **b_aux, **c_aux3;
	///////////////////////////////////////////

	int size = N * sizeof(float*);
	
	dim3 DimGrid(ceil((((COL-1)/(float)THREADS)+1)/2), ((ROW-1)/THREADS)+1, 1);
      	dim3 DimBlock(THREADS, THREADS, 1);
	createMatrixHostCUDA(a,d_a,a_aux,ROW,COL,size);
	createMatrixHostCUDA(b,d_b,b_aux,ROW,COL,size);
	
	createMatrixHostCUDA(c3,d_c3,c_aux3,ROW,COL,size);

	createMatrixHost(c2,ROW,COL,size);
	
    	llenarVector(a,ROW,COL);
	llenarVector(b,ROW,COL);

	imprimir(a,ROW,COL);
	imprimir(b,ROW,COL);

	Multiplicacion(a,b,c2);
	imprimir(c2,ROW,COL);

	cudaMemcpy(a_aux[0], a[0], size, cudaMemcpyHostToDevice);
	cudaMemcpy(b_aux[0], b[0], size, cudaMemcpyHostToDevice);
	MatrixMulKernel2<<<DimGrid,DimBlock>>>(d_a,d_b,d_c3);
	
	cudaMemcpy(c3[0],c_aux3[0], size, cudaMemcpyDeviceToHost);
	imprimir(c3,ROW,COL);
}
