library verilog;
use verilog.vl_types.all;
entity geofence is
    generic(
        idle            : integer := 0;
        read_object     : integer := 1;
        read_receiver   : integer := 2;
        sort            : integer := 3;
        compare         : integer := 4;
        ready_to_compare: integer := 5;
        finish          : integer := 6;
        temp            : integer := 7
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        X               : in     vl_logic_vector(9 downto 0);
        Y               : in     vl_logic_vector(9 downto 0);
        valid           : out    vl_logic;
        is_inside       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of idle : constant is 1;
    attribute mti_svvh_generic_type of read_object : constant is 1;
    attribute mti_svvh_generic_type of read_receiver : constant is 1;
    attribute mti_svvh_generic_type of sort : constant is 1;
    attribute mti_svvh_generic_type of compare : constant is 1;
    attribute mti_svvh_generic_type of ready_to_compare : constant is 1;
    attribute mti_svvh_generic_type of finish : constant is 1;
    attribute mti_svvh_generic_type of temp : constant is 1;
end geofence;
