library verilog;
use verilog.vl_types.all;
entity LBP is
    generic(
        idle            : integer := 0;
        read_center     : integer := 1;
        read            : integer := 2;
        write           : integer := 3;
        done            : integer := 4
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        gray_addr       : out    vl_logic_vector(13 downto 0);
        gray_req        : out    vl_logic;
        gray_ready      : in     vl_logic;
        gray_data       : in     vl_logic_vector(7 downto 0);
        lbp_addr        : out    vl_logic_vector(13 downto 0);
        lbp_valid       : out    vl_logic;
        lbp_data        : out    vl_logic_vector(7 downto 0);
        finish          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of idle : constant is 1;
    attribute mti_svvh_generic_type of read_center : constant is 1;
    attribute mti_svvh_generic_type of read : constant is 1;
    attribute mti_svvh_generic_type of write : constant is 1;
    attribute mti_svvh_generic_type of done : constant is 1;
end LBP;
