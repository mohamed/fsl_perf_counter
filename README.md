Hardware Performance Counters for Xilinx MicroBlaze Processor
=============================================================
This project contains a VHDL implementation of hardware performance counters for
Xilinx MicroBlaze processor. These counters have the following features:

* Customizable number of counters
* Support for nested counting
* Very low overhead (2 cycles to start or stop the counter)
* Very low resource usage
* Connects to the MicroBlaze via the Fast Simplex Link (FSL) interface

The counters are located under the `hw` directory, while the assoicated software
driver is located under `sw`

Usage
-----
To use the counters, you simply need to do the following:

* Copy the `perf_counter_v1_00_a` directory in `hw` to the `pcores` directory in
  your Xilinx Platform Studio (XPS) project
* Instantiate FSL links to connect the MicroBlaze processor with the counter
* Set the parameters of the counter according to your needs in XPS
* Finally, copy the software drivers to you Xilinx Software Development Kit
  (SDK) project

LICENSE
-------
See `LICENSE.md`

Questions/Issues
----------------
If you have any questions/issues, please contact [Mohamed
Bamakhrama](http://www.liacs.nl/~mohamed)
