# dna-sequence-folder

Given a 'duplex' DNA sequence, find a potential folding point.

A 'duplex' sequence, is a sequence made of two consecutive parts, were
the second part is a reverse-complement copy of the first. The second
part can contain errors, and can be shorter or longer than the first
part (up to a certain amount).

The folding point is the last position in the first part, after which
the second part starts.

The python script `find_folding_point.py` uses *k*-mer counts to try
to find the folding point in a given sequence. It returns a positive
integer value representing a possible folding point position, or zero
if nothing is found.


## roadmap

- [x] first draft,
- [x] record all dissimilarities,
- [x] iterate to find the best folding point,
- [ ] compute a Simple Moving Average (window size = 3),
- [ ] larger window means smoother average,
- [ ] add metadata, version number,
- [ ] draw an example for the README,
- [ ] write tests:
  - [x] sequence too short,
  - [x] invalid sequence,
  - [x] perfect case (1/2),
  - [x] skewed cases (1/4, 3/4),
  - [x] false-positive case,
  - [ ] cases with mutations,
  - [ ] cases with a folding plateau,
  - [ ] cases with two folding points
- [ ] add a minimal threshold based on the number of shared kmers
      divided by the length of the longest part?
