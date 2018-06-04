#!/bin/bash -f
xv_path="/home/pranav/Vivado/Vivado/2016.4"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xsim board_behav -key {Behavioral:sim_1:Functional:board} -tclbatch board.tcl -log simulate.log
