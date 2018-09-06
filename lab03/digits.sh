#!/bin/bash
# Reads from stdin and writes to stdout
# Mapping all digit chars whos values that are lt 5 into the '<' character
# and all digits gt 5 into the '>' char.
# Digit 5 is left unchanged

tr '01234' '<' | tr '6789' '>' 
