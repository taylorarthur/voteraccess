# Voter Access versus 2016 Democratic Primary Result
This is a demonstration project for an experimental visualization method 
I've been working on: 2-dimensional color mapping with colorplanes. The 
choropleth displays the 50 U.S states (and DC) ranked by two factors: ease of 
access to voting and the percentage of the vote (or equivalent for caucuses) 
that went to Senator Bernie Sanders whose primary opponent was Hillary Clinton.

The colorplane below the map explains the scale, colors further to the right, 
which have increasing amounts of blue,
indicate the state was ranked by RockTheVote.org as having better voting access.
Colors closer to the top, which have increasing red and decreasing green values,
indicate a larger share of the vote went to Bernie Sanders. 

This creates four quadrants of color to describe the states: 
red for low voter access states that went for Bernie, 
green for low voter access states that went for Hillary, fuschia for high voter
access states that went for Bernie, and blue for high voter access states that
went for Hillary. 

## Colorplanes
The purpose of the colorplane is to increase the dimensionality of a 
visualization by encoding two factors into a single color that can
be easily interpreted by the viewer. This is accomplished by projecting the
encoded values onto a plane of YUV color space with fixed luminosity. 

YUV color space was originally created with the advent of color television
broadcasting. To allow backwards compatibility, the luminosity (Y) component 
of the color, which is the only component of black and white signals, is 
kept separate, and all of the color information is encoded into two additional
channels (U & V). The result is that, for any fixed level of Y, the YUV color
space is a plane of 4 quadrants of red, fuschia, blue, and green (clockwise)
with smooth gradient transitions between. Within each quadrant, more intense
colors indicate values at the extremes and duller colors indicate values 
closer to the middle of the range. 
The four quadrants of color are
analogous to the 4 quadrants of a Cartesian coordinate system, and should
facilitate easy understanding of the meaning of each individual color used in 
the visualization. 

Unfortunately, differences in display monitors can impact the perception
of the colors and scale. Each of the four quadrants should be equal in size
and meet in the exact center of the colorplane, which is the midpoint of the
two numeric scales. However, one of my displays (a MS Surface 3) must be weak 
in its blue pixels because the colors appear to meet about 3/4 of the way
along the 
horizontal scale. 

## Voter Access
I am using scores from the Voter System Scorecard created by 
[RockTheVote.com](http://www.nonprofitvote.org/documents/2011/06/voting-system-scorecard.pdf). 
This scoring system focuses on ease of access to voting and scores states 
in three categories: voter registration, casting a ballot, and preparation 
for young voters. States score higher if voting is easier to access, and 
the score includes factors like same-day and online registration, early 
voting options, and civics education for high-schoolers. 

In the visualization, states in the blue, purple, and fuschia 
color ranges have easier access to voting while states colored red, brown, or green have poorer access. 

## Election Results
[Election results are scraped from Wikipedia](https://en.wikipedia.org/wiki/Democratic_Party_presidential_primaries,_2016) 
as of June 23rd, 2016 (California's totals are not yet final at this time). 
The metric displayed is the proportion of the vote (or equivalent measure for causes) received by Bernie Sanders. Sanders carried large wins in states 
colored red and fuschia while Hillary Clinton was the clear winner in states 
colored green, teal, or blue. 

## Interpretation
If voter access had a clear and consistent relationship with Sanders wins, 
the map would be only green and fuschia. In the converse were true, that
voter access strongly benefited Clinton, the map would have been all reds and blues. 

The result was instead a mix of colors, but there is a clear lack of 
bright blues. 
This indicates that Clinton did not have any big wins in states with good
voter access. Since there are both intense fuschias and reds, Sanders on the
other hand was 
able to achieve large victories in states with both high and low voter access 
scores. 

There are other confounding factors to consider before judging whether voter
access had an impact on the election results. Many of the low voter 
access states that Hillary won (green) are in the south. This region,
probably not by coincidence, is also home to the highest proportions of Black 
voters. Whether it was the voting access, the demographics, or some
other factor about the south that led to Hillary's wins is not determinable 
from this analysis. 

