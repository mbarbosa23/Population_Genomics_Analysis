library(adegenet)
library(pegas)
library(vcfR)
library(wordcloud)

#Import .vcf snps file
vcf <- read.vcfR( file = "~/populations.snps.vcf", verbose = FALSE )

#convert to genlight
SNP_genlight <- vcfR2genlight(vcf)

#import metadata for @pop
Sites <- read.csv("~/popmap.csv", fileEncoding="UTF-8-BOM")
class(Sites)

SNP_genlight@pop <- as.factor(Sites$Site)

#remove NAs from genlight object
X <- tab(SNP_genlight, NA.method = "zero")



##Create NJ tree
tree <- nj(dist(as.matrix(SNP_genlight)))
tree


plot(tree, typ="fan", cex=0.7)
title("NJ tree of data")


#Create simple pca
x.pca = dudi.pca(X, scannf=FALSE)

#Create scatter plot and assign color to groups
s.class(x.pca$li, pop(SNP_genlight), col=rainbow(nPop(SNP_genlight)))

#Add eigenvalues to plot
add.scatter.eig(x.pca$eig[1:5], ratio = 0.25,xax=1, yax=2, posi = "bottomright")



##Alternate pca plot

pca1 <- dudi.pca(X, scannf = FALSE, scale = FALSE)
temp <- as.integer(pop(SNP_genlight))
temp

myCol <- transp(c("blue","red"),.7)[temp]
myCol
myPch <- c(15,16)[temp]

plot(pca1$li, col=myCol, cex = 3, pch = myPch)

## use wordcloud for non-overlapping labels

textplot(pca1$li[,1], pca1$li[,2], words=rownames(X), cex=.5, new=FALSE)
## legend the axes by adding loadings
abline(h=0,v=0,col="grey",lty=2)


legend("bottom", pch=c(15,16), col=transp(c("blue","red"),.7),
       leg=c("Group WC5B", "Group C4"), pt.cex=2)

