###############################################
# Ajuste do modelo SBM - stochastic block model 
# Marina Amorim
# marinaaamorim@hotmail.com
###############################################

# OBJETIVO � OBTER A CLUSTERIZA��O 
# ESTIMANDO A PARTI��O ( INFER�NCIA ) PROBABILIDADE DE ESTAR EM UMA CLASSE 
# clusteriza dado a inferencia do SBM

## generation of one SBM network
install.packages("blockmodels", dependencies = T)
require(blockmodels)

#Pacote aceita entrar apenas com matriz de adjacencias
#Ele j� encontra as classes e melhor modelo

#Pacote usa criterio de kl e maxima verossimilhan�a para encontrar o melhor modelo
#########################################
# Tem que falar se quer testar se os vertices tem dist:
#Bernoulli, poisson ou gaussiana

#Latente no modelo � que vertice pertence a qual classe

# gerar um grafo com essas caracteristicas para ver se o modelo acerta
# gerando
npc <- 80 # nodes per class (numero de nos por classe)
Q <- 10 # classes numero
n <- npc * Q # nodes 
#Matriz Z � a matriz que fala a classe do no
Z<-diag(Q)%x%matrix(1,npc,1) #indice das classes / indica qual classe pertence cada n�
# Gerar a matriz de prob.
#Probabulidade de passar de uma classe para a outra
set.seed(1)
P<-matrix(runif(Q*Q),Q,Q) #probabilidade de transi��o entre classes
P 
#Gerar matriz de adjacencias
M<-1*(matrix(runif(n*n),n,n)<Z%*%P%*%t(Z)) ## adjacency matrix
M # Mostra a liga��o das arestas

g = graph_from_adjacency_matrix(M, "undirected", weighted = T)
decmp = (cluster_louvain(g3,weights = E(g3)$weight))
decmp


# Nosso SBM tem matriz de adj. M e matriz de prob P

## estimation
# Como geramos um bernoulli acima
my_model <- BM_bernoulli("SBM",M ) # Estamos falando que o modelo � bernoulli
#Escolhe o modelo e da a matriz de adj.
my_model$estimate() #Gera o sbm
# Se nao sabe a dist. tem que pensar no que faz sentido para fazer o modelo.
# Ele vai comparar o n�mero de classes
#ICL � criterio de KL, o menor indice indica o melhor modelo ( tipo um AIC)
#Integrated Classification Likelihood (ICL)

which.max(my_model$ICL)# mostra o que tem maior ICL
my_model$ICL # Qual o icl para cada numero de classes (1 classe, 2 classes e etc) (classe 3 melhor)
#Como deu negativo, pegar o mais proximo de zero 
my_model$PL #Maxima verossimilhan�a , pegar o menor tamb�m
my_model$memberships[[Q]]$Z #Divis�o das classes (Q classes)
my_model$memberships[[1]]$Z #Todos os v�rtices da primeira classe
my_model$memberships[[Q]]$plot() # Mostra as classes e os v�rtices
my_model$model_parameters #parametros do modelo
# mostra as probabilidades de transi��o para cada uma das classes (se tivesse essas classe).
# prob de transi��o de ir da classe 2 para a classe 3 0.6221199 se tivessem 3 classes
#[[3]]
#[[3]]$`pi`
#[,1]       [,2]      [,3]
#[1,] 0.09626253 0.38713218 0.3393022
#[2,] 0.93772968 0.48968802 0.6221199
#[3,] 0.46316817 0.03975172 0.6240966
# PODEMOS COMPARAR COM A MATRIZ P
my_model$model_parameters[3]
P # ELE PLOTA DIFERENTE A MATRIZ

my_model$plot_obs_pred(Q) # mostra a liga��o dos v�rtices
#distribui��o das arestas
#Se ta branquinho quer dizer que nao tem liga��o se preto tem liga��o
#faz com quantas classes quiser
# o segundo grafico � a probabilidade de intensidade da liga��o
#mesma coisa nos dois eixos

my_model$plot_obs_pred(Q) #
my_model$plot_parameters(Q) 


#-------------------------------------------------
#sbm dentro de cada classe � um bernoulli
# condicionado a classe o grafo � bernoulli ( pois temos a classe definida)
# sbm poisson , a dist dentro de cada classe � poisson.
#-------------------------------------------------

##
## SBM symmetric
##
## generation of one SBM_sym network
# Tem uma matrix M que seja simetrica
# Prob de ir de i para j � a maesma de j para i 
npc <- 30 # nodes per class
Q <- 3 # classes
n <- npc * Q # nodes
Z<-diag(Q)%x%matrix(1,npc,1)
P<-matrix(runif(Q*Q),Q,Q)
P[lower.tri(P)]<-t(P)[lower.tri(P)]
M<-1*(matrix(runif(n*n),n,n)<Z%*%P%*%t(Z)) ## adjacency matrix
M[lower.tri(M)]<-t(M)[lower.tri(M)] # muda neste comando
# Pega a matriz triangular inferior e transforma em triangular superior
## estimation
my_model <- BM_bernoulli("SBM_sym",M ) # Tem que falar que � SBM simetrico
my_model$estimate()
which.max(my_model$ICL)
my_model$ICL # 
my_model$PL
my_model$memberships[[Q]]$Z
my_model$memberships[[Q]]$plot()
my_model$model_parameters
my_model$plot_obs_pred(Q) 
my_model$plot_parameters(Q) 
#######################################
##
## LBM
# Mistura de SBM
##
## generation of one LBM network
######################################
# nao falou de que classe que os n�s s�o
# mistura de SBM , tem duas matriz de transi��o
# Latente � porque nao sabemos se � Z1 ou Z2
npc <- c(50,40) # nodes per class
Q <- c(2,3) # classes
n <- npc * Q # nodes
Z1<-diag(Q[1])%x%matrix(1,npc[1],1)#confundir o algoritmo sobre qual classe pertence cada n�
Z2<-diag(Q[2])%x%matrix(1,npc[2],1)
# n�o sabemos de que classe cada n� veio
# Agora vamos estimar a Z1 , Z2 e alpha ?
# Ele faz dois SBM e mistura eles ?

#Tem duas candidatas de qual classe pertence o n�.
# Ele nao sabe de onde esta vindo (Z1 ou Z2)

P<-matrix(runif(Q[1]*Q[2]),Q[1],Q[2])
M<-1*(matrix(runif(n[1]*n[2]),n[1],n[2])<Z1%*%P%*%t(Z2)) ## adjacency matrix
# mistura 2 latentes, para nao saber de qual veio
## estimation
my_model <- BM_bernoulli("LBM",M )
my_model$estimate()
which.max(my_model$ICL)
my_model$ICL
my_model$PL

my_model$memberships[[Q]]$Z
my_model$memberships[[Q]]$plot()
my_model$model_parameters
my_model$plot_obs_pred(Q) 
my_model$plot_parameters(Q) 


##
## SBM Covariates
##
## generation of one SBM network
npc <- 30 # nodes per class
Q <- 3 # classes
n <- npc * Q # nodes
sigmo <- function(x){1/(1+exp(-x))}
Z<-diag(Q)%x%matrix(1,npc,1)
Mg<-8*matrix(runif(Q*Q),Q,Q)-4
Y1 <- matrix(runif(n*n),n,n)-.5
Y2 <- matrix(runif(n*n),n,n)-.5
M_in_expectation<-sigmo(Z%*%Mg%*%t(Z) + 5*Y1-3*Y2)
M<-1*(matrix(runif(n*n),n,n)<M_in_expectation)
## estimation
my_model <- BM_bernoulli_covariates("SBM",M,list(Y1,Y2) )
my_model$estimate()
which.max(my_model$ICL)

##
## SBM symmetric
##
## generation of one SBM_sym network
npc <- 30 # nodes per class
Q <- 3 # classes
n <- npc * Q # nodes
sigmo <- function(x){1/(1+exp(-x))}
Z<-diag(Q)%x%matrix(1,npc,1)
Mg<-8*matrix(runif(Q*Q),Q,Q)-4
Mg[lower.tri(Mg)]<-t(Mg)[lower.tri(Mg)]
Y1 <- matrix(runif(n*n),n,n)-.5
Y2 <- matrix(runif(n*n),n,n)-.5
Y1[lower.tri(Y1)]<-t(Y1)[lower.tri(Y1)]
Y2[lower.tri(Y2)]<-t(Y2)[lower.tri(Y2)]
M_in_expectation<-sigmo(Z%*%Mg%*%t(Z) + 5*Y1-3*Y2)
M<-1*(matrix(runif(n*n),n,n)<M_in_expectation)
M[lower.tri(M)]<-t(M)[lower.tri(M)]
## estimation
my_model <- BM_bernoulli_covariates("SBM_sym",M,list(Y1,Y2) )
my_model$estimate()
which.max(my_model$ICL)


