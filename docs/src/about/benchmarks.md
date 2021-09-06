# Benchmarks

Here is an overview of timings of some benchmarks to show how JuLie compares to other computer algebra systems. It's not meant to belittle anyone—but as one of the goals of JuLie is being fast, we need to verify that we're on track. All the timings are in seconds, short descriptions are given below, and you can find program files for the various systems in the [bench](https://github.com/ulthiel/JuLie.jl/tree/master/bench) directory of the JuLie repository. If you find a mistake, please message me.

| Benchmark             | JuLie | Sage | GAP  | Magma |
| --------------------- | ----- | ---- | ---- | ----- |
| Compositions      | 3.69 | 145  | 50.6 | —     |
| Partitions        | 4.13 | 185  | 50.7 | 32.9  |
| Semistandard tableaux | 4.08 | 233 | —    | —     |
| Standard tableaux | 3.00 | 385 | —    | —     |

## Descriptions

* Compositions: Creating the list of compositions of the integer 26. There are about 33.5 million.
* Partitions: Creating the list of partitions of the integer 90. There are about 56.6 million.
* Semistandard tableaux: Creating the list of semistandard tableaux of shape (6,3,2). There are about 2.5 million.
* Standard tableaux: Creating the list of standard tableaux of shape (10,8,3). There are about 1.5 million.

