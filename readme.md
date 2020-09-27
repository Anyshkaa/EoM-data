# Instruction

- playground single is a demonstration of the procedure on a single participant
- playground multiple demonstrate loading for all participants 
- functions contain processes to preprocess participants, so that it doesn't happen in a script

required packages

```
library(tidyverse)
library(jsonlite)
```

# Requirements
Data are expected to be in the data/[participant] folders in raw (non .rar) format. The unpack-data.bat can do that automatically, but it needs *7z* to be installed on the pc and runs only on Windows