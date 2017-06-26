#include <iostream>
#include <stdlib.h>
#define WIDTH 448
#define N WIDTH*WIDTH
#define totalhilos 64
#define TILE_WIDTH totalhilos
using namespace std;


__global__ void MatrixMulKernel(float* A, float* B, float* P)
{
        int Row = blockIdx.y*blockDim.y +threadIdx.y;
        int Col = blockIdx.x*blockDim.x +threadIdx.x;

        if((Row < WIDTH) && (Col < WIDTH)){
                float Pvalue = 0.0;

                for(int k=0;k<WIDTH;k++){
                        Pvalue+= A[Row*WIDTH+k] * B[k*WIDTH+Col];
                }
                P[Row*WIDTH+Col] = Pvalue;
        }
}

__global__ void MatrixMulTiledKernel(float* d_M, float* d_N, float* d_P) {
        __shared__ float Mds[TILE_WIDTH][TILE_WIDTH];
        __shared__ float Nds[TILE_WIDTH][TILE_WIDTH];

        int bx = blockIdx.x; int by = blockIdx.y;
        int tx = threadIdx.x; int ty = threadIdx.y;

        int Row = by * TILE_WIDTH + ty;
        int Col = bx * TILE_WIDTH + tx;

    float Pvalue = 0;

    for (int ph = 0; ph < WIDTH/TILE_WIDTH; ++ph) {
                Mds[ty][tx] = d_M[Row*WIDTH + ph*TILE_WIDTH + tx];
                Nds[ty][tx] = d_N[(ph*TILE_WIDTH + ty)*WIDTH + Col];
                __syncthreads();

                for (int k = 0; k < TILE_WIDTH; ++k) {
                        Pvalue += Mds[ty][k] * Nds[k][tx];
                }
                __syncthreads();
        }
        d_P[Row*WIDTH + Col] = Pvalue;
}


void llenarVector(float *V){
    for(int i=0;i<N;i++){
        V[i]=rand()%11;
    }
}

void imprimir(float *M){
        for(int i=0;i<WIDTH;i++){
                for(int j=0;j<WIDTH;j++){
                        cout<<M[i*WIDTH+j]<<" ";
                }
                cout<<endl;
        }
        cout<<endl;
}


int main(){
        cout<<"inicio"<<endl;
        float *d_A, *d_B, *d_C;
        float *dd_A, *dd_B, *dd_C;

        float h_A[N], h_B[N], h_C[N], hh_C[N];

         cudaEvent_t start;
        cudaEvent_t stop;

        cudaEvent_t start2;
        cudaEvent_t stop2;

        llenarVector(h_A);
        llenarVector(h_B);
        //llenarVector(h_C);

//      imprimir(h_A);
//      imprimir(h_B);

        cudaMalloc((void **)&d_A, N*sizeof(float));
        cudaMalloc((void **)&d_B, N*sizeof(float));
        cudaMalloc((void **)&d_C, N*sizeof(float));

        cudaMalloc((void **)&dd_A, N*sizeof(float));
        cudaMalloc((void **)&dd_B, N*sizeof(float));
         cudaMalloc((void **)&dd_C, N*sizeof(float));

        cudaMemcpy(d_A,h_A,N*sizeof(float),cudaMemcpyHostToDevice);
        cudaMemcpy(d_B,h_B,N*sizeof(float),cudaMemcpyHostToDevice);

        cudaMemcpy(dd_A,h_A,N*sizeof(float),cudaMemcpyHostToDevice);
        cudaMemcpy(dd_B,h_B,N*sizeof(float),cudaMemcpyHostToDevice);

        dim3 DimGrid(((WIDTH-1)/totalhilos)+1, ((WIDTH-1)/totalhilos)+1, 1);//ver
        dim3 DimBlock(totalhilos, totalhilos, 1);

        cudaEventCreate(&start);
        cudaEventCreate(&stop);

        cudaEventRecord(start,0);
        MatrixMulKernel<<<DimGrid,DimBlock>>>(d_A,d_B,d_C);
        cudaEventRecord(stop,0);
        cudaEventSynchronize(stop);
        float elapsedTime;

        cudaEventElapsedTime(&elapsedTime,start,stop);
        cout<<"Tiempo de ejecucion Multiplicacion Normal: "<<elapsedTime<<endl;
        cudaEventDestroy(start);
        cudaEventDestroy(stop);


        /*cudaEventCreate(&start2);
        cudaEventCreate(&stop2);
        cudaEventRecord(start2,0);
        MatrixMulTiledKernel<<<DimGrid,DimBlock>>>(dd_A,dd_B,dd_C);
        cudaEventRecord(stop2,0);
        cudaEventSynchronize(stop2);
        float elapsedTime2;
        cudaEventElapsedTime(&elapsedTime2,start2,stop2);
        cout<<"Tiempo de ejecucion Multiplicacion Tiled: "<<elapsedTime2<<endl;
        cudaEventDestroy(start2);
        cudaEventDestroy(stop2); */
           cudaMemcpy(h_C,d_C,N*sizeof(float),cudaMemcpyDeviceToHost);
        cudaMemcpy(hh_C,dd_C,N*sizeof(float),cudaMemcpyDeviceToHost);
        cout<<"Multiplicación tradicional"<<endl;
//      imprimir(h_C);

        cout<<endl;
        cout<<"Multiplicacion Tiled"<<endl;
//      imprimir(hh_C);


}
