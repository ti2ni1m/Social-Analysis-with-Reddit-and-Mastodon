library("tm") # Term frequency matrix
library("SnowballC") # Stemming of text
library("RedditExtractoR") # Reddit API
library(wordcloud) # Created of Word Cloud
library(ggplot2) # Data Visualisation
library(rtoot) # Mastodon API
library(knitr) # Table generation
library(igraph) # graphs and visualization.

# Question 1 --------------------------------------------------------------
#Part 1:
iPhoneThreads <- find_thread_urls(subreddit = 'iphone', sort_by = 'top', period = 'week')
watchThreads <- find_thread_urls(subreddit = 'AppleWatch', sort_by = 'top', period = 'week')
macThreads <- find_thread_urls(subreddit = 'mac', sort_by = 'top', period = 'week')

iPhoneThreads <- read.csv("Data/iPhoneThreads.csv")
watchThreads <- read.csv("Data/watchThreads.csv")
macThreads <- read.csv("Data/macThreads.csv")

class(iPhoneThreads)
class(macThreads)
class(watchThreads)

dim(iPhoneThreads)
dim(macThreads)
dim(watchThreads)

str(iPhoneThreads)

iPhone <- iPhoneThreads$text
watch <- watchThreads$text
mac <- macThreads$text

class(iPhone)
length(iPhone)


#Part 2:
dataPreprocessing <- function(array) {
  corpus <- Corpus(VectorSource(array))
  corpus <- tm_map(corpus, function(x) iconv(x, to='UTF8', sub='byte'))
  tm <- tm_map(corpus, function(x) iconv(x, to='ASCII', sub=' ')) # remove special characters
  tm <- tm_map(tm, removeNumbers) # remove numbers
  tm <- tm_map(tm, removePunctuation) # remove punctuation
  tm <- tm_map(tm, stripWhitespace) # remove whitespace
  tm <- tm_map(tm, tolower) # convert all to lowercase
  tm <- tm_map(tm, removeWords, stopwords()) # remove stopwords
  #tm <- tm_map(tm, stemDocument) # convert all words to their stems
  return(tm)
}


iPhone.tm <- dataPreprocessing(iPhone)
watch.tm <- dataPreprocessing(watch)
mac.tm <- dataPreprocessing(mac)


documentTermMatrix <- function(termMatrix) {
  dtm <- as.matrix(DocumentTermMatrix(termMatrix))
  empties <- which(rowSums(abs(dtm)) == 0)
  return(dtm[-empties,])
}

iPhone.dtm <- documentTermMatrix(iPhone.tm)
watch.dtm <- documentTermMatrix(watch.tm)
mac.dtm <- documentTermMatrix(mac.tm)



termDocumentMatrix <- function(termMatrix) {
  tdm <- as.matrix(TermDocumentMatrix(termMatrix))
  empties <- which(colSums(as.matrix(tdm)) == 0)
  return(as.matrix(tdm[,-empties]))
}

iPhone.tdm <- termDocumentMatrix(iPhone.tm)
watch.tdm <- termDocumentMatrix(watch.tm)
mac.tdm <- termDocumentMatrix(mac.tm)



#Part 3:
wordCloud <- function(tdm) {
  freqs = rowSums(tdm)
  freqs = freqs[!is.na(freqs)] # removal of words which have no frequency
  suppressWarnings( # supression of warnings
    wordcloud(names(freqs),
              freqs,
              random.order = FALSE, # plot words in decscending frequency
              rot.per = 0.35, # proportion words with 90 degree rotation
              colors = brewer.pal(8, "Dark2"), # coloring of words from least to most frequent
              max.words = 100, # plot 100 words
    )
  )
}

wordCloud(iPhone.tdm)

wordCloud(mac.tdm)

wordCloud(watch.tdm)


#This was the question I did in my group project
