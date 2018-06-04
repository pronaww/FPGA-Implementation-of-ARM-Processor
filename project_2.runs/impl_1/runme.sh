#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/home/pranav/Vivado/Vivado/2016.4/ids_lite/ISE/bin/lin64:/home/pranav/Vivado/Vivado/2016.4/bin
else
  PATH=/home/pranav/Vivado/Vivado/2016.4/ids_lite/ISE/bin/lin64:/home/pranav/Vivado/Vivado/2016.4/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/home/pranav/Vivado/Vivado/2016.4/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/home/pranav/Vivado/Vivado/2016.4/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/pranav/Downloads/project_2_LAB5new/project_2_LAB5/project_2.runs/impl_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

# pre-commands:
/bin/touch .init_design.begin.rst
EAStep vivado -log board.vdi -applog -m64 -product Vivado -messageDb vivado.pb -mode batch -source board.tcl -notrace


