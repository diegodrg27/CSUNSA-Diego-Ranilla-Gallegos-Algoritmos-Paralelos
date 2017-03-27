#include <stdio.h>
#define N 20
#define s 4

void multiplicacion3Loops(int C[N][N],int A[N][N],int B[N][N]);
void multiplicacion6Loops(int C[N][N],int A[N][N],int B[N][N]);
void llenarMatrix(int A[N][N], int opt);
void mostrarMatrix(int A[N][N]);


main(){

int A[N][N], B[N][N], C[N][N];

llenarMatrix(A,1);
llenarMatrix(B,1);
llenarMatrix(C,2);

//mostrarMatrix(A);
//mostrarMatrix(B);
//mostrarMatrix(C);

multiplicacion3Loops(C,A,B);

mostrarMatrix(C);
}


void llenarMatrix(int A[N][N], int opt){
	int i,j;
	if(opt==1){
		for(i=0; i<N;i++){
			for(j=0; j<N;j++){
				A[i][j]=3;
			}
		}
	}

	else{
		for(i=0; i<N;i++){
			for(j=0; j<N;j++){
				A[i][j]=0;
			}
		}
	}	
}

void mostrarMatrix(int A[N][N]){
	int i,j;
	for(i=0;i<N;i++){
		for(j=0;j<N;j++){
			printf("%d ",A[i][j]);
		}
		printf("\n");
	}
}

void multiplicacion3Loops(int C[N][N], int A[N][N], int B[N][N])
{
	int i,j,k;
	for (i=0; i < N; i++){
		for (j=0; j < N; j++){
			for (k=0; k < N; k++){
				C[i][j] += A[i][k]*B[k][j];
			}
		}
	}
}

void multiplicacion6Loops(int C[N][N],int A[N][N],int B[N][N]){
	int i1,j1,k1,i,j,k;
		for (i1=0; i1<N; i1+=s){
			for (j1=0; j1<N; j1+=s){
				for (k1=0; k1<N; k1+=s){
					for (i=i1; i<i1+s&&i<N; i++){
						for (j=j1; j<j1+s&&j<N; j++){
							for (k=k1; k<k1+s&&k<N; k++){
								C[i][j] += A[i][k]*B[k][j];
							}
						}
					}
				}	
			}
		}
}

