library verilog;
use verilog.vl_types.all;
entity SDFSNQD0BWP is
    port(
        SI              : in     vl_logic;
        D               : in     vl_logic;
        SE              : in     vl_logic;
        CP              : in     vl_logic;
        SDN             : in     vl_logic;
        Q               : out    vl_logic
    );
end SDFSNQD0BWP;