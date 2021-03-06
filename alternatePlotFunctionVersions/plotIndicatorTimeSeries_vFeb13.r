################################################################################
#                                                                              #
#   Standardized plotting of indicator time series for Eco Status Report       #
#   M. Karnauskas, Nov 23, 2016                                                # 
#                                                                              #
#   Typical formatting used by Alaska Report Card and CC IEA                   #
#   Plots time series, values above and below 1 S.D., and mean                 # 
#   Highlights last 5 years of data and shows pattern in mean and trend        #
#                                                                              #
#   Note!!!  Need to use standardized .csv formatting                          #
#   Column 1 is time values, columns 2+ are indicator data                     #
#   Row 1 is indicator name (main title of plot)                               #
#   Row 2 is units (y-axis label)                                              #
#   Row 3 is spatial extent or other specifying information                    #
#   Time can be in yearly or monthly time steps, MUST be in this format:       #
#      YYYY (e.g., 2011) or mmmYYYY (e.g., Jan1986)                            #
#                                                                              #
################################################################################
#                                                                              #
#  INPUTS AS FOLLOWS:                                                          #
#  filename  = .csv file in standardized indicator reporting format (above)    # 
#  coltoplot = column number of indicator file to plot (only col 2 is default) # 
#  sublabel  = whether extent description should appear within main label      #
#  plotrownum and plotcolnum are for multi-panel plots (if coltoplot >1)       #
#   - specify layout (e.g., 4 panels could be plotrownum = 2, plotcolnum = 2   #
#  adjlabmain = manual adjustment of text size of main label                   #
#  adjlaby    = manual adjustment of text size of y-axis label                 #
#  yposadj    = manual adjustment of position of y-axis label                  #
#  widadj     = adjust total width of plot                                     #
#  trendAnalysis = whether to highlight trend in mean and SD over last 5 years #
#   ** default is T unless fewer than 4 data points available in last 5 years  # 
#  outname    = specify alternate output filename (default is same as input)   #
#  sameYscale = for multi-panel plots, if y-axis scale should be the same      #
#                                                                              #
#   function examples:                                                         #
#  plotIndicatorTimeSeries("indicator.csv", coltoplot=2:4, plotrownum=3)       #
#  plotIndicatorTimeSeries("amo.csv", coltoplot=2, plotrownum=1, plotcolnum=1, adjlabmain=1, sublabel=F)
#  plotIndicatorTimeSeries("aveSocialConnectedness.csv", coltoplot=2, plotrownum=1, plotcolnum=1, sublabel=F)
#  plotIndicatorTimeSeries("menhaden_abundance_index.csv", coltoplot=2, plotrownum=1, plotcolnum=1, sublabel=F, yposadj=0.8, widadj=0.8)
#  plotIndicatorTimeSeries("seagrass_acreage.csv", coltoplot=2:7, plotrownum=3, plotcolnum=2, adjlabmain=1, sublabel=T, widadj=0.6, trendAnalysis=F)
#                                                                              #
#  NEED TO INCLUDE "arrows.RData" in working directory                         #
#                                                                              #
################################################################################

plotIndicatorTimeSeries <-  function(filename, coltoplot=2, sublabel=F, plotrownum = 1, plotcolnum = 1, 
                                     adjlabmain=1, adjlaby=1, yposadj=1, widadj=1, trendAnalysis=T, outname=NA, sameYscale=F)  {

                                                                                # install necessary packages
if (!"formula.tools" %in% installed.packages()) install.packages("fields", repos='http://cran.us.r-project.org')
library(fields)

load("arrows.RData")                                                            # get arrow graphics -- set to be in working directory

  d1 <- read.table(filename, header=F, sep=",", skip=0, quote="")                         # load data file
  d <- read.table(filename, header=F, sep=",", skip=3, quote="")                          # load data file labels
  d <- d[rowSums(d, na.rm=T)!=0,]

  tim_all <- d$V1                                                                   # temporal data
  if ( class(tim_all)=="factor" )  {  monthly <- T  }   else  {  monthly <- F  }    # decide whether monthly or yearly and adjust accordingly
  if ( class(tim_all)=="factor" )  {  tim_all <- as.numeric(substr(tim_all,4,7)) + (match(substr(tim_all,1,3), month.abb)-1)/12  }
  
  if (monthly==F) { wid <- length(tim_all) }  else  { wid <- length(tim_all)/12 }       # adjustment for width
  if (length(tim_all) <= 10 & length(tim_all) > 5) {  wid <- wid*2  }
  if (length(tim_all) <= 5)  {  wid <- wid*3  }

  if (plotcolnum + plotrownum > 2)  { plotcolnum2 <- plotcolnum*0.6; plotrownum2 <- plotrownum*0.6 }  else { plotcolnum2 <- plotcolnum; plotrownum2 <- plotrownum }
  
  wid <- wid * widadj     #  set adjusted width if specified
                                                                                # set graphics specifications
if (is.na(outname))  {  filnam <- paste(c(unlist(strsplit(filename, ".csv"))), ".png", sep="") }   else   {  filnam <- outname  }
png(filename=filnam, units="in", width=((wid+10)/5)*plotcolnum2, height=(4*plotrownum2), pointsize=12, res=72*4)

                                                                                # layout for single or multi-panel plots
  nf <- layout(matrix(c(1:(plotrownum*plotcolnum*2)), plotrownum, plotcolnum*2, byrow = TRUE), rep(c(wid/5, 1), plotcolnum), rep(4, plotrownum))
  layout.show(nf)  
  
  if (length(coltoplot)==1 & length(tim_all) <= 5 | trendAnalysis==F)  {        # layout for single plots with fewer than 5 data points or no trend analysis
  nf <- layout(matrix(c(1:(plotrownum*plotcolnum)), plotrownum, plotcolnum, byrow = TRUE), rep(c(wid/5), plotcolnum), rep(3, plotrownum))
  layout.show(nf)         } 

  ymin <- min(d[,coltoplot], na.rm=T) * 0.94                                     # get common y scale
  ymax <- max(d[,coltoplot], na.rm=T) * 1.025    

for (i in coltoplot)  {                                                         # loop through indicator columns
  
  co_all <- d[,i]                                                               # data
  if (sum(!is.na(co_all)) == 0) {  plot.new(); plot.new()  }  else {
  
  tim <- tim_all[!is.na(co_all)]                                                # for dealing with missing values 
  co <- co_all[!is.na(co_all)]
  
if (length(tim) > 5) {  
  
  if (trendAnalysis==T)  {  par(mar=c(2.5,5,3,0), xpd=F)  }  else  {  par(mar=c(2.5,5,3,1), xpd=F)  } 
  if (sublabel==T) { mm <- paste(as.character(d1[1,i]), "-", as.character(d1[3,i])) } else { mm <- d1[1,i] }
  if (sameYscale==T)  {   plot(tim_all, co_all, col=0, axes=F, xlab="", ylab="", main="", ylim=c(ymin, ymax))    }                   # plot time series
  if (sameYscale==F)  {   plot(tim_all, co_all, col=0, axes=F, xlab="", ylab="", main="")                        }                   # plot time series
  if (adjlabmain==1)  {  mtext(side=3, line=1, mm, font=2, cex=1.5/mean(plotcolnum2, plotrownum2))  }  else  {    # main label
                         mtext(side=3, line=1, mm, font=2, cex=1.5*adjlabmain)  } 
    colind <- c("#FF000080", "#00FF0080")                                       # shading of anomalies +/- 1 S.D.  
if (length(tim) >= 5) {
    for (j in 2:length(tim))  {  polygon(c(tim[j-1], tim[j], tim[j], tim[j-1]), y=c(mean(co, na.rm=T), mean(co, na.rm=T), co[j], co[j-1]), col=colind[as.numeric(mean(co[(j-1):j], na.rm=T) > mean(co, na.rm=T))+1], border=F) }  
                      }
  polygon(c(min(tim_all, na.rm=T)-5, max(tim_all, na.rm=T)+5, max(tim_all, na.rm=T)+5, min(tim_all, na.rm=T)-5), 
      c(mean(co_all, na.rm=T)-sd(co_all, na.rm=T), mean(co_all, na.rm=T)-sd(co_all, na.rm=T), mean(co_all, na.rm=T)+sd(co_all, na.rm=T), mean(co_all, na.rm=T)+sd(co_all, na.rm=T)), col="white", border=T)
  polygon(c(max(tim_all, na.rm=T)-4.5-as.numeric(monthly)/2.1, max(tim_all, na.rm=T)+0.5-as.numeric(monthly)/2.4, max(tim_all, na.rm=T)+0.5-as.numeric(monthly)/2.4, max(tim_all, na.rm=T)-4.5-as.numeric(monthly)/2.1), 
      c((mean(co_all, na.rm=T)-sd(co_all, na.rm=T)), (mean(co_all, na.rm=T)-sd(co_all, na.rm=T)), (mean(co_all, na.rm=T)+sd(co_all, na.rm=T)), (mean(co_all, na.rm=T)+sd(co_all, na.rm=T))), col="#0000FF20", border=F)
  lines(tim_all, co_all, lwd=2); points(tim_all, co_all, pch=20)                         # plot time series 
  if (sd(diff(tim)) > 1 )  {  points(tim_all, co_all, pch=20, cex=1.5)   }
  abline(h=mean(co, na.rm=T), lty=8); abline(h=mean(co, na.rm=T)+sd(co, na.rm=T), lty=1); abline(h=mean(co)-sd(co), lty=1)
    if (length(tim) > 10)  { axis(1, at=seq(1900, 2015, 5)) } else { axis(1, at=seq(1900, 2016, 2)) }    
  axis(1, at=seq(1900, 2016, 1), tck=-0.015, lab=rep("", 117))                  # add axes
  axis(2, las=2); box()
  if (adjlaby==1)  {  mtext(side=2, line=3*yposadj, d1[2,i], cex=1.2/mean(plotcolnum2, plotrownum2))  }  else  {       # y-axis label
                      mtext(side=2, line=3*yposadj, d1[2,i], cex=1.2*adjlaby)  }
                            
  if (trendAnalysis==T)  {        
  par(mar=c(2.5,0,3,0))                                                         #  second panel on mean and trend of last 5 years
  if (monthly == F)  {  last5 <- co_all[(nrow(d)-4):nrow(d)]  }  else  {  last5 <- co_all[(nrow(d)-59):nrow(d)]  }
  plot(1, xlim=c(0.94,1.06), ylim=c(0.6, 1.6), col=0, axes=F, xlab="", ylab="")
  points(1, 1.2, pch=20, cex=6)                                                 # analyze mean of last 5 years
  if (sum(is.na(last5)) < 2)  {
  if (mean(last5, na.rm=T) > (mean(co, na.rm=T)+sd(co, na.rm=T)))  { text(1, 1.2, col="white", "+", cex=2.6, font=2) }
  if (mean(last5, na.rm=T) < (mean(co, na.rm=T)-sd(co, na.rm=T)))  { text(1, 1.2, col="white", "-", cex=2.6, font=2) }
  if (monthly == F)  {  res   <- summary(lm(last5~tim[1:5]))   } else {    res   <- summary(lm(last5~tim[1:60]))   }
    slope <- coef(res)[2,1]                                                     # analyze trend in last 5 years
    slopelim <- (1.0/ (length(last5))) * sd(co, na.rm=T)
      if (slope >  slopelim)  {   add.image(1,1, uparrow, col=grey((0:256)/256), image.width = 0.1, image.height = 0.1)   }
      if (slope <  -slopelim)  {  add.image(1,1, dnarrow, col=grey((0:256)/256), image.width = 0.1, image.height = 0.1)  }
      if (slope <= slopelim & slope >= -slopelim) {   add.image(1,1, sdarrow, col=grey((0:256)/256), image.width = 0.1, image.height = 0.1)  }
            }
         }
      }                                                                         # end looping through indicator columns

if (length(tim) <= 5) { 
  
  par(mar=c(2.5,5,3,1), xpd=F)
    if (sublabel==T) { mm <- paste(as.character(d1[1,i]), "-", as.character(d1[3,i])) } else { mm <- d1[1,i] }
if (sameYscale==T)  {   plot(tim_all, co_all, col=0, axes=F, xlab="", ylab="", main="", ylim=c(ymin, ymax))      }         # plot time series
if (sameYscale==F)  {   plot(tim_all, co_all, col=0, axes=F, xlab="", ylab="", main="")      }         # plot time series
  if (adjlabmain==1)  {  mtext(side=3, line=1, mm, font=2, cex=1.5/mean(plotcolnum2, plotrownum2))  }  else  {    # main label
                         mtext(side=3, line=1, mm, font=2, cex=1.5*adjlabmain)  } 
    colind <- c("#FF000080", "#00FF0080")                                       # shading of anomalies +/- 1 S.D.  
if (length(tim) >= 5) {    for (j in 2:length(tim))  {  polygon(c(tim[j-1], tim[j], tim[j], tim[j-1]), 
                                 y=c(mean(co, na.rm=T), mean(co, na.rm=T), co[j], co[j-1]), col=colind[as.numeric(mean(co[(j-1):j], na.rm=T) > mean(co, na.rm=T))+1], border=F) }     }
  polygon(c(min(tim_all)-5, max(tim_all)+5, max(tim_all)+5, min(tim_all)-5), 
          c(mean(co_all, na.rm=T)-sd(co_all, na.rm=T), mean(co_all, na.rm=T)-sd(co_all, na.rm=T), mean(co_all, na.rm=T)+sd(co_all, na.rm=T), mean(co_all, na.rm=T)+sd(co_all, na.rm=T)), col="white", border=T)
  lines(tim_all, co_all, lwd=2); points(tim_all, co_all, pch=20)                         # plot time series 
  if (sd(diff(tim)) > 1 )  {  points(tim_all, co_all, pch=20, cex=1.5)   }
  abline(h=mean(co, na.rm=T), lty=8); abline(h=mean(co, na.rm=T)+sd(co, na.rm=T), lty=1); abline(h=mean(co, na.rm=T)-sd(co, na.rm=T), lty=1)
  axis(1, at=tim) 
  axis(1, at=seq(1900, 2016, 1), tck=-0.015, lab=rep("", 117))                                                 # add axes
  axis(2, las=2); box()
  if (adjlaby==1)  {  mtext(side=2, line=3*yposadj, d1[2,i], cex=1.2/mean(plotcolnum2, plotrownum2))  }  else  {       # y-axis label
                      mtext(side=2, line=3*yposadj, d1[2,i], cex=1.2*adjlaby)  }
  if (length(coltoplot)>1 & trendAnalysis==T)  {
  par(mar=c(0,0,0,0), xpd=F)                    
  plot(1, col="white", axes=F, xlab="", ylab="")     }           
      }                                                                         # end looping through indicator columns
    }
  }

dev.off()                                                                       # close graphics device
}                                                                               # end of function

