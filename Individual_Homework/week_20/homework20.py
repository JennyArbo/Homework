#!/usr/bin/env python
import sys

from nltk.tokenize.regexp import WordPunctTokenizer

filename = sys.argv[1]

with open(filename, 'r') as f:
    contents = f.read()

from nltk.tokenize import wordpunct_tokenize
wptk = WordPunctTokenizer()
tokenized = wptk.tokenize(contents)

lower_list = []
for word in tokenized:
    l = word.lower()
    lower_list.append(l)

from collections import Counter
counts = Counter(lower_list)
#counts_list = sorted(lower_list, key=lambda x: (counts[x], x), reverse=True)

print(counts)
