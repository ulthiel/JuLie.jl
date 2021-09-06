# Benchmarks

Here is an overview of timings of some benchmarks to show how JuLie compares to other computer algebra systems. It's not meant to belittle anyone—but as one of the goals of JuLie is being fast, we need to verify that we're on track. All the timings are in seconds. You can find program files of the benchmarks for the various systems in the bench directory of the JuLie repository. If you find a mistake, please message me.

| Benchmark             | JuLie | Sage | GAP  | Magma |
| --------------------- | ----- | ---- | ---- | ----- |
| Compositions      | 4.89  | 145  | 50.6 | —     |
| Partitions        | 5.93  | 185  | 50.7 | 32.9  |
| Semistandard tableaux | 0.48  | 30.5 | —    | —     |
| Standard tableaux | 0.40  | 69   | —    | —     |

* Compositions: Creating the list of compositions of the integer 26. There are about 33.5 million. 
* Partitions: Creating the list of partitions of the integer 90. There are about 56.6 million.
* Semistandard tableaux: Creating the list of semistandard tableaux of shape (5,3,2). There are about 2.1 million.
* Standard tableaux: Creating the list of standard tableaux of shape (10,8,2). There are about 1.5 million.

