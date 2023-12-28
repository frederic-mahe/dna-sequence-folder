#!/bin/bash

## Print a header
SCRIPT_NAME="test find folding point"
line=$(printf "%076s\n" | tr " " "-")
printf "# %s %s\n" "${line:${#SCRIPT_NAME}}" "${SCRIPT_NAME}"

## Declare a color code for test results
RED="\033[1;31m"
GREEN="\033[1;32m"
NO_COLOR="\033[0m"

failure () {
    printf "${RED}FAIL${NO_COLOR}: ${1}\n"
    exit 1
}

success () {
    printf "${GREEN}PASS${NO_COLOR}: ${1}\n"
}

SCRIPT="find_folding_point.py"
FOLDER="../src/"

DESCRIPTION="check if file is present and not empty"
[[ -s "${FOLDER}${SCRIPT}" ]] && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="executes"
python3 ${FOLDER}${SCRIPT} \
        --help > /dev/null && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="requires a sequence argument"
python3 ${FOLDER}${SCRIPT} > /dev/null 2>&1 && \
    failure "${DESCRIPTION}" || \
        success "${DESCRIPTION}"

DESCRIPTION="accepts a sequence"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAAGGGGG > /dev/null 2>&1 && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="rejects a sequence shorter than 2 x kmer length"
python3 ${FOLDER}${SCRIPT} \
        --sequence AA > /dev/null 2>&1 && \
    failure "${DESCRIPTION}" || \
        success "${DESCRIPTION}"

DESCRIPTION="default kmer length is 5 (accept sequence >= 10)"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAAGGGGG > /dev/null 2>&1 && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="default kmer length is 5 (rejects sequence < 10)"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAAGGGG > /dev/null 2>&1 && \
    failure "${DESCRIPTION}" || \
        success "${DESCRIPTION}"

DESCRIPTION="kmer length can be specified"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAAGGGGG \
        --kmer_length 5 \
        > /dev/null 2>&1 && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="kmer length can be modified"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAGGGG \
        --kmer_length 4 \
        > /dev/null 2>&1 && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="kmer length can be set to 3"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAGGG \
        --kmer_length 3 \
        > /dev/null 2>&1 && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="kmer length can be set to 4"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAGGGG \
        --kmer_length 4 \
        > /dev/null 2>&1 && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="kmer length can be set to 5"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAAGGGGG \
        --kmer_length 5 \
        > /dev/null 2>&1 && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="kmer length can be set to 6"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAAAGGGGGG \
        --kmer_length 6 \
        > /dev/null 2>&1 && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="kmer length can be set to 7"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAAAAGGGGGGG \
        --kmer_length 7 \
        > /dev/null 2>&1 && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="kmer length can be set to 8"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAAAAAGGGGGGGG \
        --kmer_length 8 \
        > /dev/null 2>&1 && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="kmer length cannot be lower than 3"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAGGG \
        --kmer_length 2 \
        > /dev/null 2>&1 && \
    failure "${DESCRIPTION}" || \
        success "${DESCRIPTION}"

DESCRIPTION="kmer length cannot be higher than 8"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAAAAAAGGGGGGGGG \
        --kmer_length 9 \
        > /dev/null 2>&1 && \
    failure "${DESCRIPTION}" || \
        success "${DESCRIPTION}"

DESCRIPTION="rejects sequences with alternative symbols"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAAGGGGN \
        > /dev/null 2>&1 && \
    failure "${DESCRIPTION}" || \
        success "${DESCRIPTION}"

DESCRIPTION="always returns a position value (positive integer)"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAAGGGGG 2> /dev/null | \
    grep -qw "[0-9]" && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="returns zero if there is no folding point (no overlap)"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAAGGGGG 2> /dev/null | \
    grep -qw "0" && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="finds a folding point (shortest perfect case)"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAATTTTT 2> /dev/null | \
    grep -qw "5" && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="finds a folding point (perfect case 1/2)"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAAAAAAATTTTTTTTTT 2> /dev/null | \
    grep -qw "10" && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="finds a folding point (skewed case 3/4)"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAAAAAAAAAAAATTTTT 2> /dev/null | \
    grep -qw "15" && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"

DESCRIPTION="finds a folding point (skewed case 1/4)"
python3 ${FOLDER}${SCRIPT} \
        --sequence AAAAATTTTTTTTTTTTTTT 2> /dev/null | \
    grep -qw "5" && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"


## false positive: worst-case scenario
## de Bruijn sequences (shortest possible sequences containing all
## possible 3-mers, repeated only once). Here s1 and s2 are different
## 66-nt long de Bruijn sequences containing the exact same list of
## 3-mers. So, their k-mer profiles are exactly the same (except for
## four 3-mers in the contact zone)
s1="AAACAAGAATACCACGACTAGCAGGAGTATCATGATTCCCGCCTCGGCGTCTGCTTGGGTGTTTAA"
s2="GGGTGGCGGAGTTGTCGTAGCTGCCGCAGATGACGAATTTCTTATCCTCATACTAACCCACAAAGG"
DESCRIPTION="finds a folding point (de Bruijn false-positives)"
python3 ${FOLDER}${SCRIPT} \
        --sequence ${s1}${s2} \
        --kmer_length 3 \
        2> /dev/null | \
    grep -qw "64" && \
    success "${DESCRIPTION}" || \
        failure "${DESCRIPTION}"


exit 0
