#!/usr/bin/python

import sys
import subprocess
import os

THRESHOLD_AVAIL = 90
suffixes = ['K', 'M', 'G', 'T', 'P']
def humansize(nbytes, base=1024):
    i = 0
    while (nbytes >= base) and (i < len(suffixes)-1):
        nbytes /= float(base)
        i += 1
    f = ('%.2f' % nbytes).rstrip('0').rstrip('.')
    return '%s %s' % (f, suffixes[i])


def show(occupied, available, limit, prefix="", suffix="", size=100):
    x = int(size*occupied/available)
    if occupied > available:
        color = "\033[0;31m"
    elif x > THRESHOLD_AVAIL:
        color = "\033[0;33m"
    else:
        color = "\033[0;32m"
    print("{} [{}{}{}\033[1;0m] {}{}\033[1;0m/{}/{} {}".format(prefix, color, u"█"*x, " "*(size-x),
                                                               color, humansize(occupied), humansize(available), humansize(limit),
                                                               suffix),
          end='\n', file=sys.stdout, flush=True)

# Run the coda and retrieve the values
result = subprocess.run(['quota', '-u', os.getlogin()], stdout=subprocess.PIPE)
result = result.stdout.decode('utf-8').split("\n")

# Dealing with device
dev = result[2]

# Dealing with bar now
result = result[3].strip().split()
occupied = int(result[0])
available = int(result[1])
limit = int(result[2])
nb_files = int(result[3])

print("### Your quotas")
print("")
show(occupied, available, limit, prefix=dev, suffix=f"(nb_files = {humansize(nb_files, 1000)})")
