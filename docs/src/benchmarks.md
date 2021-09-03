# Benchmarks

This is a logbook to keep track of the performance of JuLie compared to other computer algebra systems. It's not meant to belittle anyone—but as one of the goals of JuLie is to be fast, we need to verify that we're on the right track. In each section there's a description of a test (including a collapsible "Code" section containing the code used for the test) and a list of timings (on the same machine). If you find a mistake, please message me.

## Partitions

We create the full list (not an iterator) of the partitions of the integer 90 (there are about 56.6 million). It's a good test for "combinatorial speed" and memory efficiency. We cheat a little because we use 8-bit integers in Julia which saves memory—but since this is a feature of Julia, why not use it?

| JuLie | Sage | GAP  | Magma |
| ----- | ---- | ---- | ----- |
| 5.45  | 185  | 52.0 | 33.0  |

```@raw html
<details><summary>Code</summary>
<pre>
JuLie:
julia> @time L=partitions(Int8(90));

Sage:
sage: time L=Partitions(90).list()

GAP:
gap> L:=Partitions(90);; time/1000.0;

Magma:
> time L:=Partitions(90);
</pre>
</details>
```

## Compositions



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

