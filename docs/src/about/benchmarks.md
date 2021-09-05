# Benchmarks

This is a logbook to keep track of the performance of JuLie compared to other computer algebra systems. It's not meant to belittle anyone—but as one of the goals of JuLie is being fast, we need to verify that we're on the right track. In each section there's a description of a benchmark—including a collapsible "Code" block containing the code run by the benchmark—and a list of timings (for each benchmark determined on the same machine). If you find a mistake, please message me.

## Combinatorics

### Partitions

We create the full list (not an iterator) of the partitions of the integer 90 (there are about 56.6 million). It's a good test for "combinatorial speed" and memory efficiency. We cheat a little because we use 8-bit integers in Julia which saves memory—but since this is a feature of Julia, why not use it? I want to note that Magma becomes basically unusable afterwards, even a simple ```2+2;``` takes a while to display.

| JuLie | Sage | GAP  | Magma |
| ----- | ---- | ---- | ----- |
| 5.93  | 185  | 50.7 | 32.9  |

```@raw html
<details><summary>Code</summary>
<pre>
#JuLie
@time L=partitions(Int8(90));
  5.928412 seconds (56.63 M allocations: 6.239 GiB, 19.87% gc time)

#Sage
time L=Partitions(90).list()
CPU times: user 3min, sys: 4.68 s, total: 3min 5s
Wall time: 3min 5s

#GAP
L:=Partitions(90);; time/1000.0;

//Magma
time L:=Partitions(90);
</pre>
</details>
```

### Compositions

Similar to the partitions benchmark, we create the full list of all compositions of the integer 26 (there are about 33.5 million).

| JuLie | Sage | GAP  | Magma |
| ----- | ---- | ---- | ----- |
| 4.89  | 145  | 50.6 | —     |

```@raw html
<details><summary>Code</summary>
<pre>
#JuLie
@time L=compositions(Int8(26));
  4.885011 seconds (33.55 M allocations: 3.969 GiB, 24.99% gc time)
  
#Sage
time L=Compositions(26).list()
CPU times: user 2min 21s, sys: 3.48 s, total: 2min 25s
Wall time: 2min 25s

#GAP
L:=OrderedPartitions(26);; time/1000.0;
50.639
</pre>
</details>
```

### Semistandard tableaux

We create the full list of semistandard tableaux of shape (5,3,2). There are about 2.1 million.

| JuLie | Sage | GAP  | Magma |
| ----- | ---- | ---- | ----- |
| 0.48  | 30.5 | —    | —     |

```@raw html
<details><summary>Code</summary>
<pre>
#JuLie
@time L=semistandard_tableaux(Partition(Int8[5,3,2]));
  0.484039 seconds (8.49 M allocations: 843.072 MiB)
  
#Sage
time L=SemistandardTableaux([5,3,2]).list()
CPU times: user 29.9 s, sys: 616 ms, total: 30.5 s
Wall time: 30.5 s
</pre>
</details>
```

### Standard tableaux

We create the full list of standard tableaux of shape (10,8,2). There are about 1.5 million.

| JuLie | Sage | GAP  | Magma |
| ----- | ---- | ---- | ----- |
| 0.40  | 69   | —    | —     |

```@raw html
<details><summary>Code</summary>
<pre>
#JuLie
@time L=standard_tableaux(Int8[10,8,2]);
  0.404633 seconds (7.35 M allocations: 757.029 MiB)
  
sage: time L = StandardTableaux([10,8,2]).list()
CPU times: user 1min 9s, sys: 246 ms, total: 1min 9s
Wall time: 1min 9s
</pre>
</details>
```

