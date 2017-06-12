#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>
#include <time.h>
#define N 20
#define min 0
#define max 5
#define Bcount 20


void crearDatos(float min_meas, float max_meas , float *data , int data_count);
void crearBin(float min_meas, float max_meas, float *bin_maxes, int *bin_counts,int bin_count);
void imprimirVector(float *v, int n);
void imprimirHistograma(int *v, int n);
int buscarBin(float dato,float *bin_maxes,int bin_count);

int nThread;

int main(int argc, char* argv[]){
	nThread = strtol(argv[1], NULL, 10);

	///////////////////////////////////////
	float * data = (float*)malloc(N*sizeof(float));
	crearDatos(min,max,data,N);

	imprimirVector(data,N);
	float *Bmaxes =  (float*)malloc(Bcount*sizeof(float));
	int *Bcounts = (int*)malloc(Bcount*sizeof(int));

	crearBin(min,max,Bmaxes,Bcounts,Bcount);

	imprimirVector(Bmaxes,Bcount);
	imprimirHistograma(Bcounts,Bcount);
	int bin,i;

#pragma omp parallel for num_threads(nThread) shared(N,data,Bmaxes,Bcount,Bcounts) private(bin,i)
{
	for (i = 0; i < N; ++i)
	{
		bin = buscarBin(data[i],Bmaxes,Bcount);	
		#pragma omp critical
			Bcounts[bin]++;
	}
}
	imprimirHistograma(Bcounts,Bcount);
}

void crearBin(float min_meas, float max_meas, float * bin_maxes, int * bin_counts,int bin_count){
	float bin_width;
	int i;

	bin_width = (max_meas - min_meas)/bin_count;
	#pragma omp parallel for num_threads(nThread) shared(min_meas,max_meas,bin_maxes,bin_counts,bin_count,bin_width)
	{
		for (i = 0; i < bin_count; i++){
	      bin_maxes[i] = min_meas + (i+1)*bin_width;
	      bin_counts[i] = 0;
	   	}
	}
}

void crearDatos(float min_meas, float max_meas , float *data , int data_count){
	int i;
	srandom(0);
	//int thread;

	#pragma omp parallel for shared(data,min_meas,max_meas,data_count)
	{
		//thread = omp_get_thread_num();
		for(i = 0; i < data_count; i++){
	         data[i] = min_meas + (max_meas - min_meas) * random() / ((double) RAND_MAX);
	 //        printf("hilo: %d iterador: %d\n",thread ,i);
	    }
	}
}

int buscarBin(float dato,float *bin_maxes,int bin_count){
	for(int i = 0; i<bin_count; i++){
		if(dato <= bin_maxes[i]) return i;
	}
}

void imprimirVector(float *v, int n){
	int j;
	for (j=0; j<n;j++){
		printf("%f ", v[j]);
	}
	printf("\n \n");
}

void imprimirHistograma(int *v, int n){
	int j;
	for (j=0; j<n;j++){
		printf("%d ", v[j]);
	}
	printf("\n \n");
}

