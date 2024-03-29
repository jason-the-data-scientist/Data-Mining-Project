#Unsupervised Learning
#Jason Colgrove ----

dev.off()
library(clValid)
library(clusterSim)
library(cluster)



##Read in the data----
load(file="cluster_data.RData")
cluster <- y
#cluster <- read.csv("C:/Users/jason/Documents/College (TAMU)/Spring 2021/stat 639/Project/cluster_data.csv")
#Set seed
set.seed(2022)




#try subsetted data
#cluster <- cluster[-c(69,  94, 128, 188, 217, 237, 366, 489, 535, 806, 861),]

#######Determine K----
#PCA

#If we want to calculate PCA.
pca.out <- prcomp(cluster, scale=TRUE)
su <- summary(pca.out)
#Look at the total variance at a each PC number.
plot(pca.out$sdev, type ="l", 
     ylab= "Variance Explained", xlab="Number Clusters",
     main= "Determine Number of Clusters")
abline(v=9, col ="red")
abline(v=30, col ="blue")
abline(v=65, col ="orange")

write.csv(pca)
##Zoomed in graph
plot(pca.out$sdev[1:30], type ="l", 
     ylab= "Variance Explained", xlab="Number Clusters",
     main= "Determine Number of Clusters")
abline(v=9, col ="red")
library(ggplot2)
ggplot(as.data.frame(pca.out$sdev[1:30]), geom_segment(aes(row(as.data.frame(pca.out$sdev[1:30])))))
#It appears that between 9 and 10 is the best number of clusters
#You could make the argument that 2 is best but that seems
#unreasonable since there are so many variables.

### There are other methods to determine the optimal number
#of clusters
library(factoextra)

#Kmeans
fviz_nbclust(cluster, kmeans, method = "wss", k.max = 25) #best is 9-10 clusters
fviz_nbclust(cluster, kmeans, method='silhouette') #best if 2 clusters
fviz_nbclust(cluster, kmeans, method='gap_stat') #best is 9 clusters

#Hierarchical
fviz_nbclust(cluster, hcut, method='silhouette', k.max=20) #best is 10 clusters

#It appears that these methods reinforce our PCA method.

#We can now proceed and use hierarchical clustering and
#cut it off at k=9.


#Based on this PCA plot and using the elbow method and the Gap Statistic, it
#would appear that using a cluster size of 9 is best.
K <- 9


#Once we have establish the important relationships and clusters
#that we want to use, we need to determine which cluster
#each data point belongs to.



#######Hierarchical----
##Hierarchical
#Complete is the most common one that I found in my
#research.
hc.complete=hclust(dist(cluster),method="complete")

#Cut the tree at K. K was determined by PCA.
hc.cut=cutree(hc.complete,20)

table(hc.cut)
hc.cut[hc.cut > 2]
#Check hc.cut to make sure that the clusters are actually
#clusters.
#It appears that for K=9, the clusters are almost all cluster
#1. This is very concerning. The following plot indicates this
#concern.

#Plot of Dendogram
plot(hc.complete, col = hc.cut)
#There appears to be outliers such as points 91 and 217.

#Check the Dunn value. The Dunn value indicates how good
#the clustering is. The larger to value the better the 
#clustering is.
#Higher values is better clustering.
dunn(dist(cluster),hc.cut)

#Since the Dunn index is 0.8258199, this indicates that clustering was
#applied in a way that makes sense.
#A higher Dunn index is better.

#Sample Plot of data comparing variables
sam <- sample(1:784, 22)
par(mfrow=c(2, 3))
for (i in 1:20) {
  plot(cluster[,sam[i]], cluster[,sam[i+1]], col= hc.cut,
       main= "Sample Plot")
  i= i+2
}





##K-Means----
##K-Means
km.out=kmeans(cluster,centers=K,nstart=100)
# print output: there are cluster means, cluster assignment, within cluster ss
km.out


## One way to visualize K-means clustering output is to draw a scatterplot of
## the first two PCs and color-code the points based on cluster membership.
cl <- rainbow(K)
eigen_vecs <- pca.out$sdev^2
PC_1 <- cluster %*% pca.out$rotation[, 1]
PC_2 <- cluster %*% pca.out$rotation[, 2]
par(mfrow=c(1, 1))
par(mar=c(4,4,4,4))
plot(PC_1, PC_2, main= "PC 1 vs PC 2", xlab= "PC 1", ylab="PC 2")
points(PC_1, PC_2, col = cl[km.out$cluster], pch = 20)
#This graph isn't very reassuring. It shows that the data
#is pretty much indistinguishable for the first 2 PCs.


#Run the Dunn index on K-means
dunn(clusters = km.out$cluster,Data = cluster)
#The value is 0.7463832 which means that the hierarchical
#method if better.

#Let's plot the cluster results by k-means.
plot(cluster,col=km.out$cluster,cex=2,pch=1,lwd=2, 
     main="2-D Display of Clustering")
#In this case, I don't think this plot gives us any information.


#Sample clustering with hierarchical.
sam <- sample(1:500, 10)
par(mfrow=c(2, 3))
for (i in 1:9) {
  plot(cluster[,sam[i]], cluster[,sam[i+1]], col= hc.cut,
       main= "Sample Plot")
  i= i+2
}

#This plot shows how distinguishable the variables are from a
#random sample of 100.
sam <- sample(1:784, 22)
par(mfrow=c(2, 3))
for (i in 1:20) {
  plot(cluster[,sam[i]], cluster[,sam[i+1]], col= km.out$cluster,
       main= "Sample Plot")
  i= i+2
}



##Compare Methods----
##Compare
#In conclusion, it appears that K-means is the best method
#to determine the clustering. Hierarchical for whatever reason
#was only having 1 data point for all of the clusters
#expect the first one. My reasoning would be that there are too many outliers.
#The assigned clusters are in the data set
#km.out$cluster.



#Compare Hierarchical vs K-means
table(hc.cut,km.out$cluster)
mean(km.out$cluster==hc.cut) #Percent of same cluster.
# Hierarchical clusters have a one large cluster and few data 
# points assigned to the other clusters.
# K-means assigns clusters fairly evenly but not exactly. 
# We don't necessarily want an even amount of data points 
# assigned to each cluster but we also don't want all of the 
# data in one cluster.

#Compare Plots of clustered data
plot(cluster,col=km.out$cluster,cex=2,pch=1,lwd=2, main = "K-Means Clusters")
plot(cluster,col=hc.cut,cex=2,pch=1,lwd=2, main = "Hierarchical")
# This is similar is the story that hierarchical is assigning
# very few data points to some clusters and many to one.

index.DB(cluster, hc.cut, d=NULL)$DB
index.DB(cluster, km.out$cluster, d=NULL)$DB
#A lower value is better for this metric.
#Both Dunn and DB indicate the hierarchical is better
#but it has few data points to every cluster
#except the first one.


# It would appear that there are some outliers in the data.
# This would usually indicate that K-means is not an appropriate
#model since it used the means of the data and the clusters
#would be skewed. We could assign these values as noise points.

#K-means
km.out$cluster
table(km.out$cluster)


library(dbscan)
db = dbscan(cluster, eps = 25, minPts=2)
db
db$cluster
length(table(db$cluster))
plot(cluster,col=db$cluster+1,cex=2,pch=1,lwd=2)

dbs <- c()
for(i in 1:50) {
  for(j in 1:20)
  db = dbscan(cluster, eps = i, minPts=j)
  if(length(table(db$cluster)) == 9) {
    dbs <- cbind(dbs, db)
  }
}

