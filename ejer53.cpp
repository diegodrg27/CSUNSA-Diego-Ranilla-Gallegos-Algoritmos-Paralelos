#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>
#include <time.h>
#include <string.h>

void crearVector(int *V, int N){
	 srand(time(NULL));
	for(int i=0;i<N;i++){
		V[i] = rand()%20;
	}
}

void imprimirVector(int *v, int n){
	int j;
	for (j=0; j<n;j++){
		printf("%d ", v[j]);
	}
	printf("\n \n");
}


int main(int argc, char* argv[]){
   int thread_count, i, j, n, count;
   srandom(0);

   thread_count = strtol(argv[1], NULL, 10);//cantidad de hilos
   n = strtol(argv[2], NULL, 10);//tamaño del vector

   int * a = (int*)malloc(n* sizeof(int));//crea el vector
   crearVector(a, n);

   int * temp = (int *)malloc(n* sizeof(int));//crea temporal

	double start = omp_get_wtime();//toma tiempo
	#pragma omp parallel for num_threads(thread_count) private(i, j, count) shared(a, n, temp, thread_count)
	
		for(i = 0; i < n; i++){
         count = 0;
         for (j = 0; j < n; j++){
            if (a[j] < a[i])
               count++;
            else if (a[j] == a[i] && j < i)
               count++;
          }
         temp[count] = a[i];
      	}
	
   memcpy(a , temp, n * sizeof(int));
   double finish = omp_get_wtime( );
   free(temp);
   imprimirVector(a,n);
   printf("Tempo estimado %e segundos\n", finish - start);
   //imprimeMatriz(a, n);
   return 0;
}