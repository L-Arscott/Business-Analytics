<br>

$$
\Huge\text{\textbf{Investigating late payments}}
$$

<br>
<br>

Our company is currently expecting payment on around 250 contracts, at an average value of 180 000 ARR. This motivates the topic of this article: factors behind payments to our company being made late.
<br>
<br>

## When do we usually get paid ? What shall we consider "late" ?
Payments made to our company are completed at an average of around 3 months after closing of contract. We have seen a healthy majority ( $\sim$ 85\%) of payments completed between 2 months and 4 months after contract closing. Throughout this article, we will consider a payment made later than 120 days (or around the 4 month mark) after closing to be **late**. This concerns around 1 in 10 of our contracts closed since 2013.
<br>
<br>

## Trouble with large contracts ?
We start by investigating the size of late contracts. The bars below represent the average size of *late* contracts (in thousands of ARR) by region for the year 2018. For comparison, the average size among *all* contracts in each region for the same year has been drawn on with dotted lines.

<p align="center">
  <img src="https://github.com/L-Arscott/Business-Analytics/assets/64332150/02f7ee0d-cfce-41a2-83fe-e305f8eb7fc0" height="300"/>
</p>


Late payments typically involved larger contracts across all regions. The average late payment across all regions involved a contract around 30\% larger than average, and even reached around double the typical size in Latin America.

These figures aren't typical however: late contracts were only around 10\% larger in both 2016 and 2017. Although evidence suggests larger contracts tend to be paid later, further information is required to determine just how strong a factor contract size will be in a given economic climate.
<br>
<br>

## Too many cooks ?
The graph below shows that, as we restrict our attention to later and later contracts, higher and higher rates of these contracts involve a vendor partner. Although just 23\% of sales are made via a partner, this figure rises to 30\% among the top latest half of contracts: those settled later than a typical figure of 90 days. Late contracts (those settled after more than 120 days) have around double the expected partner involvement, at 45\%.

<p align="center">
  <img src="https://github.com/L-Arscott/Business-Analytics/assets/64332150/24731cad-b8f9-4e51-8c69-2b47bbf6f62d" height="300"/>
</p>


It seems partners are involved in later contracts.  
A possible explanation for this pattern could be that partners are simply involved in larger contracts. As we saw earlier, these typically involved later payments. However, I have found no evidence to suggest the contracts partners are involved in are any larger. Hence contract size and partner involvement appear to be two separate factors behind late payments.
<br>
<br>

## Is loyalty rewarded ?
Do returning customers show greater respect ? Brief analysis suggests so ! Below is the mean payment delay depending on how many times customers have dealt with us.

<p align="center">
  <img src="https://github.com/L-Arscott/Business-Analytics/assets/64332150/bcb46b91-7804-403c-9201-2ca3dfadfb03" height="300"/>
</p>

Each subsequent visit seems to knock approximately a day and a half off payment delay, with payments being made a week earlier by the 5th interaction. (Note the y axis starts at 80 when interpreting the graph). We must be careful with how far we extrapolate this data: if we extrapolate to the 100th visit, the model suggests our clients will be paying us 50 days before the deal is closed, absurd.
<br>
<br>

## Putting everything together: Logistic Regression
Below is the result of feeding our data into a logistic regression model. Logistic regression is about predicting the answer to a "Yes" or "No" question (in our case, "Will payment be late ?") based on information we call "features".


<p align="center">
  <img src="https://github.com/L-Arscott/Business-Analytics/assets/64332150/9054b3dc-621f-4dde-bc7f-083cd818743a" height="200"/>
</p>


On the left hand side are features that might be relevant, such as contract size. The algorithm has marked those it found to be relevant with stars on the right hand side. Notice the algorithm agrees we ought to look at size, partner involvement and repeat customers. It also points to trends tied to the region our customer is based in. The set of "NA" results for Latin America is an interesting quirk, feel free to contact me for an explanation !
