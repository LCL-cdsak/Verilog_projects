library verilog;
use verilog.vl_types.all;
entity LCD_CTRL is
    generic(
        Load_Data       : integer := 0;
        Zoom_In         : integer := 1;
        Zoom_Fit        : integer := 2;
        Shift_Right     : integer := 3;
        Shift_Left      : integer := 4;
        Shift_Up        : integer := 5;
        Shift_Down      : integer := 6;
        Output_1        : integer := 7;
        Output_2        : integer := 8;
        Idle            : integer := 9;
        Output_State    : integer := 0;
        Initial_State   : integer := 1;
        Zoom_Fit_State  : integer := 2;
        Zoom_In_State   : integer := 3
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        datain          : in     vl_logic_vector(7 downto 0);
        cmd             : in     vl_logic_vector(2 downto 0);
        cmd_valid       : in     vl_logic;
        dataout         : out    vl_logic_vector(7 downto 0);
        output_valid    : out    vl_logic;
        busy            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Load_Data : constant is 1;
    attribute mti_svvh_generic_type of Zoom_In : constant is 1;
    attribute mti_svvh_generic_type of Zoom_Fit : constant is 1;
    attribute mti_svvh_generic_type of Shift_Right : constant is 1;
    attribute mti_svvh_generic_type of Shift_Left : constant is 1;
    attribute mti_svvh_generic_type of Shift_Up : constant is 1;
    attribute mti_svvh_generic_type of Shift_Down : constant is 1;
    attribute mti_svvh_generic_type of Output_1 : constant is 1;
    attribute mti_svvh_generic_type of Output_2 : constant is 1;
    attribute mti_svvh_generic_type of Idle : constant is 1;
    attribute mti_svvh_generic_type of Output_State : constant is 1;
    attribute mti_svvh_generic_type of Initial_State : constant is 1;
    attribute mti_svvh_generic_type of Zoom_Fit_State : constant is 1;
    attribute mti_svvh_generic_type of Zoom_In_State : constant is 1;
end LCD_CTRL;
