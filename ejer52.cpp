#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>
#include <time.h>

double num_aleatorio(){
  double aleatorio = -1 + (1 - (-1)) * random() / ((double) RAND_MAX);
  return aleatorio;
}

int main(int argc, char* argv[]) {
   long int numeroIntentos, numeroEnCirculo;//numero de intentos intentos en el circulo
   int thread_count, i;// Cantidad de hilos iterador
   double x, y, distancia;//coordenadas del intentos y la distancia de esas coordenadas connrespecto al centro

   thread_count = strtol(argv[1], NULL, 10);// recoge la cantidad de hilos
   numeroIntentos = strtoll(argv[2], NULL, 10);// numero de intentos
   numeroEnCirculo = 0;//sumador

   srandom(0);
#  pragma omp parallel for num_threads(thread_count) reduction(+: numeroEnCirculo) private(x, y, distancia)
   for (i = 0; i < numeroIntentos; i++){
      x = num_aleatorio();
      y = num_aleatorio();
      distancia = pow(x,2) + pow(y,2);

      if (distancia <= 1) {
         numeroEnCirculo += 1;
      }
   }
   double pi = 4*numeroEnCirculo/((double) numeroIntentos);
   printf("valor de pi = %.14f\n", pi);
   return 0;
} 