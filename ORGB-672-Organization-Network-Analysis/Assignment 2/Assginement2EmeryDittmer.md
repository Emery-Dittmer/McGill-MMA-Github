Assignment 2
================
Emery Dittmer
2023-03-09

# Excercise \#2

For this exercise we are investigating the idea of centrality in
networks. We will look at what seat or position that we should sit on
for the bus ride to Fakebook from downtown San Francisco! We can network
with the people in our immediate area but not outside of that.

## 1. Context & Modeling

### 1.1 Problem Description

For this problem, we will be a summer intern at Fakebook. This intern
takes a bus every morning from San Francisco to Menlo park. When he
boards the bus, there are 4 empty seats (labelled A-D). However, not all
of these seats are equal. Anyone on the bus can form connections with
their nearest neighbors who are in front, behind, to the side or
diagonal from each other. Our goal is to sit in the seat that is the
most advantageous to us. Let’s assume that seats with a lot of contact
or centrality will be the most advantageous. With this example, we will
examine network centrality to determine which seats have the most
prominent centrality. We have the following image to base our network
and centrality measures off of.

<center>

![Bus Network Illustartion.](Bus.png)

</center>

### 1.2 Assumptions

To simplify the problem, we will use several assumptions that are listed
here:<br> -1. We will use a grid to model this problem with 3 types of
seats: a. No Seat: defines a position on the bus that is not a seat. The
cabin for the driver or engine take up these spots. b. Occupied: a seat
that exists but is currently occupied c. Available: an available seat to
be sat in. These are the choice nodes we have. <br> -2. We will assume
that all the seats will be occupied. Therefore, we will set the weight
of each edge from available seats to 100%, even if the seat is currently
available. <br> -3. We will assume that the alley for walking that
divides the seats does not exist. We will not need to account for the
small extra distance between seats D and 6.

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.2 ──
    ## ✔ tibble  3.1.8     ✔ purrr   0.3.4
    ## ✔ tidyr   1.2.1     ✔ stringr 1.4.1
    ## ✔ readr   2.1.3     ✔ forcats 0.5.2
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()
    ## 
    ## Attaching package: 'igraph'
    ## 
    ## 
    ## The following objects are masked from 'package:purrr':
    ## 
    ##     compose, simplify
    ## 
    ## 
    ## The following object is masked from 'package:tidyr':
    ## 
    ##     crossing
    ## 
    ## 
    ## The following object is masked from 'package:tibble':
    ## 
    ##     as_data_frame
    ## 
    ## 
    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     as_data_frame, groups, union
    ## 
    ## 
    ## The following objects are masked from 'package:stats':
    ## 
    ##     decompose, spectrum
    ## 
    ## 
    ## The following object is masked from 'package:base':
    ## 
    ##     union
    ## 
    ## 
    ## 
    ## Attaching package: 'tidygraph'
    ## 
    ## 
    ## The following object is masked from 'package:igraph':
    ## 
    ##     groups
    ## 
    ## 
    ## The following object is masked from 'package:stats':
    ## 
    ##     filter

### 1.3 Data Collection: Making a bus coordinate system

No csv, or other data exists; however, based on the image above, we can
form a coordinate grid to model the bus. A 4x6 grid will model the bus
sufficiently for our purposes. However, some coordinates in this grid
are not actual seats; worse still, some are already occupied. To
correctly represent the situation, we need to label the seats and remove
unneeded seats. We will label the seats as either available, occupied or
no seat to differentiate the seats (nodes) within the bus (network).
Then we will remove the points that do not actually sit. Lastly, we will
index or create arbitrary seat ids for modelling purposes.

![](Assginement2EmeryDittmer_files/figure-gfm/Set%20coordinates-1.png)<!-- -->

Let’s take a look at our data!

![](Assginement2EmeryDittmer_files/figure-gfm/plot%20seats-1.png)<!-- -->

Looks like we have our bus, the seats available and taken! Now lets
filter our data frame to have only the useful coordinates, or seats that
exist.

let’s remove the seats that do not actually exist.

![](Assginement2EmeryDittmer_files/figure-gfm/plot%20seats%202-1.png)<!-- -->

We have a simplified coordinate system with the existing seats. We will
need all of this information to compute the degree of centrality for
each seat, which we can then filter out.

### 1.4 Transformations to Data

Centrality indicates the influence of a node in a network. Higher
centrality means higher influence. Therefore for this problem we would
want higher centrality. Special considerations and data transformation

### Distance Matrix Transformations

We will need to look at the distance between each seat to see which
seats can form connection with others. Ultimately we will find the most
central in our network.

<div id="ezlgcrhdtx" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#ezlgcrhdtx .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#ezlgcrhdtx .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#ezlgcrhdtx .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#ezlgcrhdtx .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#ezlgcrhdtx .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#ezlgcrhdtx .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ezlgcrhdtx .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#ezlgcrhdtx .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#ezlgcrhdtx .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#ezlgcrhdtx .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#ezlgcrhdtx .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#ezlgcrhdtx .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#ezlgcrhdtx .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#ezlgcrhdtx .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#ezlgcrhdtx .gt_from_md > :first-child {
  margin-top: 0;
}

#ezlgcrhdtx .gt_from_md > :last-child {
  margin-bottom: 0;
}

#ezlgcrhdtx .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#ezlgcrhdtx .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#ezlgcrhdtx .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#ezlgcrhdtx .gt_row_group_first td {
  border-top-width: 2px;
}

#ezlgcrhdtx .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#ezlgcrhdtx .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#ezlgcrhdtx .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#ezlgcrhdtx .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ezlgcrhdtx .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#ezlgcrhdtx .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#ezlgcrhdtx .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#ezlgcrhdtx .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ezlgcrhdtx .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#ezlgcrhdtx .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#ezlgcrhdtx .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#ezlgcrhdtx .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#ezlgcrhdtx .gt_left {
  text-align: left;
}

#ezlgcrhdtx .gt_center {
  text-align: center;
}

#ezlgcrhdtx .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#ezlgcrhdtx .gt_font_normal {
  font-weight: normal;
}

#ezlgcrhdtx .gt_font_bold {
  font-weight: bold;
}

#ezlgcrhdtx .gt_font_italic {
  font-style: italic;
}

#ezlgcrhdtx .gt_super {
  font-size: 65%;
}

#ezlgcrhdtx .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#ezlgcrhdtx .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#ezlgcrhdtx .gt_indent_1 {
  text-indent: 5px;
}

#ezlgcrhdtx .gt_indent_2 {
  text-indent: 10px;
}

#ezlgcrhdtx .gt_indent_3 {
  text-indent: 15px;
}

#ezlgcrhdtx .gt_indent_4 {
  text-indent: 20px;
}

#ezlgcrhdtx .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="1">1</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="2">2</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="3">3</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="4">4</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="5">5</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="6">6</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="7">7</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="8">8</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="9">9</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="10">10</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="1" class="gt_row gt_right">0.000000</td>
<td headers="2" class="gt_row gt_right">1.000000</td>
<td headers="3" class="gt_row gt_right">2.000000</td>
<td headers="4" class="gt_row gt_right">3.000000</td>
<td headers="5" class="gt_row gt_right">3.162278</td>
<td headers="6" class="gt_row gt_right">4.123106</td>
<td headers="7" class="gt_row gt_right">4.000000</td>
<td headers="8" class="gt_row gt_right">4.123106</td>
<td headers="9" class="gt_row gt_right">4.472136</td>
<td headers="10" class="gt_row gt_right">5.000000</td></tr>
    <tr><td headers="1" class="gt_row gt_right">1.000000</td>
<td headers="2" class="gt_row gt_right">0.000000</td>
<td headers="3" class="gt_row gt_right">1.000000</td>
<td headers="4" class="gt_row gt_right">2.000000</td>
<td headers="5" class="gt_row gt_right">2.236068</td>
<td headers="6" class="gt_row gt_right">3.162278</td>
<td headers="7" class="gt_row gt_right">3.000000</td>
<td headers="8" class="gt_row gt_right">3.162278</td>
<td headers="9" class="gt_row gt_right">3.605551</td>
<td headers="10" class="gt_row gt_right">4.000000</td></tr>
    <tr><td headers="1" class="gt_row gt_right">2.000000</td>
<td headers="2" class="gt_row gt_right">1.000000</td>
<td headers="3" class="gt_row gt_right">0.000000</td>
<td headers="4" class="gt_row gt_right">1.000000</td>
<td headers="5" class="gt_row gt_right">1.414214</td>
<td headers="6" class="gt_row gt_right">2.236068</td>
<td headers="7" class="gt_row gt_right">2.000000</td>
<td headers="8" class="gt_row gt_right">2.236068</td>
<td headers="9" class="gt_row gt_right">2.828427</td>
<td headers="10" class="gt_row gt_right">3.000000</td></tr>
    <tr><td headers="1" class="gt_row gt_right">3.000000</td>
<td headers="2" class="gt_row gt_right">2.000000</td>
<td headers="3" class="gt_row gt_right">1.000000</td>
<td headers="4" class="gt_row gt_right">0.000000</td>
<td headers="5" class="gt_row gt_right">1.000000</td>
<td headers="6" class="gt_row gt_right">1.414214</td>
<td headers="7" class="gt_row gt_right">1.000000</td>
<td headers="8" class="gt_row gt_right">1.414214</td>
<td headers="9" class="gt_row gt_right">2.236068</td>
<td headers="10" class="gt_row gt_right">2.000000</td></tr>
    <tr><td headers="1" class="gt_row gt_right">3.162278</td>
<td headers="2" class="gt_row gt_right">2.236068</td>
<td headers="3" class="gt_row gt_right">1.414214</td>
<td headers="4" class="gt_row gt_right">1.000000</td>
<td headers="5" class="gt_row gt_right">0.000000</td>
<td headers="6" class="gt_row gt_right">2.236068</td>
<td headers="7" class="gt_row gt_right">1.414214</td>
<td headers="8" class="gt_row gt_right">1.000000</td>
<td headers="9" class="gt_row gt_right">1.414214</td>
<td headers="10" class="gt_row gt_right">2.236068</td></tr>
    <tr><td headers="1" class="gt_row gt_right">4.123106</td>
<td headers="2" class="gt_row gt_right">3.162278</td>
<td headers="3" class="gt_row gt_right">2.236068</td>
<td headers="4" class="gt_row gt_right">1.414214</td>
<td headers="5" class="gt_row gt_right">2.236068</td>
<td headers="6" class="gt_row gt_right">0.000000</td>
<td headers="7" class="gt_row gt_right">1.000000</td>
<td headers="8" class="gt_row gt_right">2.000000</td>
<td headers="9" class="gt_row gt_right">3.000000</td>
<td headers="10" class="gt_row gt_right">1.414214</td></tr>
    <tr><td headers="1" class="gt_row gt_right">4.000000</td>
<td headers="2" class="gt_row gt_right">3.000000</td>
<td headers="3" class="gt_row gt_right">2.000000</td>
<td headers="4" class="gt_row gt_right">1.000000</td>
<td headers="5" class="gt_row gt_right">1.414214</td>
<td headers="6" class="gt_row gt_right">1.000000</td>
<td headers="7" class="gt_row gt_right">0.000000</td>
<td headers="8" class="gt_row gt_right">1.000000</td>
<td headers="9" class="gt_row gt_right">2.000000</td>
<td headers="10" class="gt_row gt_right">1.000000</td></tr>
    <tr><td headers="1" class="gt_row gt_right">4.123106</td>
<td headers="2" class="gt_row gt_right">3.162278</td>
<td headers="3" class="gt_row gt_right">2.236068</td>
<td headers="4" class="gt_row gt_right">1.414214</td>
<td headers="5" class="gt_row gt_right">1.000000</td>
<td headers="6" class="gt_row gt_right">2.000000</td>
<td headers="7" class="gt_row gt_right">1.000000</td>
<td headers="8" class="gt_row gt_right">0.000000</td>
<td headers="9" class="gt_row gt_right">1.000000</td>
<td headers="10" class="gt_row gt_right">1.414214</td></tr>
    <tr><td headers="1" class="gt_row gt_right">4.472136</td>
<td headers="2" class="gt_row gt_right">3.605551</td>
<td headers="3" class="gt_row gt_right">2.828427</td>
<td headers="4" class="gt_row gt_right">2.236068</td>
<td headers="5" class="gt_row gt_right">1.414214</td>
<td headers="6" class="gt_row gt_right">3.000000</td>
<td headers="7" class="gt_row gt_right">2.000000</td>
<td headers="8" class="gt_row gt_right">1.000000</td>
<td headers="9" class="gt_row gt_right">0.000000</td>
<td headers="10" class="gt_row gt_right">2.236068</td></tr>
    <tr><td headers="1" class="gt_row gt_right">5.000000</td>
<td headers="2" class="gt_row gt_right">4.000000</td>
<td headers="3" class="gt_row gt_right">3.000000</td>
<td headers="4" class="gt_row gt_right">2.000000</td>
<td headers="5" class="gt_row gt_right">2.236068</td>
<td headers="6" class="gt_row gt_right">1.414214</td>
<td headers="7" class="gt_row gt_right">1.000000</td>
<td headers="8" class="gt_row gt_right">1.414214</td>
<td headers="9" class="gt_row gt_right">2.236068</td>
<td headers="10" class="gt_row gt_right">0.000000</td></tr>
  </tbody>
  
  
</table>
</div>
<div id="zrwuzxqdkw" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#zrwuzxqdkw .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#zrwuzxqdkw .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#zrwuzxqdkw .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#zrwuzxqdkw .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#zrwuzxqdkw .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#zrwuzxqdkw .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#zrwuzxqdkw .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#zrwuzxqdkw .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#zrwuzxqdkw .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#zrwuzxqdkw .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#zrwuzxqdkw .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#zrwuzxqdkw .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#zrwuzxqdkw .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#zrwuzxqdkw .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#zrwuzxqdkw .gt_from_md > :first-child {
  margin-top: 0;
}

#zrwuzxqdkw .gt_from_md > :last-child {
  margin-bottom: 0;
}

#zrwuzxqdkw .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#zrwuzxqdkw .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#zrwuzxqdkw .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#zrwuzxqdkw .gt_row_group_first td {
  border-top-width: 2px;
}

#zrwuzxqdkw .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#zrwuzxqdkw .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#zrwuzxqdkw .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#zrwuzxqdkw .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#zrwuzxqdkw .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#zrwuzxqdkw .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#zrwuzxqdkw .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#zrwuzxqdkw .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#zrwuzxqdkw .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#zrwuzxqdkw .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#zrwuzxqdkw .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#zrwuzxqdkw .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#zrwuzxqdkw .gt_left {
  text-align: left;
}

#zrwuzxqdkw .gt_center {
  text-align: center;
}

#zrwuzxqdkw .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#zrwuzxqdkw .gt_font_normal {
  font-weight: normal;
}

#zrwuzxqdkw .gt_font_bold {
  font-weight: bold;
}

#zrwuzxqdkw .gt_font_italic {
  font-style: italic;
}

#zrwuzxqdkw .gt_super {
  font-size: 65%;
}

#zrwuzxqdkw .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#zrwuzxqdkw .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#zrwuzxqdkw .gt_indent_1 {
  text-indent: 5px;
}

#zrwuzxqdkw .gt_indent_2 {
  text-indent: 10px;
}

#zrwuzxqdkw .gt_indent_3 {
  text-indent: 15px;
}

#zrwuzxqdkw .gt_indent_4 {
  text-indent: 20px;
}

#zrwuzxqdkw .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="from_seat_id">from_seat_id</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="X">X</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Y">Y</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Status">Status</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="to_seat_id">to_seat_id</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Distance">Distance</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="from_seat_id" class="gt_row gt_right">1</td>
<td headers="X" class="gt_row gt_right">2</td>
<td headers="Y" class="gt_row gt_right">1</td>
<td headers="Status" class="gt_row gt_left">Occupied</td>
<td headers="to_seat_id" class="gt_row gt_right">2</td>
<td headers="Distance" class="gt_row gt_right">1.000000</td></tr>
    <tr><td headers="from_seat_id" class="gt_row gt_right">1</td>
<td headers="X" class="gt_row gt_right">2</td>
<td headers="Y" class="gt_row gt_right">1</td>
<td headers="Status" class="gt_row gt_left">Occupied</td>
<td headers="to_seat_id" class="gt_row gt_right">3</td>
<td headers="Distance" class="gt_row gt_right">2.000000</td></tr>
    <tr><td headers="from_seat_id" class="gt_row gt_right">1</td>
<td headers="X" class="gt_row gt_right">2</td>
<td headers="Y" class="gt_row gt_right">1</td>
<td headers="Status" class="gt_row gt_left">Occupied</td>
<td headers="to_seat_id" class="gt_row gt_right">4</td>
<td headers="Distance" class="gt_row gt_right">3.000000</td></tr>
    <tr><td headers="from_seat_id" class="gt_row gt_right">1</td>
<td headers="X" class="gt_row gt_right">2</td>
<td headers="Y" class="gt_row gt_right">1</td>
<td headers="Status" class="gt_row gt_left">Occupied</td>
<td headers="to_seat_id" class="gt_row gt_right">5</td>
<td headers="Distance" class="gt_row gt_right">3.162278</td></tr>
    <tr><td headers="from_seat_id" class="gt_row gt_right">1</td>
<td headers="X" class="gt_row gt_right">2</td>
<td headers="Y" class="gt_row gt_right">1</td>
<td headers="Status" class="gt_row gt_left">Occupied</td>
<td headers="to_seat_id" class="gt_row gt_right">6</td>
<td headers="Distance" class="gt_row gt_right">4.123106</td></tr>
    <tr><td headers="from_seat_id" class="gt_row gt_right">1</td>
<td headers="X" class="gt_row gt_right">2</td>
<td headers="Y" class="gt_row gt_right">1</td>
<td headers="Status" class="gt_row gt_left">Occupied</td>
<td headers="to_seat_id" class="gt_row gt_right">7</td>
<td headers="Distance" class="gt_row gt_right">4.000000</td></tr>
  </tbody>
  
  
</table>
</div>

This is just a sample, but the table overall contains all the distances
between seats.

Now we have the distance between each of the available seats and the
taken or occupied seats. We just need to apply the rules of connections
(diagonal, front,back, ect) and we will be able to summarize the table
to get the strength of each seat based on the connections. We will
filter all of the connections who are further than sqrt 2 away from the
current seat

<div id="nhtjyyvmjm" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#nhtjyyvmjm .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#nhtjyyvmjm .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#nhtjyyvmjm .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#nhtjyyvmjm .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#nhtjyyvmjm .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#nhtjyyvmjm .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#nhtjyyvmjm .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#nhtjyyvmjm .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#nhtjyyvmjm .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#nhtjyyvmjm .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#nhtjyyvmjm .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#nhtjyyvmjm .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#nhtjyyvmjm .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#nhtjyyvmjm .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#nhtjyyvmjm .gt_from_md > :first-child {
  margin-top: 0;
}

#nhtjyyvmjm .gt_from_md > :last-child {
  margin-bottom: 0;
}

#nhtjyyvmjm .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#nhtjyyvmjm .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#nhtjyyvmjm .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#nhtjyyvmjm .gt_row_group_first td {
  border-top-width: 2px;
}

#nhtjyyvmjm .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#nhtjyyvmjm .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#nhtjyyvmjm .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#nhtjyyvmjm .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#nhtjyyvmjm .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#nhtjyyvmjm .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#nhtjyyvmjm .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#nhtjyyvmjm .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#nhtjyyvmjm .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#nhtjyyvmjm .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#nhtjyyvmjm .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#nhtjyyvmjm .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#nhtjyyvmjm .gt_left {
  text-align: left;
}

#nhtjyyvmjm .gt_center {
  text-align: center;
}

#nhtjyyvmjm .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#nhtjyyvmjm .gt_font_normal {
  font-weight: normal;
}

#nhtjyyvmjm .gt_font_bold {
  font-weight: bold;
}

#nhtjyyvmjm .gt_font_italic {
  font-style: italic;
}

#nhtjyyvmjm .gt_super {
  font-size: 65%;
}

#nhtjyyvmjm .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#nhtjyyvmjm .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#nhtjyyvmjm .gt_indent_1 {
  text-indent: 5px;
}

#nhtjyyvmjm .gt_indent_2 {
  text-indent: 10px;
}

#nhtjyyvmjm .gt_indent_3 {
  text-indent: 15px;
}

#nhtjyyvmjm .gt_indent_4 {
  text-indent: 20px;
}

#nhtjyyvmjm .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="from">from</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="X">X</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Y">Y</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Status">Status</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="to">to</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Distance">Distance</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="from" class="gt_row gt_right">1</td>
<td headers="X" class="gt_row gt_right">2</td>
<td headers="Y" class="gt_row gt_right">1</td>
<td headers="Status" class="gt_row gt_left">Occupied</td>
<td headers="to" class="gt_row gt_right">2</td>
<td headers="Distance" class="gt_row gt_right">1</td></tr>
    <tr><td headers="from" class="gt_row gt_right">2</td>
<td headers="X" class="gt_row gt_right">2</td>
<td headers="Y" class="gt_row gt_right">2</td>
<td headers="Status" class="gt_row gt_left">Occupied</td>
<td headers="to" class="gt_row gt_right">1</td>
<td headers="Distance" class="gt_row gt_right">1</td></tr>
    <tr><td headers="from" class="gt_row gt_right">2</td>
<td headers="X" class="gt_row gt_right">2</td>
<td headers="Y" class="gt_row gt_right">2</td>
<td headers="Status" class="gt_row gt_left">Occupied</td>
<td headers="to" class="gt_row gt_right">3</td>
<td headers="Distance" class="gt_row gt_right">1</td></tr>
    <tr><td headers="from" class="gt_row gt_right">3</td>
<td headers="X" class="gt_row gt_right">2</td>
<td headers="Y" class="gt_row gt_right">3</td>
<td headers="Status" class="gt_row gt_left">Available</td>
<td headers="to" class="gt_row gt_right">2</td>
<td headers="Distance" class="gt_row gt_right">1</td></tr>
    <tr><td headers="from" class="gt_row gt_right">3</td>
<td headers="X" class="gt_row gt_right">2</td>
<td headers="Y" class="gt_row gt_right">3</td>
<td headers="Status" class="gt_row gt_left">Available</td>
<td headers="to" class="gt_row gt_right">4</td>
<td headers="Distance" class="gt_row gt_right">1</td></tr>
  </tbody>
  
  
</table>
</div>

Now we have the final distance tables. We can begin the transformation
of data to edges and nodes.

![](Assginement2EmeryDittmer_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

Now let’s try to find the measures for each seat \## 2. Centrality
Measures

### 2.1 Degree Centrality

The count of the number of links each node has to other nodes. For
instance, seat A(labelled as 3 above) has a degree centrality of 3 since
it is connected to 3 other nodes: 2, B & C (B labelled as 4 and C
labelled as 5 above)

<div id="tpvxfmdkll" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#tpvxfmdkll .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#tpvxfmdkll .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#tpvxfmdkll .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#tpvxfmdkll .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#tpvxfmdkll .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#tpvxfmdkll .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#tpvxfmdkll .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#tpvxfmdkll .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#tpvxfmdkll .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#tpvxfmdkll .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#tpvxfmdkll .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#tpvxfmdkll .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#tpvxfmdkll .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#tpvxfmdkll .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#tpvxfmdkll .gt_from_md > :first-child {
  margin-top: 0;
}

#tpvxfmdkll .gt_from_md > :last-child {
  margin-bottom: 0;
}

#tpvxfmdkll .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#tpvxfmdkll .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#tpvxfmdkll .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#tpvxfmdkll .gt_row_group_first td {
  border-top-width: 2px;
}

#tpvxfmdkll .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#tpvxfmdkll .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#tpvxfmdkll .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#tpvxfmdkll .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#tpvxfmdkll .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#tpvxfmdkll .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#tpvxfmdkll .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#tpvxfmdkll .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#tpvxfmdkll .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#tpvxfmdkll .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#tpvxfmdkll .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#tpvxfmdkll .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#tpvxfmdkll .gt_left {
  text-align: left;
}

#tpvxfmdkll .gt_center {
  text-align: center;
}

#tpvxfmdkll .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#tpvxfmdkll .gt_font_normal {
  font-weight: normal;
}

#tpvxfmdkll .gt_font_bold {
  font-weight: bold;
}

#tpvxfmdkll .gt_font_italic {
  font-style: italic;
}

#tpvxfmdkll .gt_super {
  font-size: 65%;
}

#tpvxfmdkll .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#tpvxfmdkll .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#tpvxfmdkll .gt_indent_1 {
  text-indent: 5px;
}

#tpvxfmdkll .gt_indent_2 {
  text-indent: 10px;
}

#tpvxfmdkll .gt_indent_3 {
  text-indent: 15px;
}

#tpvxfmdkll .gt_indent_4 {
  text-indent: 20px;
}

#tpvxfmdkll .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Seat">Seat</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Degree_Centrality">Degree_Centrality</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Seat" class="gt_row gt_left">B</td>
<td headers="Degree_Centrality" class="gt_row gt_right">5</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">C</td>
<td headers="Degree_Centrality" class="gt_row gt_right">5</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">D</td>
<td headers="Degree_Centrality" class="gt_row gt_right">5</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">A</td>
<td headers="Degree_Centrality" class="gt_row gt_right">3</td></tr>
  </tbody>
  
  
</table>
</div>

We can validate this with the igraph package wich has a built in
functionality for centrality degree

<div id="lxffthrcvx" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#lxffthrcvx .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#lxffthrcvx .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#lxffthrcvx .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#lxffthrcvx .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#lxffthrcvx .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#lxffthrcvx .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#lxffthrcvx .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#lxffthrcvx .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#lxffthrcvx .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#lxffthrcvx .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#lxffthrcvx .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#lxffthrcvx .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#lxffthrcvx .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#lxffthrcvx .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#lxffthrcvx .gt_from_md > :first-child {
  margin-top: 0;
}

#lxffthrcvx .gt_from_md > :last-child {
  margin-bottom: 0;
}

#lxffthrcvx .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#lxffthrcvx .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#lxffthrcvx .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#lxffthrcvx .gt_row_group_first td {
  border-top-width: 2px;
}

#lxffthrcvx .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#lxffthrcvx .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#lxffthrcvx .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#lxffthrcvx .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#lxffthrcvx .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#lxffthrcvx .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#lxffthrcvx .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#lxffthrcvx .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#lxffthrcvx .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#lxffthrcvx .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#lxffthrcvx .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#lxffthrcvx .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#lxffthrcvx .gt_left {
  text-align: left;
}

#lxffthrcvx .gt_center {
  text-align: center;
}

#lxffthrcvx .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#lxffthrcvx .gt_font_normal {
  font-weight: normal;
}

#lxffthrcvx .gt_font_bold {
  font-weight: bold;
}

#lxffthrcvx .gt_font_italic {
  font-style: italic;
}

#lxffthrcvx .gt_super {
  font-size: 65%;
}

#lxffthrcvx .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#lxffthrcvx .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#lxffthrcvx .gt_indent_1 {
  text-indent: 5px;
}

#lxffthrcvx .gt_indent_2 {
  text-indent: 10px;
}

#lxffthrcvx .gt_indent_3 {
  text-indent: 15px;
}

#lxffthrcvx .gt_indent_4 {
  text-indent: 20px;
}

#lxffthrcvx .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Seat">Seat</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Centrality_Degree">Centrality_Degree</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Seat" class="gt_row gt_left">B</td>
<td headers="Centrality_Degree" class="gt_row gt_right">5</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">C</td>
<td headers="Centrality_Degree" class="gt_row gt_right">5</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">D</td>
<td headers="Centrality_Degree" class="gt_row gt_right">5</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">A</td>
<td headers="Centrality_Degree" class="gt_row gt_right">3</td></tr>
  </tbody>
  
  
</table>
</div>

![](Assginement2EmeryDittmer_files/figure-gfm/degree%20central%20igraph-1.png)<!-- -->

There is agreement between our calculations and the calculations for the
package therefore we can use them!

### 2.2 Closeness centrality

    A measure that calculates the ability to spread information efficiently via the edges the node is connected to. It is calculated as the inverse of the average shortest path between nodes.

For instance, for node A (labelled 3), the closeness is
1/((1+2+1+1+2+2+2+2+3))=0.0625. The higher the number, the closer the
node is to the center based on distance. See appendix For details

<div id="prqjvskzpk" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#prqjvskzpk .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#prqjvskzpk .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#prqjvskzpk .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#prqjvskzpk .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#prqjvskzpk .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#prqjvskzpk .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#prqjvskzpk .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#prqjvskzpk .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#prqjvskzpk .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#prqjvskzpk .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#prqjvskzpk .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#prqjvskzpk .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#prqjvskzpk .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#prqjvskzpk .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#prqjvskzpk .gt_from_md > :first-child {
  margin-top: 0;
}

#prqjvskzpk .gt_from_md > :last-child {
  margin-bottom: 0;
}

#prqjvskzpk .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#prqjvskzpk .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#prqjvskzpk .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#prqjvskzpk .gt_row_group_first td {
  border-top-width: 2px;
}

#prqjvskzpk .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#prqjvskzpk .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#prqjvskzpk .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#prqjvskzpk .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#prqjvskzpk .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#prqjvskzpk .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#prqjvskzpk .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#prqjvskzpk .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#prqjvskzpk .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#prqjvskzpk .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#prqjvskzpk .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#prqjvskzpk .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#prqjvskzpk .gt_left {
  text-align: left;
}

#prqjvskzpk .gt_center {
  text-align: center;
}

#prqjvskzpk .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#prqjvskzpk .gt_font_normal {
  font-weight: normal;
}

#prqjvskzpk .gt_font_bold {
  font-weight: bold;
}

#prqjvskzpk .gt_font_italic {
  font-style: italic;
}

#prqjvskzpk .gt_super {
  font-size: 65%;
}

#prqjvskzpk .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#prqjvskzpk .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#prqjvskzpk .gt_indent_1 {
  text-indent: 5px;
}

#prqjvskzpk .gt_indent_2 {
  text-indent: 10px;
}

#prqjvskzpk .gt_indent_3 {
  text-indent: 15px;
}

#prqjvskzpk .gt_indent_4 {
  text-indent: 20px;
}

#prqjvskzpk .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Seat">Seat</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Closeness_Degree">Closeness_Degree</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Seat" class="gt_row gt_left">B</td>
<td headers="Closeness_Degree" class="gt_row gt_right">0.07142857</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">C</td>
<td headers="Closeness_Degree" class="gt_row gt_right">0.07142857</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">A</td>
<td headers="Closeness_Degree" class="gt_row gt_right">0.06250000</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">D</td>
<td headers="Closeness_Degree" class="gt_row gt_right">0.06250000</td></tr>
  </tbody>
  
  
</table>
</div>

![](Assginement2EmeryDittmer_files/figure-gfm/closeness%20centrality-1.png)<!-- -->

### 2.3 Betweenness centrality

A measure that detects a node’s influence over the flow of information
within a graph. This is the sum of the shortest paths between two points
i and j divided by the number of shortest paths that pass-through node
v.

<div id="ditkfsfqkp" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#ditkfsfqkp .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#ditkfsfqkp .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#ditkfsfqkp .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#ditkfsfqkp .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#ditkfsfqkp .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#ditkfsfqkp .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ditkfsfqkp .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#ditkfsfqkp .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#ditkfsfqkp .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#ditkfsfqkp .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#ditkfsfqkp .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#ditkfsfqkp .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#ditkfsfqkp .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#ditkfsfqkp .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#ditkfsfqkp .gt_from_md > :first-child {
  margin-top: 0;
}

#ditkfsfqkp .gt_from_md > :last-child {
  margin-bottom: 0;
}

#ditkfsfqkp .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#ditkfsfqkp .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#ditkfsfqkp .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#ditkfsfqkp .gt_row_group_first td {
  border-top-width: 2px;
}

#ditkfsfqkp .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#ditkfsfqkp .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#ditkfsfqkp .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#ditkfsfqkp .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ditkfsfqkp .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#ditkfsfqkp .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#ditkfsfqkp .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#ditkfsfqkp .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ditkfsfqkp .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#ditkfsfqkp .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#ditkfsfqkp .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#ditkfsfqkp .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#ditkfsfqkp .gt_left {
  text-align: left;
}

#ditkfsfqkp .gt_center {
  text-align: center;
}

#ditkfsfqkp .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#ditkfsfqkp .gt_font_normal {
  font-weight: normal;
}

#ditkfsfqkp .gt_font_bold {
  font-weight: bold;
}

#ditkfsfqkp .gt_font_italic {
  font-style: italic;
}

#ditkfsfqkp .gt_super {
  font-size: 65%;
}

#ditkfsfqkp .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#ditkfsfqkp .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#ditkfsfqkp .gt_indent_1 {
  text-indent: 5px;
}

#ditkfsfqkp .gt_indent_2 {
  text-indent: 10px;
}

#ditkfsfqkp .gt_indent_3 {
  text-indent: 15px;
}

#ditkfsfqkp .gt_indent_4 {
  text-indent: 20px;
}

#ditkfsfqkp .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Seat">Seat</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Betweenness_Degree">Betweenness_Degree</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Seat" class="gt_row gt_left">A</td>
<td headers="Betweenness_Degree" class="gt_row gt_right">14.000000</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">B</td>
<td headers="Betweenness_Degree" class="gt_row gt_right">9.033333</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">C</td>
<td headers="Betweenness_Degree" class="gt_row gt_right">8.600000</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">D</td>
<td headers="Betweenness_Degree" class="gt_row gt_right">3.266667</td></tr>
  </tbody>
  
  
</table>
</div>

![](Assginement2EmeryDittmer_files/figure-gfm/betweeness%20centrality-1.png)<!-- -->

### Comparison between all 3!

Let’s compare the centrality of all 3 measures

<div id="lnpnekkhxb" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#lnpnekkhxb .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#lnpnekkhxb .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#lnpnekkhxb .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#lnpnekkhxb .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#lnpnekkhxb .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#lnpnekkhxb .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#lnpnekkhxb .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#lnpnekkhxb .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#lnpnekkhxb .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#lnpnekkhxb .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#lnpnekkhxb .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#lnpnekkhxb .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#lnpnekkhxb .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#lnpnekkhxb .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#lnpnekkhxb .gt_from_md > :first-child {
  margin-top: 0;
}

#lnpnekkhxb .gt_from_md > :last-child {
  margin-bottom: 0;
}

#lnpnekkhxb .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#lnpnekkhxb .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#lnpnekkhxb .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#lnpnekkhxb .gt_row_group_first td {
  border-top-width: 2px;
}

#lnpnekkhxb .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#lnpnekkhxb .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#lnpnekkhxb .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#lnpnekkhxb .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#lnpnekkhxb .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#lnpnekkhxb .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#lnpnekkhxb .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#lnpnekkhxb .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#lnpnekkhxb .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#lnpnekkhxb .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#lnpnekkhxb .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#lnpnekkhxb .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#lnpnekkhxb .gt_left {
  text-align: left;
}

#lnpnekkhxb .gt_center {
  text-align: center;
}

#lnpnekkhxb .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#lnpnekkhxb .gt_font_normal {
  font-weight: normal;
}

#lnpnekkhxb .gt_font_bold {
  font-weight: bold;
}

#lnpnekkhxb .gt_font_italic {
  font-style: italic;
}

#lnpnekkhxb .gt_super {
  font-size: 65%;
}

#lnpnekkhxb .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#lnpnekkhxb .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#lnpnekkhxb .gt_indent_1 {
  text-indent: 5px;
}

#lnpnekkhxb .gt_indent_2 {
  text-indent: 10px;
}

#lnpnekkhxb .gt_indent_3 {
  text-indent: 15px;
}

#lnpnekkhxb .gt_indent_4 {
  text-indent: 20px;
}

#lnpnekkhxb .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Seat">Seat</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Centrality_Degree">Centrality_Degree</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Closeness_Degree">Closeness_Degree</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Betweenness_Degree">Betweenness_Degree</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Seat" class="gt_row gt_left">B</td>
<td headers="Centrality_Degree" class="gt_row gt_right">5</td>
<td headers="Closeness_Degree" class="gt_row gt_right">0.07142857</td>
<td headers="Betweenness_Degree" class="gt_row gt_right">9.033333</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">C</td>
<td headers="Centrality_Degree" class="gt_row gt_right">5</td>
<td headers="Closeness_Degree" class="gt_row gt_right">0.07142857</td>
<td headers="Betweenness_Degree" class="gt_row gt_right">8.600000</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">D</td>
<td headers="Centrality_Degree" class="gt_row gt_right">5</td>
<td headers="Closeness_Degree" class="gt_row gt_right">0.06250000</td>
<td headers="Betweenness_Degree" class="gt_row gt_right">3.266667</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">A</td>
<td headers="Centrality_Degree" class="gt_row gt_right">3</td>
<td headers="Closeness_Degree" class="gt_row gt_right">0.06250000</td>
<td headers="Betweenness_Degree" class="gt_row gt_right">14.000000</td></tr>
  </tbody>
  
  
</table>
</div>

It looks like Seat B may be the best

<div id="bptsfuexgk" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#bptsfuexgk .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#bptsfuexgk .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#bptsfuexgk .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#bptsfuexgk .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#bptsfuexgk .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#bptsfuexgk .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#bptsfuexgk .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#bptsfuexgk .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#bptsfuexgk .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#bptsfuexgk .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#bptsfuexgk .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#bptsfuexgk .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#bptsfuexgk .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#bptsfuexgk .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#bptsfuexgk .gt_from_md > :first-child {
  margin-top: 0;
}

#bptsfuexgk .gt_from_md > :last-child {
  margin-bottom: 0;
}

#bptsfuexgk .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#bptsfuexgk .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#bptsfuexgk .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#bptsfuexgk .gt_row_group_first td {
  border-top-width: 2px;
}

#bptsfuexgk .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#bptsfuexgk .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#bptsfuexgk .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#bptsfuexgk .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#bptsfuexgk .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#bptsfuexgk .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#bptsfuexgk .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#bptsfuexgk .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#bptsfuexgk .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#bptsfuexgk .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#bptsfuexgk .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#bptsfuexgk .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#bptsfuexgk .gt_left {
  text-align: left;
}

#bptsfuexgk .gt_center {
  text-align: center;
}

#bptsfuexgk .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#bptsfuexgk .gt_font_normal {
  font-weight: normal;
}

#bptsfuexgk .gt_font_bold {
  font-weight: bold;
}

#bptsfuexgk .gt_font_italic {
  font-style: italic;
}

#bptsfuexgk .gt_super {
  font-size: 65%;
}

#bptsfuexgk .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#bptsfuexgk .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#bptsfuexgk .gt_indent_1 {
  text-indent: 5px;
}

#bptsfuexgk .gt_indent_2 {
  text-indent: 10px;
}

#bptsfuexgk .gt_indent_3 {
  text-indent: 15px;
}

#bptsfuexgk .gt_indent_4 {
  text-indent: 20px;
}

#bptsfuexgk .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Seat">Seat</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Centrality_Degree">Centrality_Degree</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Closeness_Degree">Closeness_Degree</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="Betweenness_Degree">Betweenness_Degree</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Seat" class="gt_row gt_left" style="background-color: rgba(128,188,216,0.8); color: #000000; font-weight: normal;">B</td>
<td headers="Centrality_Degree" class="gt_row gt_right" style="background-color: rgba(128,188,216,0.8); color: #000000; font-weight: normal;">5</td>
<td headers="Closeness_Degree" class="gt_row gt_right" style="background-color: rgba(128,188,216,0.8); color: #000000; font-weight: normal;">0.07142857</td>
<td headers="Betweenness_Degree" class="gt_row gt_right" style="background-color: rgba(128,188,216,0.8); color: #000000; font-weight: normal;">9.033333</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">C</td>
<td headers="Centrality_Degree" class="gt_row gt_right">5</td>
<td headers="Closeness_Degree" class="gt_row gt_right">0.07142857</td>
<td headers="Betweenness_Degree" class="gt_row gt_right">8.600000</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">D</td>
<td headers="Centrality_Degree" class="gt_row gt_right">5</td>
<td headers="Closeness_Degree" class="gt_row gt_right">0.06250000</td>
<td headers="Betweenness_Degree" class="gt_row gt_right">3.266667</td></tr>
    <tr><td headers="Seat" class="gt_row gt_left">A</td>
<td headers="Centrality_Degree" class="gt_row gt_right">3</td>
<td headers="Closeness_Degree" class="gt_row gt_right">0.06250000</td>
<td headers="Betweenness_Degree" class="gt_row gt_right">14.000000</td></tr>
  </tbody>
  
  
</table>
</div>

## 3.Discussion

While we have measured each seat’s centrality and plotted the network
diagram, we need to consider the consequences of the seat choice. The
primary goal is to leverage this opportunity to form connections. The
connections will likely become valuable when looking for future
employment, future progression or to have a colleague/friend you can
rely on. We will aim to pick a seat that has connections with people. A
seat without any links isolates us and removes us from the network. The
potential consequences of the seat selection are a network size that may
be smaller or larger, a potential utility within the network (conveyor
of information) and recognition. In other words, if a seat has more
connections, your possible network is larger than other seats. If your
seat is between two friends, you will be in the middle of their
conversation or convey information and thus become associated with the
network. For instance, seat 3 in the problem has side to side connection
with seat D and 4, whereas seat 4 is only connected to seat 3 From this
perspective, there are two intuitive solutions: create the most
significant number of relationships or create a few strong connections.
These two perspectives are equally valid. We can be in a seat with the
greatest number of connections, thereby becoming friendly with many
people or choose a specific seat that allows us to make fewer
connections. The benefit of picking a seat with fewer connections is
that you grow the strength of your network. A strong network gives you
access to a more intimate side of friends, who can help with roles,
advocate for you or serve as mentors. From a growth perspective, these
are valuable people in a network and are likely to help grow a network.
The tradeoff of a smaller network is that while your connections may be
strong, there are fewer of them, and your network will be smaller. A
larger network of “weak” connections is a tradeoff. Implicitly strong
connections sound more desirable, but counterintuitively weak ties have
more power for securing future roles, according to David Easley and Jon
Kleinberg. We can borrow from the circles of knowledge and boundary of
ignorance to explain this. As the circle of friends grows so does the
boundary of friendship (friends of friends); assuming little overlap
adding additional friends gives you access to a much larger network.

<center>

![circle of knowledge and boundry of ignorance.](Knowledge.png)

</center>
<center>

![Growth of network illustration](Growth.png)

</center>

Therefore, based on the goal and the available seats, the best seat to
take for this bus ride will be the one that maximizes the number of
connections. Based on the centrality scores, seat B is the best seat to
take. This seat is the most connected based on degree centrality and has
a good balance of closeness and betweenness centrality. In this case,
betweenness and connectedness centrality are not as important as degree
centrality, as forming connections relies more on physical distance as
represented by degree centrality. This, however, relies on the
assumption that seats D, C and A are filled. If this assumption does not
hold, then seat D is the best to pick.

## 4. Final Visulizations

Finally, we can visualize all nodes in the network with their respective
labels and centrality degrees.

![](Assginement2EmeryDittmer_files/figure-gfm/visnetwork%20final%20network-1.png)<!-- -->

<!-- ```{r comparison table rows} -->
<!-- fulltable=rbind(degree_table,setNames(closeness_table, names(degree_table)),setNames(betweeness_table, names(degree_table))) -->
<!-- gtTable = gt(fulltable) %>% -->
<!--   tab_row_group( -->
<!--     label = "Centrality Degree", -->
<!--     rows = 1:4 -->
<!--   ) %>%  -->
<!--   tab_row_group( -->
<!--     label = "Closesness", -->
<!--     rows = 5:8 -->
<!--   )%>%  -->
<!--   tab_row_group( -->
<!--     label = "Betweeness", -->
<!--     rows = 9:12 -->
<!--   ) -->
<!-- gtTable -->
<!-- ``` -->
