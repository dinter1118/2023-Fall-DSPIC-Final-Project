set ref_cycle  4.58
#set ref_cycle  0.66 4.58 5.16
#set CLK_HALF_PERIODS [expr $ref_cycle/2.0];
#set hdlin_enable_vpp true;  
#set hdlin_check_no_latch true; 
#set synlib_dwgen_fmlink_active true;

set DESIGN	"FIR" 
#/*--------------------------------------------------------------*/
#/*----------------------- 1.Read files -------------------------*/
#/*--------------------------------------------------------------*/
analyze -f verilog ../$DESIGN\.v
elaborate $DESIGN
current_design $DESIGN

# Top module name
set_operating_conditions slow
#/*--------------------------------------------------------------*/
#/*--------------- 2. Set design constraints --------------------*/ 
#/*--------------------------------------------------------------*/
#insert_clock_gating -global
#rewire_clock_gating   -balance_fanout
create_clock -period $ref_cycle [get_ports clk]
set_input_delay [expr $ref_cycle*0.05] -clock clk [all_inputs]
set_output_delay [expr $ref_cycle*0.05] -clock clk [all_outputs]
#set_clock_uncertainty -setup 0.3 clk
#set_clock_uncertainty -hold 0.1 clk
#propagate_constraints -gate_clock
#create_clock -name "clk" [get_ports clk] -period $ref_cycle -waveform {0 CLK_HALF_PERIODS}
#set_clock_uncertainty 0.1 [get_clocks {*}];
set_dont_touch_network [get_clocks clk]
set_dont_touch_network [get_ports rst]
#set_ideal_netowrk [get_ports clk]
set_fix_hold clk
#set_wire_load_mode top
set auto_wire_load_selection true
set_wire_load_mode top
#set_load 0.05 [all_outputs]
set_drive 1.5 [all_inputs] 
set_load [load_of slow/CLKBUFX20/A] [all_outputs]
# Power Constraints #
set_max_area 0
set_leakage_optimization true
set_dynamic_optimization true

#/*--------------------------------------------------------------*/
#/*----------------- 3.Check and Link Design --------------------*/ 
#/*--------------------------------------------------------------*/
#link 
#check_design
#uniquify
link 
check_design
check_timing
update_timing
#uniquify
set_fix_multiple_port_nets -all -buffer_constants  


#/*--------------------------------------------------------------*/
#/*------------------------ 4.Compile ---------------------------*/ 
#/*--------------------------------------------------------------*/

set compile_new_boolean_structure true
set compile_sequential_area_recovery true

set_structure -boolean true -boolean_effort high

#compile  -map_effort medium 
compile_ultra

check_design 
check_timing
update_timing


set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed {a-z A-Z 0-9 _} -max_length 255 -type cell
define_name_rules name_rule -allowed {a-z A-Z 0-9 _[]} -max_length 255 -type net
define_name_rules name_rule -map {{"\*cell\*" "cell"}}
define_name_rules name_rule -map {{"*-return", "myreturn"}}
define_name_rules name_rule -case_insensitive
change_names -hierarchy -rules name_rule

set verilogout_show_unconnected_pins true  

#/*--------------------------------------------------------------*/ 
#/*----------------------- 5.Write out files --------------------*/ 
#/*--------------------------------------------------------------*/
report_resources >> ../fir_syn.report
report_cell  >> ../fir_syn.report
report_design >> ../fir_syn.report
report_area -hierarchy > ../fir_syn.report
report_timing -path full -input_pins -delay max >> ../fir_syn.report
report_timing -path full -input_pins -delay min >> ../fir_syn.report
#report_clock_gating  >> ../fir_syn.report
report_power  >> ../fir_syn.report
#report_datapath  >> ../fir_syn.report
#write -format verilog -hierarchy -output ../fir_syn.v
write -format verilog -hierarchy -output ../NETILST/fir_syn.v

write_sdf -version 3.0 -context verilog -load_delay cell ../NETILST/fir_syn.sdf 
#write_sdf -version 1.0 -interconn interconnect -nosplit_timing_check -edges check_edge -no_escape -nonegchecks -delimiter / -recrem merge_when_paired -design $DESIGN > ./div_syn.sdf 
write_sdc ../NETILST/fir_syn.sdc 

exit
