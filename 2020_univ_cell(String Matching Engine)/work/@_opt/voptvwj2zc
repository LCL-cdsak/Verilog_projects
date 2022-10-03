library verilog;
use verilog.vl_types.all;
entity SME is
    generic(
        \out\           : integer := 0;
        read            : integer := 1;
        comparing       : integer := 2
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        chardata        : in     vl_logic_vector(7 downto 0);
        isstring        : in     vl_logic;
        ispattern       : in     vl_logic;
        valid           : out    vl_logic;
        match           : out    vl_logic;
        match_index     : out    vl_logic_vector(4 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of \out\ : constant is 1;
    attribute mti_svvh_generic_type of read : constant is 1;
    attribute mti_svvh_generic_type of comparing : constant is 1;
end SME;
