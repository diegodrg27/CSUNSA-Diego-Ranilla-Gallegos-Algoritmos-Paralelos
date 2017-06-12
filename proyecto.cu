#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <math.h>
#include <vector>

#include <time.h>

#define ancho 1280
#define alto 720
#define totalPixeles ancho*alto

#define totalhilos 32

typedef int tamPixel;

using namespace std;

void llenarVectores(tamPixel *V){

        for(int i=0;i<totalPixeles;i++){
                srand(time(NULL));
                V[i]=rand()%256;
        }
}

__global__ void convertirRGBtoYCoCg(tamPixel *RY,tamPixel *GCg, tamPixel *BCo, int height, int width){
	int Row = blockIdx.y*blockDim.y + threadIdx.y;
	int Col = blockIdx.x*blockDim.x + threadIdx.x;
	int index = Row*width+Col;
	
	if ((Row < height) && (Col < width)) {
		RY[index] = ((1/4)*RY[index]) + ((1/2)*GCg[index]) + ((1/4)*BCo[index]);
		GCg[index] = ((-1/4)*RY[index]) + ((1/2)*GCg[index]) + ((-1/4)*BCo[index]);
		BCo[index] = ((1/2)*RY[index]) + ((-1/2)*BCo[index]);
	}
}

__global__ void suma(tamPixel *RY,tamPixel *GCg, tamPixel *BCo, int height, int width){
	int Row = blockIdx.y*blockDim.y + threadIdx.y;
	int Col = blockIdx.x*blockDim.x + threadIdx.x;
	int index = Row*width+Col;
	
	if ((Row < height) && (Col < width)) {
		BCo[index] = RY[index]+GCg[index];
	}
}

int main(){

		tamPixel *R,*G,*B;
		tamPixel *RY, *GCg, *BCo;

		int size = totalPixeles * sizeof(tamPixel);

		R = (tamPixel *)malloc(size);
		G = (tamPixel *)malloc(size); 
		B = (tamPixel *)malloc(size);		

        llenarVectores(R);
        llenarVectores(G);
        llenarVectores(B);

        cudaMalloc((void **)&RY, size);
		cudaMalloc((void **)&GCg, size);
		cudaMalloc((void **)&BCo, size);

        cudaMemcpy(RY,R,size,cudaMemcpyHostToDevice);
		cudaMemcpy(GCg,G,size,cudaMemcpyHostToDevice);
		cudaMemcpy(BCo,B,size,cudaMemcpyHostToDevice);

		dim3 DimGrid(((ancho-1)/totalhilos)+1, ((alto-1)/totalhilos)+1, 1);//ver
		dim3 DimBlock(totalhilos, totalhilos, 1);

		convertirRGBtoYCoCg<<<DimGrid,DimBlock>>>(RY,GCg,BCo, alto, ancho);

        cout<<"todo bn"<<endl;

}
