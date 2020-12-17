/* Adam Fischer
 * ajfische
 * 11/29/16
 * greedy04.c
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "edgeVec.h"
#include "minPQ.h"
#include "LoadWgtGraph.h"
#define STDIN_NAME "-"

//Print graph
void printGraph(EdgeVec *adjInfo, int n) {

    for (int i = 1; i <= n; i++){
        printf("%d ", i);
        EdgeVec vec = adjInfo[i];

        if (edgeSize(vec) == 0){
            printf("[ ]\n");
        }
        else{
            printf("[");
            for (int x = edgeSize(vec); x >= 1; x--){
                printf("%d ",edgeData(vec, x-1).to);
                printf("(%f)",edgeData(vec, x-1).wgt);
                if(x-1 == 0){
                    printf("]\n");
                }
                else printf(", ");
            }
        }    
    }
    printf("\n\n");
}

void PrimMST(MinPQ pq, EdgeVec adjVInfo, int v, int status[], double priority[], int parent[]){
    EdgeVec remAdj;
    remAdj = adjVInfo;
    int x = edgeSize(remAdj)-1;
    while(x >= 0){
        int w = edgeData(remAdj, x).to;
        double newWgt = edgeData(remAdj, x).wgt;
        if(status[w] == UNSEEN){
            insertPQ(pq, w, newWgt, v);
        }
        else if(status[w] == FRINGE){
            if(newWgt < getPriority(pq, w)){
                decreaseKey(pq, w, newWgt, v);
            }
        }
        x--;
    }
}

void dijkstraSSSP(MinPQ pq, EdgeVec adjVInfo, int v, int status[], double priority[], int parent[]){
    EdgeVec remAdj;
    remAdj = adjVInfo;
    int x = edgeSize(remAdj)-1;
    double myDist = getPriority(pq, v);
    while(x >= 0){
        // wInfo = next vertex to visit
        EdgeInfo wInfo = edgeData(remAdj, x);
        int w = wInfo.to;
        //Add weights
        double newDist = myDist + wInfo.wgt;
        if(status[w] == UNSEEN){
            insertPQ(pq, w, newDist, v);
        } 
        else if(status[w] == FRINGE){
            if(newDist < getPriority(pq, w)){
                decreaseKey(pq, w, newDist, v);
            }
        }
        x--;
    }
}

void greedyTree(EdgeVec adjInfo[], int n, int s, int status[], double priority[], int parent[], char task){
    MinPQ pq = createPQ(n, status, priority, parent);
    //Look at first vertex
    insertPQ(pq, s, 0.0, -1);
    //while there are still vertices to look at
    while(isEmptyPQ(pq) != 0){
        int v = getMin(pq);
        delMin(pq);
        if(task == 'P'){
            PrimMST(pq, adjInfo[v], v, status, priority, parent);
        } 
        else { 
            dijkstraSSSP(pq, adjInfo[v], v, status, priority, parent);
        }
    }

    printf("Vertex | Status | Priority | Parent\n");
        for (int i = 1; i <= n; i++) {
             printf("%i        %c        %0.2f       %i\n",i, status[i], priority[i], parent[i]);
        }
}

int main(int argc, char* argv[]){

    char *file = argv[3];
    FILE * in = NULL;
    if (strcmp(file, STDIN_NAME) == 0) {
        in = stdin;
    }
    else {
        in = fopen(file, "r");
    }

    if (argc < 4){
        printf("Error, use format: greedy04 (-P or -D) startVec filename\n");
        exit(0);
    }

    if (argc > 5){
        printf("Too many arguments\n");
        exit(0);
    }

    //Get the amount of vertices
    char *line = calloc(1024, sizeof(char));
    fgets(line,1024,in);
    int n = parseN(line);

    //Get starting vertex
    int s = atoi(argv[2]);

    if(s < 1 || s > n){
        printf("Starting Vertex is not in the range of available vertices\n");
        exit(0);
    }

    //------------------Checks done--------------------

    //Create an array of empty edgeVecs. First index unused.
    EdgeVec *adjInfo = calloc((n+1), sizeof(EdgeVec));
    for (int i = 1; i <= n; i++) {
        adjInfo[i] = edgeMakeEmptyVec();
    }

    //Identify Prim's or Dikstra's
    char task = NULL;
    int directed = 0;
    char* type = argv[1];

    if (strcmp(type, "-P") == 0){
        printf("\nPrim's Algorithm starting at vertex: %i\n\n", s);
        task = 'P';
        directed = 0;
    }
    else if (strcmp(type, "-D") == 0){
        printf("\nDijkstra's Algorithm at vertex: %i\n\n", s);
        task = 'D';
        directed = 1;
    }
    else{
        printf("Did not select Prim's or Dijkstra's");
        exit(0);
    }

    //Construct 
    int m = loadWgtGraph(in, adjInfo, directed);
    printf("m = %d\n", m);
    printf("n = %d\n",  n);

    printf("Original Graph:\n\n");
    printGraph(adjInfo, n);

    int *status = calloc((n+1), sizeof(int));
    double *fringeWgt = calloc((n+1), sizeof(double));
    int *parent = calloc((n+1), sizeof(int));

    //Run Prim MST or dijkstra SSSP
    greedyTree(adjInfo, n, s, status, fringeWgt, parent, task);

}
