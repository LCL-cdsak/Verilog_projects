module SME(clk,
           reset,
           chardata,
           isstring,
           ispattern,
           valid,
           match,
           match_index);
    input clk;
    input reset;
    input [7:0] chardata;
    input isstring;
    input ispattern;
    output match;
    output [4:0] match_index;
    output valid;
    
    reg match;
    reg [4:0] match_index;
    reg valid;
    
    reg [7:0] string[33:0];//head & tail concatenate blank
    reg [7:0] pattern[7:0];
    reg [5:0] length_string;
    reg [5:0] length_pattern;
    reg [2:0] state;
    reg [5:0] start;
    reg [1:0] pattern_format;
    parameter out       = 0;
    parameter read      = 1;
    parameter comparing = 2;
    
    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            state          <= read;
            length_string  <= 1; //append head blank
            length_pattern <= 0;
            valid          <= 0;
            match          <= 0;
            match_index    <= 0;
            string[0]      <= 32;
            string[33]     <= 32;
            start          <= 0;
        end
        else
        begin
            state<=state;
        end
    end
    

    always @(posedge clk)
    begin
        case (state)
            out://output data
                state <= read;
            read://read input
            begin
                if (isstring)
                begin
                    string[length_string]<=chardata;
                    length_string<=length_string+1;
                end
                else if(ispattern)
                begin
                    pattern[length_pattern]<=chardata;
                    length_pattern<=length_pattern+1;
                end
                else
                    state<=comparing;
            end
            comparing://compare
            begin
                if((start + length_pattern -1 ) <= (length_string))
                begin
                    case(pattern_format)
                    0://^ + $
                    begin
                        if(
                            (string[start]==32) && (string[start+length_pattern-1]==32||((start+length_pattern-1) == length_string))&&
                            (pattern[1]==string[start+1]||pattern[1]==46||1>=length_pattern||pattern[1]==36) && 
                            (pattern[2]==string[start+2]||pattern[2]==46||2>=length_pattern||pattern[2]==36) &&
                            (pattern[3]==string[start+3]||pattern[3]==46||3>=length_pattern||pattern[3]==36) &&
                            (pattern[4]==string[start+4]||pattern[4]==46||4>=length_pattern||pattern[4]==36) &&
                            (pattern[5]==string[start+5]||pattern[5]==46||5>=length_pattern||pattern[5]==36) &&
                            (pattern[6]==string[start+6]||pattern[6]==46||6>=length_pattern||pattern[6]==36)
                          )
                          begin
                              state<=out;
                              match<=1;
                              match_index <= start;
                          end
                        else
                            match<=0;
                    end
                    1://^
                    begin
                       if(
                            (string[start]==32)&&
                            (pattern[1]==string[start+1]||pattern[1]==46||1>=length_pattern) && 
                            (pattern[2]==string[start+2]||pattern[2]==46||2>=length_pattern) &&
                            (pattern[3]==string[start+3]||pattern[3]==46||3>=length_pattern) &&
                            (pattern[4]==string[start+4]||pattern[4]==46||4>=length_pattern) &&
                            (pattern[5]==string[start+5]||pattern[5]==46||5>=length_pattern) &&
                            (pattern[6]==string[start+6]||pattern[6]==46||6>=length_pattern) &&
                            (pattern[7]==string[start+7]||pattern[7]==46||7>=length_pattern)
                          )
                          begin
                              state<=out;
                              match<=1;
                              match_index <= start;
                          end
                        else
                            match<=0;
                    end
                    2://$
                    begin
                        if(
                            (string[start+length_pattern-1]==32||((start+length_pattern-1) == length_string))&&
                            (pattern[0]==string[start+0]||pattern[0]==46|| 0>=length_pattern || pattern[0]==36) &&
                            (pattern[1]==string[start+1]||pattern[1]==46|| 1>=length_pattern || pattern[1]==36) && 
                            (pattern[2]==string[start+2]||pattern[2]==46|| 2>=length_pattern || pattern[2]==36) &&
                            (pattern[3]==string[start+3]||pattern[3]==46|| 3>=length_pattern || pattern[3]==36) &&
                            (pattern[4]==string[start+4]||pattern[4]==46|| 4>=length_pattern || pattern[4]==36) &&
                            (pattern[5]==string[start+5]||pattern[5]==46|| 5>=length_pattern || pattern[5]==36) &&
                            (pattern[6]==string[start+6]||pattern[6]==46|| 6>=length_pattern || pattern[6]==36)
                          )
                          begin
                              state<=out;
                              match<=1;
                              match_index <= start-1;
                          end
                        else
                            match<=0;
                    end
                    3:
                    begin
                        if(
                            (pattern[0]==string[start+0] ||pattern[0]==46|| 0>=length_pattern) &&
                            (pattern[1]==string[start+1] ||pattern[1]==46|| 1>=length_pattern) && 
                            (pattern[2]==string[start+2] ||pattern[2]==46|| 2>=length_pattern) &&
                            (pattern[3]==string[start+3] ||pattern[3]==46|| 3>=length_pattern) &&
                            (pattern[4]==string[start+4] ||pattern[4]==46|| 4>=length_pattern) &&
                            (pattern[5]==string[start+5] ||pattern[5]==46|| 5>=length_pattern) &&
                            (pattern[6]==string[start+6] ||pattern[6]==46|| 6>=length_pattern) &&
                            (pattern[7]==string[start+7] ||pattern[7]==46|| 7>=length_pattern)
                          )
                          begin
                              state<=out;
                              match<=1;
                              match_index <= start-1;
                          end
                        else
                            match<=0;
                    end
                    endcase
                end
                else
                    state <= out;//no match
                start <= start+1;
            end
            default:
                state <= state;
        endcase
    end

    always @(*)
    begin
        casex({pattern[0],pattern[length_pattern-1]})
        16'b0101111000100100://^ + $
             begin
                start = 0;
                pattern_format = 0;
            end
        16'b01011110xxxxxxxx://^
            begin
                start = 0;
                pattern_format = 1;
            end
        16'bxxxxxxxx00100100://$
            begin
                start = 1;
                pattern_format = 2;
            end
        default:
            begin
                start = 1;
                pattern_format = 3;
            end
        endcase
        /*if(pattern[0]==94 && pattern[length_pattern-1] == 36)
            begin
                start = 0;
                pattern_format = 0;
            end
            
        else if(pattern[0]==94 && pattern[length_pattern-1] != 36)
            begin
                start = 0;
                pattern_format = 1;
            end
        else if(pattern[0]!=94 && pattern[length_pattern-1] == 36)
            begin
                start = 1;
                pattern_format = 2;
            end
        else
            begin
                start = 1;
                pattern_format = 3;
            end*/
    end

    always @(posedge isstring) 
    begin
        length_string = 1;
        state = read;
    end
    always @(posedge ispattern) 
    begin
        length_pattern = 0;
        state = read;
    end
    always @(*)
    begin
        case (state)
            out:
                valid = 1;
            read:
                valid = 0;
            comparing:
                valid = 0;
            default:
                valid = 0;
        endcase
    end
endmodule