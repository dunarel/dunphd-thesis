
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <string.h>
#include <vector>

using namespace std;

struct TNoeud{	
    int NoNoeud;
	char *seq;
	TNoeud * gauche;
	TNoeud * droit;
	int nbFils;
};


 //==Prototypes des fonctions
 void SAVEASNewick(double *LONGUEUR, long int *ARETE,int nn,const char* t); 
 char ChangeDNA(char);
 int floor1(double x);
 void tree_generation(double **DA, double **DI, int n, double Sigma);
 void odp(double**,int*,int*,int*);
 void odp1(double**,int*,int*,int*,int);
 void Tree_edges(double **,long int *,double *); 
 void TrierMatrices(double **DISS,char **NomsDISS,char **NomsADD,int n);
 void afficherMatriceDouble(double **MAT , int taille);
 TNoeud * CreerSousArbre(long int * ARETE, int *indice,double ** Adjacence,int sommet);
 void AfficherArbre(TNoeud *,int);
 double P(double l);
 int findRoot(long int *ARETE,int encore);
 void NombreNoeud(TNoeud *arbre);
 void FindNode(TNoeud *arbre, TNoeud **arb, int node);
 void GenererListeTaxons(TNoeud * arbre, TNoeud ** TabNoeud);
 void GenererMatrice(TNoeud **TabNoeud, double **DISS);
 void SimulerTransfert ();
 void afficherMatriceDouble(double **MAT,int n,FILE *in);
 int Bipartition_Table(double **, int **,int*,int* flag);
 int Table_Comparaison(int**,int**,int*,int*,int,int);
 void NJ(double **D1,double **DA);
 double CalculerDistance (char MODEL,TNoeud * noeud1,TNoeud * noeud2);
 void viderArbre(TNoeud * arbre);
 void LectureMatrices(double ***DISS,double ***ADD,const char *fichier);
 void Floyd(double ** Adjacence , double ** DIST,int n);
 void UpdateGeneMatrix(double **DISS, int R1, int R2, int R3, int R4, double longueur);
 void Floyd(double ** Adjacence , double ** DIST,int n);
 void SelectTransfer(long int *ARETE3, TNoeud *arbre1, TNoeud *arbre2);
 int findAreteSource(TNoeud *tete, long int *ARETE,int ** FORBIDEN_BRANCH,int maxFeuilles);
 int findAreteDest(TNoeud *tete, long int *ARETE,int ** FORBIDEN_BRANCH,int maxFeuilles);
 //int findAreteDest(TNoeud *tete, int source, long int *ARETE, double ** DIST,int *TabTrans, int nElt,int ** FORBIDEN_BRANCH);
 void UpdateARETE(long int *ARETE, double *LONGUEUR, TNoeud *tete);
 TNoeud * FindPred(TNoeud *tete, int R);
 void AfficherSequences(TNoeud *arbre,FILE *OUT);
 void AfficherSousMatrice(const char *,TNoeud *a2,double **DIST);
void createTree(int nbSpecies);

 #define INFINI 999999.99
 #define ECRAN "ECRAN"
 #define FICHIER "FICHIER"
 #define MaxRF 0
 double MaxLong=0;
 double MinLong = INFINI;
 double seuil;
 double epsilon = 0.00005;
 int n;
 
 void presenterProgramme(){
	//printf("\nHGT-simulator by Alix Boc - June 2008");
 }


//=============================================================
//=========================== MAIN ============================
//=============================================================
int main(int nargs,char ** argv){

	int nbSpecies;
	
	if(nargs != 2){
		printf("\nbad input..\nusage:%s nbTaxons\n",argv[0]);
		exit(1);
	}
	
	nbSpecies = atoi(argv[1]);
	createTree(nbSpecies);
	
	return 0;
}


void ParcoursSousArbre(TNoeud *a, int *tab,int *pos){
	
	if(a->droit == NULL){
		tab[*pos] = a->NoNoeud;
		(*pos)++;
	}
	else{
		ParcoursSousArbre(a->droit,tab,pos);
		ParcoursSousArbre(a->gauche,tab,pos);
	}
}

int nbFeuille(TNoeud *a){
	
	if(a->droit == NULL)
		return 1;
	else
		return nbFeuille(a->droit) + nbFeuille(a->gauche);
}

void AfficherSousMatrice(const char *sortie,TNoeud *a,double **DIST){
	
	FILE *out;
	int n=nbFeuille(a);
	int *tab = (int*)malloc((n+1)*sizeof(int));
	int pos=0;
	
	if(strcmp(sortie,ECRAN)==0)
		out = stdout;
	else
		out = fopen("simMatrice.txt","a+");
	
	ParcoursSousArbre(a,tab,&pos);
	
	fprintf(out,"\n%d ",n);
	for(int i=0;i<n;i++){
		fprintf(out,"%d ",tab[i]);
	}
	fprintf(out,"\n");

	for(int i=0;i<n;i++){
		for(int j=0;j<n;j++)
			fprintf(out,"%lf ",DIST[tab[i]][tab[j]]);
		fprintf(out,"\n");
	}

	free(tab);
	fclose(out);
}
 
 void ListerFeuilles(TNoeud *noeud,vector<int> *listeFeuilles){
	 if(noeud->droit == NULL)
		 listeFeuilles->push_back(noeud->NoNoeud);
	 else{
		ListerFeuilles(noeud->droit,listeFeuilles);
		ListerFeuilles(noeud->gauche,listeFeuilles);
	 }
 }
 
  void TrierTableau(int tableau[],int taille){
 	int i, inversion,tmp;	
 	do
 	{	
 		inversion=0;	
 		for(i=1;i<taille;i++)		
 		{		
 			if (tableau[i]>tableau[i+1])	
 			{	
 				tmp = tableau[i];				
 				tableau[i] = tableau[i+1];	
 				tableau[i+1] = tmp;
 				inversion=1;
 			}
 		}
 	}
	while(inversion);	
 }
 

 void SauvegarderLesFeuilles(TNoeud *a1, TNoeud *a2, TNoeud *a3, TNoeud *a4,FILE *IN,int * listFeuilles){
 
	 vector<int> tableau1;
	 vector<int> tableau2;
	 int min,pos=1,*T1,*T2;
	 
	 //free(listFeuilles);
	 
	 
	 if((a1->droit == a2)||(a1->gauche == a2))
		 ListerFeuilles(a2,&tableau1);
	 else
		ListerFeuilles(a1,&tableau1);

	 if((a3->droit == a4)||(a3->gauche == a4))
		 ListerFeuilles(a4,&tableau2);
	 else
		ListerFeuilles(a3,&tableau2);
 	 
 	 T1 = (int*) malloc((tableau1.size()+1)*(sizeof(int)));
	 T2 = (int*) malloc((tableau2.size()+1)*(sizeof(int)));
	
	 for(int i=0;i<tableau1.size();i++)
		 T1[i+1] = tableau1[i];
	for(int i=0;i<tableau2.size();i++)
		 T2[i+1] = tableau2[i];
		 
	TrierTableau(T1,tableau1.size());
	TrierTableau(T2,tableau2.size());
	
	
	listFeuilles[0] = tableau1.size()+tableau2.size();
	
//	 fprintf(IN,"\n%d",tableau1.size());
	 fprintf(IN,"\n");
	 for(int i=1;i<=tableau1.size();i++){
		fprintf(IN," %d",T1[i]);
		listFeuilles[pos++] = T1[i];
	 }

//	 fprintf(IN,"\n%d",tableau2.size());
	 fprintf(IN,"\n");
	 for(int i=1;i<=tableau2.size();i++){
		fprintf(IN," %d",T2[i]);
		listFeuilles[pos++] = T2[i];
	 }
 }


 void AreteFromTree(TNoeud * arbre,double ** Adjacence,double l){
	
	 if(arbre != NULL){
		 if(arbre->NoNoeud > n){
			 Adjacence[arbre->NoNoeud][arbre->droit->NoNoeud] = Adjacence[arbre->droit->NoNoeud][arbre->NoNoeud] = l;
			 Adjacence[arbre->NoNoeud][arbre->gauche->NoNoeud] = Adjacence[arbre->gauche->NoNoeud][arbre->NoNoeud] = l;
			 AreteFromTree(arbre->droit,Adjacence,l);
			 AreteFromTree(arbre->gauche,Adjacence,l);
		 }	 
	 }
 }

void parcoursNewick(FILE *newick, FILE*racine,TNoeud * arbre,int pred){

    if(arbre->gauche == NULL){
        //printf("%d",arbre->NoNoeud); 
        fprintf(newick,"%d:25.0",arbre->NoNoeud);
		fprintf(racine,"%d ",arbre->NoNoeud);
        if(pred == 1) {
            //printf(", "); 
            fprintf(newick,",");
        }     
    }
    else{ 
        //printf("("); 
        fprintf(newick,"(");
        parcoursNewick(newick,racine,arbre->gauche,1);
        parcoursNewick(newick,racine,arbre->droit,2);
        //printf(")"); 
        fprintf(newick,"):25.0");
        if(pred == 1){ 
        //  printf(", "); 
            fprintf(newick,",");
        }     
    }
}
void parcoursNewick2(TNoeud * arbre,int pred){

    if(arbre->gauche == NULL){
        //printf("%d",arbre->NoNoeud); 
        printf("%d:25.0",arbre->NoNoeud);
        if(pred == 1) {
            //printf(", "); 
            printf(",");
        }     
    }
    else{ 
        //printf("("); 
        printf("(");
        parcoursNewick2(arbre->gauche,1);
        parcoursNewick2(arbre->droit,2);
        //printf(")"); 
        printf("):25.0");
        if(pred == 1){ 
        //  printf(", "); 
            printf(",");
        }     
    }
}

void SauvegarderEnNewick(FILE *newick,FILE *racine, TNoeud *arbre1, TNoeud *arbre2){
    
    char BS = 8;
    //printf("("); 
    fprintf(newick,"(");
    parcoursNewick(newick,racine,arbre1,1);
	fprintf(racine,"\n<>\n");	
    fseek(newick,-1,SEEK_CUR); 
    fprintf(newick,",");//fprintf(newick,"ROOT");
    parcoursNewick(newick,racine,arbre2,1); 
    //printf("%c%c",BS,BS); 
    fseek(newick,-1,SEEK_CUR); 
    //printf(")"); 
    fprintf(newick,");\n");
}
void printEnNewick(TNoeud *arbre1, TNoeud *arbre2){
    
    char BS = 8;
    //printf("("); 
    printf("(");
    parcoursNewick2(arbre1,1); 
    //printf("%c",BS); 
    printf(",");//fprintf(newick,"ROOT");
    parcoursNewick2(arbre2,1); 
    //printf("%c",BS); 
    //printf(")"); 
    printf(");\n");
}
//=============================================
//
//=============================================
void createTree (int nbSpecies){	 
	 int i,j;
	 double *LONGUEUR,Sigma;				    //= Longueurs des aretes
	 long int *ARETE , *ARETE1, *ARETE2;		//= Liste des aretes de l'arbre
	 double **DA,**DI;							//= Distance d'arbre
	 time_t t;
	 double ** Adjacence, ** Adjacence2;
	 FILE *input,*racine;
	 
	 n = nbSpecies;
	// Allocation dynamique pour les matrices
	DI = (double **) malloc((n+1)*sizeof(double*));
	DA=(double **) malloc((2*n-1)*sizeof(double*));

	for (i=0;i<=n;i++){
		DI[i]=(double*)malloc((n+1)*sizeof(double));
		 
		if (DI[i]==NULL)
		{
			printf(" Data matrix is too large(2)\n"); 
			exit(1);
		}
	}

	 Adjacence=(double **) malloc((2*n-1)*sizeof(double*));
	 Adjacence2=(double **) malloc((2*n-1)*sizeof(double*));
	 for(i=0;i<=2*n-2;i++){
		 DA[i]=(double*)malloc((2*n-1)*sizeof(double));
		 Adjacence2[i]=(double*) malloc((2*n-1)*sizeof(double));
		 Adjacence[i]=(double*) malloc((2*n-1)*sizeof(double));
	 }	 

	 ARETE=(long int *) malloc((4*n)*sizeof(long int));
	 ARETE1=(long int *) malloc((4*n)*sizeof(long int));
	 ARETE2=(long int *) malloc((4*n)*sizeof(long int));

	 LONGUEUR=(double *) malloc((2*n)*sizeof(double));

	 //char *string = (char*) malloc((100*n) * sizeof(char));
  
	 TNoeud * arbre1, *arbre2 ,*a1,*a2,*a3, *a4, *tete, *tmp, *pred;
	 int racine1,racine2,indice=1,choix,encore;

	//===== CA COMMENCE ICI =====
	srand((unsigned) time(&t));
	seuil = ((double) (rand() % 100)) / 100.00;
	
	//==================================
	//= CREATION D'UN ARBRE ALEATOIRE
	//==================================
	tree_generation(DA, DI, n, Sigma = 0.0);
	Tree_edges(DA, ARETE, LONGUEUR);

	//SAVEASNewick(LONGUEUR,ARETE,n,"input.txt"); 
	
	MaxLong = 0;
	MinLong = INFINI;

	for(int j=1;j<=2*n-3;j++){
		if(MaxLong < LONGUEUR[j-1])	MaxLong = LONGUEUR[j-1];
		if(MinLong > LONGUEUR[j-1]) MinLong = LONGUEUR[j-1];
		//LONGUEUR[j-1] *=2 ;
	} 

	//printf("\nMaxLong = %lf , MinLong = %lf",MaxLong,MinLong);
	for(i=0;i<=2*n-2;i++)
		for(int j=0;j<=2*n-2;j++){
			Adjacence[i][j] = Adjacence[j][i] = INFINI;
			Adjacence2[i][j] = Adjacence2[j][i] = INFINI;
		}			

	 for(i=1;i<=2*n-3;i++){
		Adjacence2[ARETE[2*i-1]][ARETE[2*i-2]] = Adjacence2[ARETE[2*i-2]][ARETE[2*i-1]] = LONGUEUR[i-1];
	 }
	 encore=0;
	 
	 //===============================================
	 //= RECHERCHE DE LA RACINE QUI EQUILIBRE L'ARBRE
	 //===============================================
	 do{		 
		for(i=0;i<=2*n-2;i++)
			for(int j=0;j<=2*n-2;j++)
				Adjacence[i][j] = Adjacence2[i][j];

		choix = findRoot(ARETE,encore);
		encore = choix;
		racine1 = ARETE[2*choix-1];
		racine2 = ARETE[2*choix-2];
		 
		Adjacence[racine1][racine2] = Adjacence[racine2][racine1] = INFINI;
		 
		//== creation de deux sous arbres par rapport � chaque racine.
		indice=1;
		arbre1 = CreerSousArbre(ARETE1,&indice,Adjacence,racine1);
		indice=1;
		arbre2 = CreerSousArbre(ARETE2,&indice,Adjacence,racine2);
		
		//== comptabiliser le nombre de noeuds dans chaque arbre.
		NombreNoeud(arbre1);
		NombreNoeud(arbre2);
		
	}while((arbre1->nbFils < (n/3.0)) || (arbre2->nbFils < (n/3.0)));
	
	//=============================================================================
	//= ECRITURE DE LA STRUCTURE DE L'ARBRE D'ESPECES et generation des sequences
	//=============================================================================
	if((input = fopen("species_rooted.new","w+"))==NULL){
			 printf("\nimpossible de creer le fichier : tree.new");
			 exit(-1);
	 }
	if((racine = fopen("racine.txt","w+"))==NULL){
			 printf("\nimpossible de creer le fichier : racine.txt");
			 exit(-1);
	 }
	SauvegarderEnNewick(input,racine,arbre1,arbre2);
	SAVEASNewick(LONGUEUR,ARETE,n,"species_unrooted.new"); 
	//printEnNewick(arbre1,arbre2); 
	fclose(input);	
	fclose(racine);
}



//================================
//
//================================
TNoeud * FindPred(TNoeud *tete, int R){

	TNoeud * tmp = NULL;

	if(tete != NULL){
		if(tete->droit != NULL){
			if( (tete->droit->NoNoeud == R)||(tete->gauche->NoNoeud == R) )
				tmp = tete;
			else{
			tmp = FindPred(tete->droit,R);
			if(tmp == NULL)
				tmp = FindPred(tete->gauche,R);
			}
		}
	}
	return tmp;
}

//=====================================================================
//
//=====================================================================
int findAreteSource(TNoeud *tete,long int *ARETE,int ** FORBIDEN_BRANCH,int maxFeuilles){
	int val;
	int R1,R2;
	bool pasTrouve=true;
	time_t t;
	int cpt=0;
	TNoeud * node;
    
	val = (rand() % (2*n-3)) + 1;

	do{
		cpt++;
		if(cpt > (2*n-3) ) return -1;
		R1 = ARETE[2*val-1];
		R2 = ARETE[2*val-2];
		
		node=NULL;
		FindNode(tete,&node,R1);
		
		if(node==NULL || FORBIDEN_BRANCH[R1][R2]==0 || node->nbFils > maxFeuilles ||(ARETE[2*val-1] == tete->NoNoeud || ARETE[2*val-2] == tete->NoNoeud )){
  			val = ((val+1) % (2*n-3)) + 1;
  		}else{
        pasTrouve = false;
      }
  
	}while(pasTrouve);
	
	return val;
}


//================================
//
//================================ 
int findAreteDest(TNoeud *tete,long int *ARETE,int ** FORBIDEN_BRANCH,int maxFeuilles){
	int val;
	int R1,R2;
	bool pasTrouve=true;
	time_t t;
	int cpt=0;
	TNoeud * node;
    
	val = (rand() % (2*n-3)) + 1;

	do{
		cpt++;
		if(cpt > (2*n-3) ) return -1;
		R1 = ARETE[2*val-1];
		R2 = ARETE[2*val-2];
		
		node=NULL;
		FindNode(tete,&node,R1);
		
		if(node==NULL ||(ARETE[2*val-1] == tete->NoNoeud || ARETE[2*val-2] == tete->NoNoeud )){
  			val = ((val+1) % (2*n-3)) + 1;
  		}else{
        pasTrouve = false;
      }
  
	}while(pasTrouve);

	return val;
}

//================================
//
//================================
double Minimum(double A, double B){
	if(A<B)
		return A;
	else
		return B;
}

//===================================================
//
//===================================================
void viderArbre(TNoeud * arbre){

	if(arbre != NULL){
		viderArbre(arbre->droit);
		viderArbre(arbre->gauche);
		free(arbre->seq);
//		free(arbre->NoNoeud);
		free(arbre);
	}
}



//===================================================
//
//===================================================
void FindNode(TNoeud *arbre,TNoeud ** arb, int node){

	if(arbre->NoNoeud == node)
		*arb = arbre;
	else
		if(arbre->droit != NULL){
			FindNode(arbre->droit,arb,node);
			FindNode(arbre->gauche,arb,node);
		}
}

//===================================================
//
//===================================================
void NombreNoeud(TNoeud *arbre){
	if(arbre->droit == NULL && arbre->gauche == NULL)
		arbre->nbFils = 1;
	else{
		NombreNoeud(arbre->droit);
		NombreNoeud(arbre->gauche);
		arbre->nbFils = arbre->droit->nbFils + arbre->gauche->nbFils;
	}
}

//===================================================
//
//===================================================
int findRoot(long int *ARETE,int encore){
	bool rootfound = false;
	int val;

	if(encore != 0){
		while(!rootfound){
			val = ((encore++) % (2*n-3)) + 1;
			//printf("\nval = %d , encore = %d",val,encore);
			if((ARETE[2*val-1]>n) && (ARETE[2*val-2]>n))
				rootfound = true;
		}
	}
	else
		while(!rootfound){
			val = rand() % (2*n-3) + 1;
			if((ARETE[2*val-1]>n) && (ARETE[2*val-2]>n))
				rootfound = true;
		}
	return val;
}

//=================================
//
//=================================
double P(double l){
	return 0.25*(1.0+3.0*exp(-4.0*1*l)); 
}

//======================================
//
//======================================
void AfficherArbre(TNoeud * unNoeud,int prof){

	if(unNoeud != NULL){
		AfficherArbre(unNoeud->droit,prof+1);
		printf("\n");
		for(int i=0;i<prof;i++) printf("  ");
		printf("%d",unNoeud->NoNoeud);//,unNoeud->seq);
		AfficherArbre(unNoeud->gauche,prof+1);
	}
}

//========================================
//
//========================================
int findFils(double ** Adjacence,int sommet){

	for(int i=0;i<=2*n-2;i++){
		if(Adjacence[sommet][i]<INFINI){
			Adjacence[sommet][i] = Adjacence[i][sommet] = INFINI;
			return i;
		}
	}
	return -1;
}

//======================================================
//
//======================================================
TNoeud * CreerSousArbre(long int *ARETE,int *indice, double ** Adjacence,int sommet){
	
	int i=0;
	int filsGauche;
	int filsDroit;

	if(sommet==-1)
		return NULL;

	TNoeud * node = (TNoeud*)malloc(sizeof(TNoeud));
	node->NoNoeud = sommet;
	//node->seq = (char*) malloc((SeqBases+1)*(sizeof(char)));
	//strcpy(node->seq,"");
	//node->seq[SeqBases] = '\0';

	filsGauche = findFils(Adjacence,sommet);
	filsDroit  = findFils(Adjacence,sommet);

	if(filsGauche != -1) {
		ARETE[2*(*indice)-2] = sommet;
		ARETE[2*(*indice)-1] = filsGauche;
		(*indice) = (*indice) + 1;
		ARETE[2*(*indice)-2] = sommet;
		ARETE[2*(*indice)-1] = filsDroit;
		(*indice) = (*indice) + 1;
	}
	node->gauche = CreerSousArbre(ARETE,indice,Adjacence,filsGauche);
	node->droit  = CreerSousArbre(ARETE,indice,Adjacence,filsDroit);
	return node;
}


// This C++ function is meant to generate a random tree distance matrix DA
// of size (nxn) and a distance (i.e. dissimilarity) matrix DI obtained
// from DA by adding a random normally distributed noise with mean 0 
// and standard deviation Sigma. For more detail, see Makarenkov and
// Legendre (2004), Journal of Computational Biology.  
void tree_generation(double **DA, double **DI, int n, double Sigma)
{
   struct TABLEAU { int V; } **NUM, **A;
   int i,j,k,p,a,a1,a2,*L,*L1,n1;
   double *LON,X0,X,U;
   //time_t t;
   
   n1=n*(n-1)/2;
    
   L=(int *)malloc((2*n-2)*sizeof(int));
   L1=(int *)malloc((2*n-2)*sizeof(int));
   LON=(double *)malloc((2*n-2)*sizeof(double));
    
   NUM=(TABLEAU **)malloc((2*n-2)*sizeof(TABLEAU*));
   A=(TABLEAU **)malloc((n1+1)*sizeof(TABLEAU*));
    
   for (i=0;i<=n1;i++)
   {
      A[i]=(TABLEAU*)malloc((2*n-2)*sizeof(TABLEAU));
      if (i<=2*n-3) NUM[i]=(TABLEAU*)malloc((n+1)*sizeof(TABLEAU));
      
      if ((A[i]==NULL)||((i<=2*n-3)&&(NUM[i]==NULL))) 
      {
       printf("\nData matrix is too large\n");
       exit(1);
      }
    }  

/* Generation of a random additive tree topology T*/

   for (j=1;j<=2*n-3;j++)
   {
    for (i=1;i<=n;i++)
     {
       A[i][j].V=0;
       NUM[j][i].V=0;
     }
    for (i=n+1;i<=n1;i++)
      A[i][j].V=0;
   }
   A[1][1].V=1; L[1]=1; L1[1]=2; NUM[1][1].V=1; NUM[1][2].V=0;
     
//   srand((unsigned) time(&t));

   for (k=2;k<=n-1;k++)
   {
    p=(rand() % (2*k-3))+1;
    for (i=1;i<=(n*(k-2)-(k-1)*(k-2)/2+1);i++)
     A[i][2*k-2].V=A[i][p].V;
    for (i=1;i<=k;i++)
    {
     a=n*(i-1)-i*(i-1)/2+k+1-i;
     if (NUM[p][i].V==0)
      A[a][2*k-2].V=1;
     else
      A[a][p].V=1;
    }
    for (i=1;i<=k;i++)
    {
      a=n*(i-1)-i*(i-1)/2+k+1-i;
      A[a][2*k-1].V=1;
    }
    for (j=1;j<=k;j++)
    {
     if (j==L[p])
     {
       for (i=1;i<=2*k-3;i++)
       {
        if (i!=p)
        {
         if (L1[p]>L[p])
         a=floor1((n-0.5*L[p])*(L[p]-1)+L1[p]-L[p]);
         else
         a=floor1((n-0.5*L1[p])*(L1[p]-1)+L[p]-L1[p]);
         if (A[a][i].V==1)
         {
          if (NUM[i][L[p]].V==0)
            a=floor1((n-0.5*L[p])*(L[p]-1)+k+1-L[p]);
          else
            a=floor1((n-0.5*L1[p])*(L1[p]-1)+k+1-L1[p]);
          A[a][i].V=1;
         }
        }
       }
     }
     else if (j!=L1[p])
     {
      a=floor1((n-0.5*j)*(j-1)+k+1-j);
      if (j<L[p])
      a1=floor1((n-0.5*j)*(j-1)+L[p]-j);
      else
      a1=floor1((n-0.5*L[p])*(L[p]-1)+j-L[p]);

      if (j<L1[p])
      a2=floor1((n-0.5*j)*(j-1)+L1[p]-j);
      else
      a2=floor1((n-0.5*L1[p])*(L1[p]-1)+j-L1[p]);
      for (i=1;i<=2*k-3;i++)
       {
        if ((i!=p)&&((A[a1][i].V+A[a2][i].V==2)||((NUM[i][j].V+NUM[i][L[p]].V==0)&&(A[a2][i].V==1))||((NUM[i][j].V+NUM[i][L1[p]].V==0)&&(A[a1][i].V==1))))
          A[a][i].V=1;
       }
     }
    }
    for (i=1;i<=k;i++)
     NUM[2*k-2][i].V=NUM[p][i].V;
    NUM[2*k-2][k+1].V=1;

    for (i=1;i<=k;i++)
     NUM[2*k-1][i].V=1;

    for (i=1;i<=2*k-3;i++)
    {
     if (((NUM[i][L[p]].V+NUM[i][L1[p]].V)!=0)&&(i!=p))
      NUM[i][k+1].V=1;
    }

    L[2*k-2]=k+1; L1[2*k-2]=L1[p];
    L[2*k-1]=L1[p]; L1[2*k-1]=k+1;
    L1[p]=k+1;
   }

   //srand((unsigned) time(&t));
   
 // Exponential distribution generator with expectation 1/(2n-3)  
 // 1. Generate U~U(0,1)
 // 2. Compute X = -ln(U)/lambda
 // 3. To obtain an exponential distribution with theoretical mean (= "expected
 // value") of 1/(2n-3), use lambda = 1 and multiply X by 1/(2n-3):     
 // Thus, X = -(1/(2n-3))*ln(U)
 // This formula is given in Numerical Recipes, p.200.*/ 
 // Every branch length of the tree T is then multiplied by 1+aX,
 // where X followed the standard exponential distribution (P(X>n)=exp(-n)) and 
 //  "a" is a tuning factor to adjust the deviation from the molecular clock; "a" is set at 0.8. 
 // 4. LON[i] = LON[i]*(1+0.8*-ln(U))
 
   U = 0.1;
   //while (U<0.1) U = 1.0*rand()/RAND_MAX;
   
   for (i=1;i<=2*n-3;i++)
		LON[i] = -1.0/(2*n-3)*log(U);    
   
   //for (i=1;i<=2*n-3;i++)
   i=1;
   while (i<=2*n-3)
		{  U = 1.0*rand()/RAND_MAX;  LON[i] = 1.0*LON[i]*(1.0+0.8*(-log(U)));  LON[i] = LON[i]*2; ///5.0 ;//0.8
           if (LON[i]>2*epsilon) i++;/*printf("U=%f LON[%d]=%f \n",U,i,LON[i]);*/}
      
 // Computation of a tree distance matrix (tree metric matrix)
   for (i=1;i<=n;i++)
   {
    DA[i][i]=0;
    for (j=i+1;j<=n;j++)
    {
     DA[i][j]=0;
     a=floor1((n-0.5*i)*(i-1)+j-i);
     for (k=1;k<=2*n-3;k++)
      if (A[a][k].V==1) DA[i][j]=DA[i][j]+LON[k];
     DA[j][i]=DA[i][j];
    }
   }

// Normalisation of the tree distance matrix
 /*double m=0.0, var=0.0;
 for (i=1;i<=n;i++)
 {
  for (j=i+1;j<=n;j++)
  { 
   m=m+2.0*DA[i][j]/n/(n-1);
   var=var+2.0*DA[i][j]*DA[i][j]/n/(n-1);
  }
 }
 var=var-m*m;
 for (i=1;i<=n;i++)
 {
  for (j=1;j<=n;j++)
      DA[i][j]=DA[i][j]/sqrt(var); 
 }*/

/* Addition of noise to the tree metric */
  //srand((unsigned) time(&t));
  
  for (i=1;i<=n;i++)
  {
   DI[i][i]=0.0;
   for (j=i+1;j<=n;j++)
   {
    X=0.0;   
    for (k=1;k<=5;k++)
    {
	  X0 = 1.0*rand()/RAND_MAX;
      X=X+0.0001*X0;
    }
    X=2*sqrt(0.6)*(X-2.5);
    U=X-0.01*(3*X-X*X*X);
    DI[i][j]=DA[i][j]+Sigma*U;
    if (DI[i][j]<0) DI[i][j]=0.01;
    DI[j][i]=DI[i][j];
   }
  }
   
  free (L);
  free(L1);
  free(LON);    
  for (i=0;i<=n1;i++)
  {
    free(A[i]);
    if (i<=2*n-3) free(NUM[i]);
  }
  free(NUM);
  free(A);
}


int floor1(double x)
{  
  int i;
  
  if (ceil(x)-floor(x)==2) i=(int)x; 
  else if (fabs(x-floor(x)) > fabs(x-ceil(x))) i=(int)ceil(x);
  else i=(int)floor(x);
  return i;
} 

/****************************************************
* application de la m�thode NJ pour construire
* une matrice additive
****************************************************/
void NJ(double **D1,double **DA)
{
double **D,*T1,*S,*LP,Som,Smin,Sij,L,Lii,Ljj,l1,l2,l3,epsilon = 0.00005;
int *T,i,j,ii,jj,n1;

D=(double **) malloc((n+1)*sizeof(double*));
T1=(double *) malloc((n+1)*sizeof(double));
S=(double *) malloc((n+1)*sizeof(double));
LP=(double *) malloc((n+1)*sizeof(double));
T=(int *) malloc((n+1)*sizeof(int));

for (i=0;i<=n;i++)
{
  D[i]=(double*)malloc((n+1)*sizeof(double));

  if (D[i]==NULL)
  {
	  { printf("Data matrix is too large"); return;}
  }
}


L=0;
Som=0;
for (i=1;i<=n;i++)
{
  S[i]=0; LP[i]=0;
  for (j=1;j<=n;j++)
    {
      D[i][j]=D1[i][j];
      S[i]=S[i]+D[i][j];
    }
  Som=Som+S[i]/2;
  T[i]=i;
  T1[i]=0;
}

/* Procedure principale */
for (n1=n;n1>3;n1--)
{

  /* Recherche des plus proches voisins */
  Smin=2*Som;
  for (i=1;i<=n1-1;i++)
  {
   for (j=i+1;j<=n1;j++)
   {
    Sij=2*Som-S[i]-S[j]+D[i][j]*(n1-2);
    if (Sij<Smin)
    {
     Smin=Sij;
     ii=i;
     jj=j;
    }
   }
  }
/* Nouveau groupement */

  Lii=(D[ii][jj]+(S[ii]-S[jj])/(n1-2))/2-LP[ii];
  Ljj=(D[ii][jj]+(S[jj]-S[ii])/(n1-2))/2-LP[jj];

/* Mise a jour de D */

  if (Lii<2*epsilon) Lii=2*epsilon;
  if (Ljj<2*epsilon) Ljj=2*epsilon;
  L=L+Lii+Ljj;
  LP[ii]=0.5*D[ii][jj];

  Som=Som-(S[ii]+S[jj])/2;
  for (i=1;i<=n1;i++)
  {
    if ((i!=ii)&&(i!=jj))
    {
     S[i]=S[i]-0.5*(D[i][ii]+D[i][jj]);
     D[i][ii]=(D[i][ii]+D[i][jj])/2;
     D[ii][i]=D[i][ii];
    }
  }
  D[ii][ii]=0;
  S[ii]=0.5*(S[ii]+S[jj])-D[ii][jj];

  if (jj!=n1)
  {
    for (i=1;i<=n1-1;i++)
    {
     D[i][jj]=D[i][n1];
     D[jj][i]=D[n1][i];
    }
    D[jj][jj]=0;
    S[jj]=S[n1];
    LP[jj]=LP[n1];
  }
/* Mise a jour de DA */
  for (i=1;i<=n;i++)
  {
    if (T[i]==ii) T1[i]=T1[i]+Lii;
    if (T[i]==jj) T1[i]=T1[i]+Ljj;
  }


  for (j=1;j<=n;j++)
  {
   if (T[j]==jj)
   {
     for (i=1;i<=n;i++)
     {
       if (T[i]==ii)
       {
         DA[i][j]=T1[i]+T1[j];
         DA[j][i]=DA[i][j];
       }
     }
   }
  }

  for (j=1;j<=n;j++)
  if (T[j]==jj)  T[j]=ii;

  if (jj!=n1)
  {
   for (j=1;j<=n;j++)
   if (T[j]==n1) T[j]=jj;
  }
}

/*Il reste 3 sommets */

l1=(D[1][2]+D[1][3]-D[2][3])/2-LP[1];
l2=(D[1][2]+D[2][3]-D[1][3])/2-LP[2];
l3=(D[1][3]+D[2][3]-D[1][2])/2-LP[3];
if (l1<2*epsilon) l1=2*epsilon;
if (l2<2*epsilon) l2=2*epsilon;
if (l3<2*epsilon) l3=2*epsilon;
L=L+l1+l2+l3;

for (j=1;j<=n;j++)
{
   for (i=1;i<=n;i++)
   {
    if ((T[j]==1)&&(T[i]==2))
    {
     DA[i][j]=T1[i]+T1[j]+l1+l2;
     DA[j][i]=DA[i][j];
    }
    if ((T[j]==1)&&(T[i]==3))
    {
     DA[i][j]=T1[i]+T1[j]+l1+l3;
     DA[j][i]=DA[i][j];
    }
    if ((T[j]==2)&&(T[i]==3))
    {
     DA[i][j]=T1[i]+T1[j]+l2+l3;
     DA[j][i]=DA[i][j];
    }
   }
   DA[j][j]=0;
}

  free(T);
  free(T1);
  free(S);
  free(LP);
  for (i=0;i<=n;i++)
  {
  	free(D[i]);
  }
  free(D);

}


/* La recherche d'un ordre diagonal plan */
void odp(double **D,int *X,int *i1,int *j1)
{
 double S1,S;
 int i,j,k,a,*Y1;
 
 Y1=(int *) malloc((n+1)*sizeof(int));
 
 for(i=1;i<=n;i++)
  Y1[i]=1;
  
 X[1]=*i1;
 X[n]=*j1;
 if (n==2) return;
 Y1[*i1]=0;
 Y1[*j1]=0;
 for(i=0;i<=n-3;i++)
 { a=2;
   S=0;
   for(j=1;j<=n;j++)
   { if (Y1[j]>0)
    {
      S1= D[X[n-i]][X[1]]-D[j][X[1]]+D[X[n-i]][j];
      if ((a==2)||(S1<=S))
      {
        S=S1;
        a=1;
        X[n-i-1]=j;
        k=j;
      }
    }
   }
   Y1[k]=0;
 }
 
   free(Y1);
}

/* Calcule les tableaux ARETE et LONGUEUR contenant les aretes et leur longueurs
a partir d'une matrice de distance d'arbre DI de taille n par n; 
la fonction auxiliaire odp est appell�e une fois */  

void Tree_edges (double **DI, long int *ARETE, double *LONGUEUR)
{ 
 struct EDGE { unsigned int U; unsigned int V; double LN;};
 struct EDGE *Path,*Tree;
 int i,j,k,p,P,*X;
 double S,DIS,DIS1,*L,**D;
 
  X=(int *)malloc((n+1)*sizeof(int));  
  L=(double *)malloc((n+1)*sizeof(double));
  Tree=(EDGE *)malloc((2*n-2)*sizeof(EDGE));
  Path=(EDGE *)malloc((n+2)*sizeof(EDGE));
 
 
 D=(double **) malloc((n+1)*sizeof(double*));
 
 for (i=0;i<=n;i++)
 {
  D[i]=(double*)malloc((n+1)*sizeof(double)); 
  
  if (D[i]==NULL)
  {
    printf("Data matrix is too large"); exit(1); 
  }
 }
 
 i=1; j=n;
 odp1(DI,X,&i,&j,n);
 
 for (i=1;i<=n;i++)
 { 
  for (j=1;j<=n;j++) 
   D[i][j]=DI[i][j];
 }  
   
 /* Verification de l'equivalence des topologies */
 L[1]=D[X[1]][X[2]];
 Path[1].U=X[1];
 Path[1].V=X[2];

 p=0;
 P=1;
 
 for(k=2;k<=n-1;k++)
 {

  DIS=(D[X[1]][X[k]]+D[X[1]][X[k+1]]-D[X[k]][X[k+1]])/2;
  DIS1=(D[X[1]][X[k+1]]+D[X[k]][X[k+1]]-D[X[1]][X[k]])/2;
  
  S=0.0;
  i=0;

  if (DIS>2*epsilon)
  {
    while (S<DIS-epsilon)
    {
     i=i+1;
     S=S+L[i];
    }
  }
  else { DIS=0; i=1; }
  
  Tree[p+1].U=n+k-1;
  Tree[p+1].V=Path[i].V;
  Tree[p+1].LN=S-DIS;
  if (Tree[p+1].LN<2*epsilon) Tree[p+1].LN=epsilon; 
  
  for (j=i+1;j<=P;j++)
  {
   Tree[p+j-i+1].U=Path[j].U;
   Tree[p+j-i+1].V=Path[j].V;
   Tree[p+j-i+1].LN=L[j];
   if (L[j]<2*epsilon) L[j]=2*epsilon; 
  }
  p=p+P-i+1;
  
  Path[i].V=n+k-1;
  Path[i+1].U=n+k-1;
  Path[i+1].V=X[k+1];
  L[i]=L[i]+DIS-S;
  L[i+1]=DIS1;
  P=i+1;
 }
 
  for (i=1;i<=P;i++) 
  {
   Tree[p+i].U=Path[i].U;
   Tree[p+i].V=Path[i].V;
   Tree[p+i].LN=L[i];
  }
 
 for (i=1;i<=2*n-3;i++)
 {
  if (fabs(Tree[i].LN-epsilon)<=2*epsilon)
   Tree[i].LN=0.0;
  ARETE[2*i-2]=Tree[i].U;
  ARETE[2*i-1]=Tree[i].V;
  LONGUEUR[i-1]=Tree[i].LN;   
  if (LONGUEUR[i-1]<2*epsilon) LONGUEUR[i-1] = 2*epsilon;
 } 
 
 free(X);
 free(Tree);
 free(L);
 free(Path);

 
 for (i=0;i<=n;i++)    
    free(D[i]);
    
 free(D);
}

/* Fonction auxiliaire odp. La recherche d'un ordre diagonal plan */

void odp1(double **D, int *X, int *i1, int *j1, int n)
{
 double S1,S;
 int i,j,k,a,*Y1;
 
 Y1=(int *) malloc((n+1)*sizeof(int));
 
 for(i=1;i<=n;i++)
  Y1[i]=1;
  
 X[1]=*i1;
 X[n]=*j1;
 if (n==2) return;
 Y1[*i1]=0;
 Y1[*j1]=0;
 for(i=0;i<=n-3;i++)
 { a=2;
   S=0;
   for(j=1;j<=n;j++)
   { if (Y1[j]>0)
    {
      S1= D[X[n-i]][X[1]]-D[j][X[1]]+D[X[n-i]][j];
      if ((a==2)||(S1<=S))
      {
        S=S1;
        a=1;
        X[n-i-1]=j;
        k=j;
      }
    }
   }
   Y1[k]=0;
 }     
   free(Y1);
}


void SAVEASNewick(double *LONGUEUR, long int *ARETE,int nn,const char* t) 
{
	int n,root,a;
	int Ns;
	int i, j, sd, sf, *Suc, *Fre, *Tree, *degre, *Mark;
	double *Long;
	int *boot; 
	char *string = (char*)malloc(10000);	
	n = nn;
	Ns=2*n-3;
	
	double * bootStrap= NULL;
	
	Suc =(int*) malloc((2*n) * sizeof(int));
	Fre =(int*) malloc((2*n) * sizeof(int));
	degre =(int*) malloc((2*n) * sizeof(int));
	Long = (double*) malloc((2*n) * sizeof(double));	
	boot = (int*) malloc((2*n) * sizeof(int));
	Tree = (int*) malloc((2*n) * sizeof(int));
	Mark =(int*) malloc((2*n) * sizeof(int));
	
	if ((degre==NULL)||(Mark==NULL)||(string==NULL)||(Suc==NULL)||(Fre==NULL)||(Long==NULL)||(Tree==NULL)||(ARETE==NULL)||(LONGUEUR==NULL))	
		{ printf("Tree is too large to be saved"); return;} 
	
	for (i=1;i<=2*n-3;i++)
	{ 
		
		if (i<=n) degre[i]=1;
		else degre[i]=3;
	} degre[2*n-2]=3;
	
	root=Ns+1;
	
	int cpt=0;
	
	for (;;)
	{
		cpt++;
		if(cpt > 1000000) exit(1);
		a=0; a++;
		for (j=1;j<=2*n-2;j++)
			Mark[j]=0;
		
		for (i=1;i<=2*n-3;i++)
		{ 	  									
			if ((degre[ARETE[2*i-2]]==1)&&(degre[ARETE[2*i-1]]>1)&&(Mark[ARETE[2*i-1]]==0)&&(Mark[ARETE[2*i-2]]==0))
			{
				Tree[ARETE[2*i-2]]=ARETE[2*i-1]; degre[ARETE[2*i-1]]--; degre[ARETE[2*i-2]]--; Mark[ARETE[2*i-1]]=1; Mark[ARETE[2*i-2]]=1;
				Long[ARETE[2*i-2]]=LONGUEUR[i-1];
				if(bootStrap != NULL) boot[ARETE[2*i-2]] = (int) bootStrap[i-1];
				
			}
			else if ((degre[ARETE[2*i-1]]==1)&&(degre[ARETE[2*i-2]]>1)&&(Mark[ARETE[2*i-1]]==0)&&(Mark[ARETE[2*i-2]]==0))
			{
				Tree[ARETE[2*i-1]]=ARETE[2*i-2]; degre[ARETE[2*i-1]]--; degre[ARETE[2*i-2]]--; Mark[ARETE[2*i-1]]=1; Mark[ARETE[2*i-2]]=1;
				Long[ARETE[2*i-1]]=LONGUEUR[i-1];
				if(bootStrap != NULL) boot[ARETE[2*i-1]] = (int) bootStrap[i-1];
				
			}
			else if ((degre[ARETE[2*i-2]]==1)&&(degre[ARETE[2*i-1]]==1)&&(Mark[ARETE[2*i-2]]==0)&&(Mark[ARETE[2*i-1]]==0))
			{
				Tree[ARETE[2*i-2]]=ARETE[2*i-1]; root=ARETE[2*i-1]; degre[ARETE[2*i-1]]--; degre[ARETE[2*i-2]]--; a=-1;
				Long[ARETE[2*i-2]]=LONGUEUR[i-1];
				if(bootStrap != NULL) boot[ARETE[2*i-2]] = (int) bootStrap[i-1];
			}
			if (a==-1) break;
		}
		if (a==-1) break;
	}
	
	
	/*  On decale et on complete la structure d'arbre avec Successeurs et Freres  */
	for (i=Ns+1;i>0;i--)
	{ 	Fre[i]=0; Suc[i]=0;
		//Tree[i]=Tree[i-1]+1; Long[i]=Long[i-1];
	}	Tree[root]=0;/*Tree[Ns+1]=0;*/
	
	for (i=1;i<=Ns+1/*Ns*/;i++)
	{	
		if (i!=root) 
		{
			sd=i; sf=Tree[i];
			if (Suc[sf]==0) Suc[sf]=sd;
			else {	
				sf=Suc[sf];
				while (Fre[sf]>0) sf=Fre[sf];
				Fre[sf]=sd;
			}		 
		}
	}
	
	
	/* On compose la chaine parenthesee */
	string[0]=0; i=root;/*i=Ns+1;*/
	cpt=0;
	for (;;)
	{	
		if(cpt > 1000000) exit(1);
		
		if (Suc[i]>0)
		{	sprintf(string,"%s(",string);
		Suc[i]=-Suc[i]; i=-Suc[i]; }
		else if (Fre[i]!=0)
		{	if (Suc[i]==0) sprintf(string,"%s%d:%.4f,",string,i,Long[i]);
			else {
				if(bootStrap != NULL)
					sprintf(string,"%s%d:%.4f,",string,boot[i],Long[i]);
				else
					sprintf(string,"%s:%.4f,",string,Long[i]);
			}
		i=Fre[i]; }
		else if (Tree[i]!=0)
		{	if (Suc[i]==0) sprintf(string,"%s%d:%.4f)",string,i,Long[i]);
		else {
			if(bootStrap != NULL)
				sprintf(string,"%s%d:%.4f)",string,boot[i],Long[i]);
			else
				sprintf(string,"%s:%.4f)",string,Long[i]);
			}
		i=Tree[i]; }
		else break;
	}	
	strcat(string,";");
	
	FILE *pt_t = fopen(t,"w+");
	fprintf(pt_t,"%s",string);
	fclose(pt_t);
	
	free(Suc); free(Fre); free(Tree); free(Long); free(degre); free(Mark);	free(string);
}
