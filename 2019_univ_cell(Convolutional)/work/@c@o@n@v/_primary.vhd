library verilog;
use verilog.vl_types.all;
entity CONV is
    generic(
        idle            : integer := 0;
        read_0          : integer := 1;
        write_0         : integer := 2;
        read_1          : integer := 3;
        write_1         : integer := 4;
        finish          : integer := 5;
        next_0          : integer := 6;
        next_1          : integer := 7
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        busy            : out    vl_logic;
        ready           : in     vl_logic;
        iaddr           : out    vl_logic_vector(11 downto 0);
        idata           : in     vl_logic_vector(19 downto 0);
        cwr             : out    vl_logic;
        caddr_wr        : out    vl_logic_vector(11 downto 0);
        cdata_wr        : out    vl_logic_vector(19 downto 0);
        crd             : out    vl_logic;
        caddr_rd        : out    vl_logic_vector(11 downto 0);
        cdata_rd        : in     vl_logic_vector(19 downto 0);
        csel            : out    vl_logic_vector(2 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of idle : constant is 1;
    attribute mti_svvh_generic_type of read_0 : constant is 1;
    attribute mti_svvh_generic_type of write_0 : constant is 1;
    attribute mti_svvh_generic_type of read_1 : constant is 1;
    attribute mti_svvh_generic_type of write_1 : constant is 1;
    attribute mti_svvh_generic_type of finish : constant is 1;
    attribute mti_svvh_generic_type of next_0 : constant is 1;
    attribute mti_svvh_generic_type of next_1 : constant is 1;
end CONV;
