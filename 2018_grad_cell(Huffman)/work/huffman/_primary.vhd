library verilog;
use verilog.vl_types.all;
entity huffman is
    generic(
        read            : integer := 0;
        init            : integer := 1;
        sort            : integer := 2;
        combine         : integer := 3;
        swap            : integer := 4;
        temp            : integer := 9;
        split           : integer := 5;
        final_sort      : integer := 6;
        final_assign    : integer := 7;
        finish          : integer := 8
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        gray_valid      : in     vl_logic;
        CNT_valid       : out    vl_logic;
        CNT1            : out    vl_logic_vector(7 downto 0);
        CNT2            : out    vl_logic_vector(7 downto 0);
        CNT3            : out    vl_logic_vector(7 downto 0);
        CNT4            : out    vl_logic_vector(7 downto 0);
        CNT5            : out    vl_logic_vector(7 downto 0);
        CNT6            : out    vl_logic_vector(7 downto 0);
        code_valid      : out    vl_logic;
        HC1             : out    vl_logic_vector(7 downto 0);
        HC2             : out    vl_logic_vector(7 downto 0);
        HC3             : out    vl_logic_vector(7 downto 0);
        HC4             : out    vl_logic_vector(7 downto 0);
        HC5             : out    vl_logic_vector(7 downto 0);
        HC6             : out    vl_logic_vector(7 downto 0);
        M1              : out    vl_logic_vector(7 downto 0);
        M2              : out    vl_logic_vector(7 downto 0);
        M3              : out    vl_logic_vector(7 downto 0);
        M4              : out    vl_logic_vector(7 downto 0);
        M5              : out    vl_logic_vector(7 downto 0);
        M6              : out    vl_logic_vector(7 downto 0);
        gray_data       : in     vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of read : constant is 1;
    attribute mti_svvh_generic_type of init : constant is 1;
    attribute mti_svvh_generic_type of sort : constant is 1;
    attribute mti_svvh_generic_type of combine : constant is 1;
    attribute mti_svvh_generic_type of swap : constant is 1;
    attribute mti_svvh_generic_type of temp : constant is 1;
    attribute mti_svvh_generic_type of split : constant is 1;
    attribute mti_svvh_generic_type of final_sort : constant is 1;
    attribute mti_svvh_generic_type of final_assign : constant is 1;
    attribute mti_svvh_generic_type of finish : constant is 1;
end huffman;
