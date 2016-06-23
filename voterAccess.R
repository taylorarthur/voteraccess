library(dplyr); library(tidyr); library(rvest)

# Voter access score source:
# http://s3.rockthevote.com/downloads/2011-voting-system-scorecard.pdf
aRaw <- readLines("RTVAccessRank.txt")[-1*(1:20)]
statesReg <- regexpr("^[[:alpha:][:space:]]+", aRaw)
states <- regmatches(aRaw, statesReg) %>% trimws
regmatches(aRaw, statesReg, invert = T) %>%
  unlist %>% 
  subset(., . != "") %>%
  textConnection %>%
  read.table(stringsAsFactors = F) ->
  aDat

# giving ND credit for all registration-related points because they don't
# require any voter registration see footnote in source
aDat[states == "North Dakota", "V16"] <- "17.4"
aDat %>% select(accessScore = V16) %>% 
  mutate(accessScore = as.numeric(accessScore),
         state = states) ->
  aDat

# kaggle data incomplete and outdated :(
# # election results data from kaggle
# # https://www.kaggle.com/benhamner/2016-us-election
# vDat <- read.csv("2016_presidential_election/primary_results.csv")
# vDat %>% filter(party == "Democrat") %>% 
#   group_by(state, candidate) %>%
#   summarise(votes = sum(votes)) %>%
#   group_by(state) %>%
#   mutate(vote_fraction = votes / sum(votes)) %>% View

#wikipedia election result data
url <- "https://en.wikipedia.org/wiki/Democratic_Party_presidential_primaries,_2016"
selector <- "#mw-content-text > table:nth-child(75)"
xp <- '//*[@id="mw-content-text"]/table[16]'
h <- read_html(url) 
h %>%
  html_nodes(xpath = xp) %>%
  html_table(fill = T) ->
  eDatRaw
eDatRaw <- eDatRaw[[1]]
# drop header rows and redundant, nonbinding primaries in WA & NE
eDat <- eDatRaw[setdiff(3:61, c(48,52)), c(1,2,6,7,8)] 
names(eDat) <- c("date", "state", "clinton", "sanders", "extra")
isOffset <- !grepl("^0", eDat$date)
eDat %>% mutate(state = ifelse(isOffset, date, state),
                 clinton = ifelse(isOffset, clinton, sanders),
                 sanders = ifelse(isOffset, sanders, extra)) %>%
  select(-date, -extra) %>%
  mutate(state = gsub("\\[[[:digit:]]+\\]", "", state)) %>%
  mutate_each(funs(gsub(".*\\(|%\\)", "", .)), clinton, sanders) %>%
  mutate_each(funs(as.numeric(.)/100), clinton, sanders) %>% 
  mutate(sandersLogOdds = log(sanders / clinton)) ->
  eDat

dat <- inner_join(aDat, eDat, by = "state")

#viz time
source("colorplane.R")

# map data with AK, HI. Taken from http://stackoverflow.com/a/13767984
require(maptools)
require(rgdal)

fixup <- function(usa,alaskaFix,hawaiiFix){
  
  alaska=usa[usa$STATE_NAME=="Alaska",]
  alaska = fix1(alaska,alaskaFix)
  proj4string(alaska) <- proj4string(usa)
  
  hawaii = usa[usa$STATE_NAME=="Hawaii",]
  hawaii = fix1(hawaii,hawaiiFix)
  proj4string(hawaii) <- proj4string(usa)
  
  usa = usa[! usa$STATE_NAME %in% c("Alaska","Hawaii"),]
  usa = rbind(usa,alaska,hawaii)
  
  return(usa)
  
}

fix1 <- function(object,params){
  r=params[1];scale=params[2];shift=params[3:4]
  object = elide(object,rotate=r)
  size = max(apply(bbox(object),1,diff))/scale
  object = elide(object,scale=size)
  object = elide(object,shift=shift)
  object
}

#state shape file from 
# http://www.arcgis.com/home/item.html?id=f7f805eb65eb4ab787a0a3e1116ca7e5
us <- readOGR(dsn = "states21basic", layer = "states")
usAEA = spTransform(us,CRS("+init=epsg:2163"))
usfix = fixup(usAEA,c(-35,1.5,-2800000,-2600000),c(-35,.75,-1000000,-2400000))
usfix = spTransform(usfix,CRS("+init=epsg:4326"))
usMap <- fortify(usfix, region = "STATE_NAME")
usMap$id <- tolower(usMap$id)
dat <- mutate(dat, state = tolower(state))

mp <- ggplot(dat, aes(map_id = state)) +
  geom_map(aes(fill = colorPlane(accessScore, sanders)), map = usMap) +
  scale_fill_identity() +
  expand_limits(x = usMap$long, y = usMap$lat) +
  coord_map() +
  theme_void() +
  theme(plot.title = element_text(size = 28)) +
  ggtitle("Voting Access Score v. 2016 Democratic Primary Results")

leg <- legendPlot(dat$accessScore, dat$sanders, "Voter Access Score", 
                  "Sanders Vote %") + 
  theme(axis.title = element_text(size = 18)) +
  scale_y_continuous(labels = scales::percent)

png("accessxvote.png" , 800, 800)
gridExtra::grid.arrange(mp, leg, layout_matrix = matrix(c(1, 1, NA, 1, 1, 2, 1, 1, NA), ncol = 3))
dev.off()
