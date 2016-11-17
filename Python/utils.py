def table(vector_input, ordered=True, numeric=False):
    # return list of tuples consisting of: 
    #
    #   (distinct elements in vector_input, number of occurrences in vector_input) 
    #
    from collections import Counter
    def num(val):
        try:
            return int(float(val))
        except ValueError:
            return 0
    if numeric:
        vector = [num(v) for v in vector_input]
    else:
        vector = vector_input
    freq = Counter(vector)
    data = []
    for item in set(vector):
        data.append((item, freq[item]))
    # sort by most frequent
    if (ordered):
        data = sorted(data, key=lambda item: item[1], reverse=True)
    return data
