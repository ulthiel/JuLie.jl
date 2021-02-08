# Benchmarks

All benchmarks were performed on an Intel(R) Core(TM) i5-8600 CPU @ 3.10GHz, all timings are in seconds. The commands are given as footnotes. If you find a mistake, please send me a message.

| Function               | JuLie      | Sage     | GAP | Magma |
|:---------------------- | ---------- | -------- | ----- | ----- |
| catalan(2^20)          | 0.02[^1]   | 22.1[^2] | —     | 1.72[^3] |
| compositions(26)       | 4.98[^4] | 154[^5] | 49.7[^6] | — |
| partitions(90)   | 5.45[^7] | 185[^8] | 52.0[^9] | 33.0[^10]   |
| semistandard_tableaux([5,3,2]) | 0.88[^11] | 30.8[^12] | — | — |

[^1]: ```@time catalan(2^20)```
[^2]: ```time X=catalan_number(2^20)```
[^3]: ```time X:=Catalan(2^20);```
[^4]: ```@time compositions(Int8(26));```
[^5]: ```time X=Compositions(26).list()```
[^6]: ```L:=OrderedPartitions(26);; time/1000.0;```
[^7]: ```@time partitions(Int8(90));```
[^8]:```time X=Partitions(90).list()```
[^9]: ```L:=Partitions(90);; time/1000.0;```
[^10]: ```time X:=Partitions(90);```
[^11]: ``` @time semistandard_tableaux([5,3,2]);```
[^12]: ```time X=SemistandardTableaux([5,3,2]).list()```

