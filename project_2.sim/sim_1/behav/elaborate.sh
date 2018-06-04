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
ExecStep $xv_path/bin/xelab -wto 4854bd6dd3114d94b023722d3688f095 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L secureip --snapshot board_behav xil_defaultlib.board -log elaborate.log
