# TODO: Add comment
# 
# Author: mjskay
###############################################################################

library(rgdal)	#spTransform
library(ggplot2)
library(stringr)
library(reshape2)
library(hexbin)
library(plyr)
melt.data.frame = reshape2:::melt.data.frame	#fix conflict of reshape2 with reshape

frame_files <- lapply(sys.frames(), function(x) x$ofile)
frame_files <- Filter(Negate(is.null), frame_files)
FILE_PATH <- dirname(frame_files[[length(frame_files)]])

DATA_PATH = FILE_PATH


#read in data
df = read.csv(paste(DATA_PATH, "whiskies.txt", sep="/"))

#clean up post code (has whitespace that needs trimming)
df$Postcode = factor(str_trim(as.character(df$Postcode)))

##normalize
#normalize = function(x) { mn = min(x); mx = max(x); (x - mn) / (mx - mn) }
#df[,1:12+2] = apply(df[,1:12+2], 2, normalize)

#convert UK UTM coordinates to lat/long
coordinates(df) = c("Latitude", "Longitude")
proj4string(df) = CRS("+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs")
df = spTransform(df, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
df = cbind(df@data, df@coords)
names(df)[16:17] = c("Longitude", "Latitude")

#write out cleaned data
write.csv(df, paste(DATA_PATH, "whiskies.csv", sep="/"), row.names=FALSE)

#load map
md = map_data("world", region="UK")

ggplot(md) + geom_map(aes(map_id=region, alpha=.5), map=md) + geom_point(aes(x=Longitude, y=Latitude, color="red", alpha=Fruity), data=df)


#scatterplot matrix of flavors
plotmatrix(df[,1:12+2]) + geom_jitter() + stat_smooth(method=lm)

#hexbin the flavor characteristics
binfunc = mean	#binning functions to consider: min, max, mean, median, ... ?
hb = hexbin(df$Longitude, df$Latitude, IDs=TRUE)
hexdf = ddply(df, ~ hb@cID, function(d) apply(d[,1:12+2], 2, binfunc))	#aggregate data by bins
hexdf = cbind(hexdf, hcell2xy(hb))	#put x, y coords of bins into hexdf$x, y
ggplot(md) + geom_map(aes(map_id=region, alpha=.5), map=md) + geom_hex(aes(x=x, y=y, fill=Medicinal), data=hexdf, stat="identity")


#small multiples by flavor
hexdfl = melt(hexdf[,-1], c("x","y"), variable.name="Flavor")
ggplot(hexdfl) + geom_map(aes(map_id=region, alpha=.5), data=md, map=md) + geom_hex(aes(x=x, y=y, fill=value), stat="identity") + facet_wrap(~Flavor)