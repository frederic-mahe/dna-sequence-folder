#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
   find the folding point in a duplex sequence
"""

__author__ = "Frédéric Mahé <frederic.mahe@cirad.fr>"
__date__ = "2023/12/28"
__version__ = "$Revision: 1.0"


import argparse
import copy
import sys
from itertools import product


def parse_arguments():
    """
    Sequence is mandatory, but can be empty. k-mer length is optional.
    """
    parser = argparse.ArgumentParser(
        description="find the folding point in a duplex sequence, or return 0"
    )

    parser.add_argument(
        "--sequence", type=str, required=True, help="Input sequence string"
    )

    parser.add_argument(
        "--kmer_length",
        type=int,
        choices=range(3, 9),
        default=5,
        help="Kmer length (3 to 8, default: 5)",
    )

    return parser.parse_args()


def is_not_valid_dna_sequence(sequence):
    valid_symbols = {"A", "C", "G", "T"}
    return not all(symbol in valid_symbols for symbol in sequence)


def checks(sequence, kmer_length):
    if len(sequence) < 2 * kmer_length:
        print("sequence is too short", file=sys.stderr)
        sys.exit(-1)
    if is_not_valid_dna_sequence(sequence):
        print("sequence contains undetermined symbols", file=sys.stderr)
        sys.exit(-1)


def generate_kmers(kmer_length):
    # Define the DNA alphabet
    alphabet = ["A", "C", "G", "T"]

    # Generate all possible k-mers of length kmer_length
    kmers = ["".join(p) for p in product(alphabet, repeat=kmer_length)]

    # Create a dictionary with k-mers as keys and initial count set to 0
    kmer_dict = {kmer: 0 for kmer in kmers}

    return kmer_dict


def count_kmers(kmer_list, kmer_dict, folding_point):
    for kmer in kmer_list[0:folding_point]:
        kmer_dict[kmer] += 1


def reset_dictionary_values(dictionary):
    for key in dictionary:
        dictionary[key] = 0


def extract_kmers(sequence, kmer_length):
    return [
        sequence[i : i + kmer_length] for i in range(len(sequence) - kmer_length + 1)
    ]


def reverse_complement(sequence):
    complement_dict = {"A": "T", "T": "A", "C": "G", "G": "C"}
    reverse_sequence = sequence[::-1]
    return "".join(complement_dict[base] for base in reverse_sequence)


def count_dict_differences(dict1, dict2):
    # both dictionaries have the same keys
    zipped_values = zip(dict1.values(), dict2.values())
    return sum(abs(val1 - val2) for val1, val2 in zipped_values)


def compute_dissimilarities(
    forward_kmers, forward_dict, reverse_kmers, reverse_dict, sequence_length
):
    dissimilarities = [0] * (sequence_length + 1)
    # dissimilarity for all possible folding points
    for folding_point in range(0, sequence_length + 1):
        count_kmers(forward_kmers, forward_dict, folding_point)
        count_kmers(reverse_kmers, reverse_dict, sequence_length - folding_point)
        dissimilarities[folding_point] = count_dict_differences(
            forward_dict, reverse_dict
        )
        reset_dictionary_values(forward_dict)
        reset_dictionary_values(reverse_dict)

    return dissimilarities


def find_the_best_folding_point(dissimilarities):
    # find the first minimal folding point
    lowest_dissimilarity = min(dissimilarities)
    first_occurrence = dissimilarities.index(lowest_dissimilarity)
    # find the middle of the plateau if there is one
    current_index = first_occurrence
    while dissimilarities[current_index] == lowest_dissimilarity:
        current_index += 1
    return first_occurrence + (current_index - first_occurrence) // 2


def main():
    # parse command line
    args = parse_arguments()

    # load and check values
    sequence = args.sequence
    kmer_length = args.kmer_length
    checks(sequence, kmer_length)

    # generate dictionaries
    forward_dict = generate_kmers(kmer_length)
    reverse_dict = copy.deepcopy(forward_dict)

    # extract kmers
    forward_kmers = extract_kmers(sequence, kmer_length)
    reverse_kmers = extract_kmers(reverse_complement(sequence), kmer_length)

    # compute dissimilarities for all possible folding points
    sequence_length = len(sequence)
    dissimilarities = compute_dissimilarities(
        forward_kmers, forward_dict, reverse_kmers, reverse_dict, sequence_length
    )
    print(dissimilarities, file=sys.stderr)

    print(find_the_best_folding_point(dissimilarities))

    return 0


if __name__ == "__main__":
    main()
