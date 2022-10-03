library verilog;
use verilog.vl_types.all;
entity LCD_CTRL is
    generic(
        idle            : integer := 0;
        read            : integer := 1;
        op              : integer := 2;
        \out\           : integer := 3;
        wait_cmd        : integer := 4;
        finish          : integer := 5;
        write           : integer := 0;
        shift_up        : integer := 1;
        shift_down      : integer := 2;
        shift_left      : integer := 3;
        shift_right     : integer := 4;
        average         : integer := 5;
        mirror_x        : integer := 6;
        mirror_y        : integer := 7
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        IROM_Q          : in     vl_logic_vector(7 downto 0);
        cmd             : in     vl_logic_vector(2 downto 0);
        cmd_valid       : in     vl_logic;
        IROM_EN         : out    vl_logic;
        IROM_A          : out    vl_logic_vector(5 downto 0);
        IRB_RW          : out    vl_logic;
        IRB_D           : out    vl_logic_vector(7 downto 0);
        IRB_A           : out    vl_logic_vector(5 downto 0);
        busy            : out    vl_logic;
        done            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of idle : constant is 1;
    attribute mti_svvh_generic_type of read : constant is 1;
    attribute mti_svvh_generic_type of op : constant is 1;
    attribute mti_svvh_generic_type of \out\ : constant is 1;
    attribute mti_svvh_generic_type of wait_cmd : constant is 1;
    attribute mti_svvh_generic_type of finish : constant is 1;
    attribute mti_svvh_generic_type of write : constant is 1;
    attribute mti_svvh_generic_type of shift_up : constant is 1;
    attribute mti_svvh_generic_type of shift_down : constant is 1;
    attribute mti_svvh_generic_type of shift_left : constant is 1;
    attribute mti_svvh_generic_type of shift_right : constant is 1;
    attribute mti_svvh_generic_type of average : constant is 1;
    attribute mti_svvh_generic_type of mirror_x : constant is 1;
    attribute mti_svvh_generic_type of mirror_y : constant is 1;
end LCD_CTRL;
