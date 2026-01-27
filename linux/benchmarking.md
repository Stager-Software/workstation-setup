# Benchmarking
We use Geekbench6 for CPU benchmarking. A quick benchmark can be ran using the following command:
```sh
mkdir -p /tmp/geekbench && wget -qO- https://cdn.geekbench.com/Geekbench-6.5.0-Linux.tar.gz | tar xz -C /tmp/geekbench --strip-components=1 && /tmp/geekbench/geekbench6
```
This outputs a benchmark together with a nice link to Geekbench that you can save and refer to later.
The scores are calibrated  against a baseline score of 2500 which is the score of an Intel Core i7-12700 - a
fairly modern and powerful processor. Higher scores are better, with double the score indicating
double the performance.