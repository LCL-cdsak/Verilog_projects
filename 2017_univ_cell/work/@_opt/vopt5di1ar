library verilog;
use verilog.vl_types.all;
entity DT is
    generic(
        idle            : integer := 0;
        read_center_f   : integer := 1;
        read_f          : integer := 2;
        write_f         : integer := 3;
        read_center_b   : integer := 4;
        read_b          : integer := 5;
        write_b         : integer := 6;
        finish          : integer := 7
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        done            : out    vl_logic;
        sti_rd          : out    vl_logic;
        sti_addr        : out    vl_logic_vector(9 downto 0);
        sti_di          : in     vl_logic_vector(15 downto 0);
        res_wr          : out    vl_logic;
        res_rd          : out    vl_logic;
        res_addr        : out    vl_logic_vector(13 downto 0);
        res_do          : out    vl_logic_vector(7 downto 0);
        res_di          : in     vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of idle : constant is 1;
    attribute mti_svvh_generic_type of read_center_f : constant is 1;
    attribute mti_svvh_generic_type of read_f : constant is 1;
    attribute mti_svvh_generic_type of write_f : constant is 1;
    attribute mti_svvh_generic_type of read_center_b : constant is 1;
    attribute mti_svvh_generic_type of read_b : constant is 1;
    attribute mti_svvh_generic_type of write_b : constant is 1;
    attribute mti_svvh_generic_type of finish : constant is 1;
end DT;
