class Priority_Encoder;
    // Inputs
    logic [24:0] significand;
    logic [7:0] Exponent_a;

    // Outputs
    logic [24:0] Significand;
    logic [7:0] Exponent_sub;

    // Internal variables
    logic [4:0] shift;

    // Constructor
    function new();
        // Initialize all variables
    endfunction

    // Method to set input values
    function void Prepare(logic [24:0] sig, logic [7:0] exp);
        significand = sig;
        Exponent_a = exp;
    endfunction

    // Method to execute the priority encoding logic
    function void Execute();
        casex (significand)
            25'b1_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx : begin
                Significand = significand;
                shift = 5'd0;
            end
            25'b1_01xx_xxxx_xxxx_xxxx_xxxx_xxxx : begin
                Significand = significand << 1;
                shift = 5'd1;
            end
            25'b1_001x_xxxx_xxxx_xxxx_xxxx_xxxx : begin
                Significand = significand << 2;
                shift = 5'd2;
            end
            25'b1_0001_xxxx_xxxx_xxxx_xxxx_xxxx : begin
                Significand = significand << 3;
                shift = 5'd3;
            end
            25'b1_0000_1xxx_xxxx_xxxx_xxxx_xxxx : begin
                Significand = significand << 4;
                shift = 5'd4;
            end
            25'b1_0000_01xx_xxxx_xxxx_xxxx_xxxx : begin
                Significand = significand << 5;
                shift = 5'd5;
            end
            25'b1_0000_001x_xxxx_xxxx_xxxx_xxxx : begin
                Significand = significand << 6;
                shift = 5'd6;
            end
            25'b1_0000_0001_xxxx_xxxx_xxxx_xxxx : begin
                Significand = significand << 7;
                shift = 5'd7;
            end
            25'b1_0000_0000_1xxx_xxxx_xxxx_xxxx : begin
                Significand = significand << 8;
                shift = 5'd8;
            end
            25'b1_0000_0000_01xx_xxxx_xxxx_xxxx : begin
                Significand = significand << 9;
                shift = 5'd9;
            end
            25'b1_0000_0000_001x_xxxx_xxxx_xxxx : begin
                Significand = significand << 10;

                shift = 5'd10;
            end
            25'b1_0000_0000_0001_xxxx_xxxx_xxxx : begin
                Significand = significand << 11;
                shift = 5'd11;
            end
            25'b1_0000_0000_0000_1xxx_xxxx_xxxx : begin
                Significand = significand << 12;
                shift = 5'd12;
            end
            25'b1_0000_0000_0000_01xx_xxxx_xxxx : begin
                Significand = significand << 13;
                shift = 5'd13;
            end
            25'b1_0000_0000_0000_001x_xxxx_xxxx : begin
                Significand = significand << 14;
                shift = 5'd14;
            end
            25'b1_0000_0000_0000_0001_xxxx_xxxx : begin
                Significand = significand << 15;
                shift = 5'd15;
            end
            25'b1_0000_0000_0000_0000_1xxx_xxxx : begin
                Significand = significand << 16;
                shift = 5'd16;
            end
            25'b1_0000_0000_0000_0000_01xx_xxxx : begin
                Significand = significand << 17;
                shift = 5'd17;
            end
            25'b1_0000_0000_0000_0000_001x_xxxx : begin
                Significand = significand << 18;
                shift = 5'd18;
            end
            25'b1_0000_0000_0000_0000_0001_xxxx : begin
                Significand = significand << 19;
                shift = 5'd19;
            end
            25'b1_0000_0000_0000_0000_0000_1xxx : begin
                Significand = significand << 20;
                shift = 5'd20;
            end
            25'b1_0000_0000_0000_0000_0000_01xx : begin
                Significand = significand << 21;
                shift = 5'd21;
            end
            25'b1_0000_0000_0000_0000_0000_001x : begin
                Significand = significand << 22;
                shift = 5'd22;
            end
            25'b1_0000_0000_0000_0000_0000_0001 : begin
                Significand = significand << 23;
                shift = 5'd23;
            end
            25'b1_0000_0000_0000_0000_0000_0000 : begin
                Significand = significand << 24;
                shift = 5'd24;
            end
            default : begin
                Significand = (~significand) + 1'b1;
                shift = 8'd0;
            end
        endcase
        Exponent_sub = Exponent_a - shift;
       //$display("significand=%h,shift=%h,Significand=%h,Exponent_sub=%h",significand,shift,Significand,Exponent_sub);
    endfunction
endclass


class Ref_Addition_Subtraction;
    // Inputs
    logic [31:0] a_operand, b_operand;
    logic AddBar_Sub; // 0 for Addition, 1 for Subtraction

    // Outputs
    logic Exception;
    logic [31:0] result;

    // Internal variables
    logic Comp_enable;
    logic [31:0] operand_a, operand_b;
    logic [23:0] significand_a, significand_b;
    logic [7:0] exponent_diff;
    logic [23:0] significand_b_add_sub;
    logic [7:0] exponent_b_add_sub;
    logic perform,output_sign,operation_sub_addBar;
    logic [24:0] significand_add;
    logic [30:0] add_sum;
    logic [23:0] significand_sub_complement;
    logic [24:0] significand_sub;
    logic [30:0] sub_diff;
    logic [24:0] subtraction_diff;
    logic [7:0] exponent_sub;

    Priority_Encoder Enc;

    // Constructor
    function new();
        // Initialize all variables
    endfunction

    // Method to set input values
    function void Prepare(logic [31:0] a, logic [31:0] b, logic add_sub);
        a_operand = a;
        b_operand = b;
        AddBar_Sub = add_sub;
    endfunction

    // Method to execute the addition/subtraction operation
    function void Execute();
        Enc=new();

        // Step 1: Compare operands and swap if necessary
        if (a_operand[30:0] < b_operand[30:0]) begin
            Comp_enable = 1'b1;
            operand_a = b_operand;
            operand_b = a_operand;
        end else begin
            Comp_enable = 1'b0;
            operand_a = a_operand;
            operand_b = b_operand;
        end

        // Step 2: Check for exceptions
        Exception = (operand_a[30:23] == 8'hFF) | (operand_b[30:23] == 8'hFF);
        

        // Step 3: Determine output sign
        if (AddBar_Sub) begin
            output_sign = Comp_enable ? !operand_a[31] : operand_a[31];
        end else begin
            output_sign = operand_a[31];
        end
        operation_sub_addBar = AddBar_Sub ? operand_a[31] ^ operand_b[31] : ~(operand_a[31] ^ operand_b[31]);
        
        // Step 4: Assign significands and exponents
        significand_a = (|operand_a[30:23]) ? {1'b1, operand_a[22:0]} : {1'b0, operand_a[22:0]};
        significand_b = (|operand_b[30:23]) ? {1'b1, operand_b[22:0]} : {1'b0, operand_b[22:0]};
        exponent_diff = operand_a[30:23] - operand_b[30:23];

        // Step 5: Align significand_b
        significand_b_add_sub = significand_b >> exponent_diff;
        exponent_b_add_sub = operand_b[30:23] + exponent_diff;

        // Step 6: Check exponent alignment
        perform = (operand_a[30:23] == exponent_b_add_sub);

//------------------------------------------------ADD BLOCK------------------------------------------//

        significand_add = (perform & operation_sub_addBar) ? (significand_a + significand_b_add_sub) : 25'd0; 
        add_sum[22:0] = significand_add[24] ? significand_add[23:1] : significand_add[22:0];
        add_sum[30:23] = significand_add[24] ? (1'b1 + operand_a[30:23]) : operand_a[30:23];
//------------------------------------------------SUB BLOCK------------------------------------------//

        significand_sub_complement = (perform & !operation_sub_addBar) ? ~(significand_b_add_sub) + 24'd1 : 24'd0 ; 
        significand_sub = perform ? (significand_a + significand_sub_complement) : 25'd0;
            //$display("significand_sub=%h,operand_a[30:23]=%h",significand_sub,operand_a[30:23]);
        Enc.Prepare(significand_sub,operand_a[30:23]);
        Enc.Execute();
        subtraction_diff=Enc.Significand;
        exponent_sub=Enc.Exponent_sub;
        sub_diff[30:23] = exponent_sub;
        sub_diff[22:0] = subtraction_diff[22:0];
//-------------------------------------------------OUTPUT--------------------------------------------//
        result = Exception ? 32'b0 : ((!operation_sub_addBar) ? {output_sign,sub_diff} : {output_sign,add_sum});
        // Step 7: Perform addition or subtraction
        /*if (AddBar_Sub) begin
            // Subtraction logic
            significand_sub_complement = (perform & !operation_sub_addBar) ? ( ~significand_b_add_sub + 24'd1 ) : 24'd0;
            significand_sub = perform ? (significand_a + significand_sub_complement) : 25'd0;
            // Implement priority encoder logic
            // ...
            Enc.Prepare(significand_sub,operand_a[30:23]);
            Enc.Execute();
            subtraction_diff=Enc.Significand;
            exponent_sub=Enc.Exponent_sub;
            sub_diff[30:23] = exponent_sub;
            sub_diff[22:0] = subtraction_diff[22:0];
            result = Exception ? 32'b0 : {output_sign, sub_diff};
        end else begin
            // Addition logic
            significand_add = (perform & operation_sub_addBar) ? (significand_a + significand_b_add_sub) : 25'd0;
            add_sum[22:0] = significand_add[24] ? significand_add[23:1] : significand_add[22:0];
            add_sum[30:23] = significand_add[24] ? (1'b1 + operand_a[30:23]) : operand_a[30:23];
            result = Exception ? 32'b0 : {output_sign, add_sum};
        end*/
    endfunction
endclass

class Ref_Multiplication;
    // Inputs
    logic [31:0] a_operand, b_operand;

    // Outputs
    logic Exception, Overflow, Underflow;
    logic [31:0] result;

    // Internal variables
    logic sign;
    logic [47:0] product, product_normalised;
    logic [23:0] operand_a, operand_b;
    logic product_round, normalised, zero;
    logic [8:0] sum_exponent, exponent;
    logic [22:0] product_mantissa;

    // Constructor
    function new();
        // Initialize all variables to their default values
        a_operand = 32'd0;
        b_operand = 32'd0;
        Exception = 0;
        Overflow = 0;
        Underflow = 0;
        result = 32'd0;
        sign = 0;
        product = 48'd0;
        product_normalised = 48'd0;
        operand_a = 24'd0;
        operand_b = 24'd0;
        product_round = 0;
        normalised = 0;
        zero = 0;
        sum_exponent = 9'd0;
        exponent = 9'd0;
        product_mantissa = 23'd0;
    endfunction

    // Method to set input values
    function void Prepare(logic [31:0] a, logic [31:0] b);
        a_operand = a;
        b_operand = b;
    endfunction

    // Method to execute the multiplication logic
    function void Execute();
        // Determine the sign of the result
        sign = a_operand[31] ^ b_operand[31];

        // Check for exceptions (exponent overflow)
        Exception = (a_operand[30:23] == 8'hFF) | (b_operand[30:23] == 8'hFF);

        // Assign significands with hidden bit
        operand_a = (a_operand[30:23] != 8'h00) ? {1'b1, a_operand[22:0]} : {1'b0, a_operand[22:0]};
        operand_b = (b_operand[30:23] != 8'h00) ? {1'b1, b_operand[22:0]} : {1'b0, b_operand[22:0]};

        // Multiply the significands
        product = operand_a * operand_b;

        // Normalize the product
        normalised = product[47];
        product_normalised = normalised ? product : product << 1;

        // Determine rounding
        product_round = |product_normalised[22:0];

        // Calculate the mantissa with rounding
        product_mantissa = product_normalised[46:24] + {21'b0, product_normalised[23] & product_round};

        // Check for zero result
        zero = Exception ? 1'b0 : (product_mantissa == 23'd0) ? 1'b1 : 1'b0;

        // Calculate the sum exponent and adjust with normalization
        sum_exponent = a_operand[30:23] + b_operand[30:23];
        exponent = sum_exponent - 8'd127 + (normalised ? 1 : 0);

        // Determine overflow and underflow conditions
        Overflow = (exponent[8] && !exponent[7]) && !zero;
        Underflow = (exponent[8] && exponent[7]) && !zero;

        // Assemble the result based on the calculated values
        if (Exception) begin
            result = 32'd0;
        end else if (zero) begin
            result = {sign, 31'd0};
        end else if (Overflow) begin
            result = {sign, 8'hFF, 23'd0};
        end else if (Underflow) begin
            result = {sign, 31'd0};
        end else begin
            result = {sign, exponent[7:0], product_mantissa};
        end
    endfunction
endclass

class Ref_Iteration;
    // Inputs
    logic [31:0] operand_1, operand_2;

    // Outputs
    logic [31:0] solution;

    // Internal variables
    logic [31:0] Intermediate_Value1, Intermediate_Value2;

    logic [31:0] operand_a;
    logic [31:0] operand_b;
    logic AddBar_Sub;

    // Reference models
    Ref_Multiplication M1;
    Ref_Addition_Subtraction A1;
    Ref_Multiplication M2;

    // Constructor
    function new();
        M1 = new();
        A1 = new();
        M2 = new();
    endfunction

    // Method to set input values
    function void Prepare(logic [31:0] op1, logic [31:0] op2);
        operand_1 = op1;
        operand_2 = op2;
    endfunction

    // Method to execute the iteration logic
    function void Execute();
        // Step 1: First Multiplication (M1)
        M1.Prepare(operand_1, operand_2);
        M1.Execute();
        Intermediate_Value1 = M1.result;

        // Step 2: Addition/Subtraction (A1)
        operand_a = 32'h4000_0000; // 2.0 in float
        operand_b = {1'b1, Intermediate_Value1[30:0]}; // Construct the second operand
        AddBar_Sub = 1'b0; // Perform addition
        A1.Prepare(operand_a, operand_b, AddBar_Sub);
        A1.Execute();
        Intermediate_Value2 = A1.result;

        // Step 3: Second Multiplication (M2)
        M2.Prepare(operand_1, Intermediate_Value2);
        M2.Execute();
        solution = M2.result;
    endfunction
endclass

class Ref_Division;
    // Inputs
    logic [31:0] a_operand, b_operand;

    // Outputs
    logic Exception;
    logic [31:0] result;

    // Internal variables
    logic sign;
    logic [7:0] shift;
    logic [7:0] exponent_a;
    logic [31:0] divisor;
    logic [31:0] operand_a;
    logic [31:0] Intermediate_X0;
    logic [31:0] Iteration_X0;
    logic [31:0] Iteration_X1;
    logic [31:0] Iteration_X2;
    logic [31:0] Iteration_X3;
    logic [31:0] solution;

    Ref_Multiplication x0_ref;
    Ref_Addition_Subtraction x0_add_ref;
    Ref_Iteration X1_ref,X2_ref,X3_ref;
    Ref_Multiplication end_ref;
    // Constructor
    function new();
        // Initialize all variables to their default values
        a_operand = 32'd0;
        b_operand = 32'd0;
        Exception = 0;
        result = 32'd0;
        sign = 0;
        shift = 8'd0;
        exponent_a = 8'd0;
        divisor = 32'd0;
        operand_a = 32'd0;
        Intermediate_X0 = 32'd0;
        Iteration_X0 = 32'd0;
        Iteration_X1 = 32'd0;
        Iteration_X2 = 32'd0;
        Iteration_X3 = 32'd0;
        solution = 32'd0;
    endfunction

    // Method to set input values
    function void Prepare(logic [31:0] a, logic [31:0] b);
        a_operand = a;
        b_operand = b;
    endfunction

    // Method to execute the division logic
    function void Execute();
        
        // Calculate exception flags
        Exception = (a_operand[30:23] == 8'hFF) | (b_operand[30:23] == 8'hFF);

        // Determine the sign of the result
        sign = a_operand[31] ^ b_operand[31];

        // Calculate shift value
        shift = 8'd126 - b_operand[30:23];

        // Construct divisor
        divisor = {1'b0, 8'd126, b_operand[22:0]};

        // Calculate exponent_a
        exponent_a = a_operand[30:23] + shift;

        // Construct operand_a
        operand_a = {a_operand[31], exponent_a, a_operand[22:0]};

        // Compute Intermediate_X0 using the predefined value
        // In Hardware module: Multiplication x0(32'hC00B_4B4B,divisor,,,,Intermediate_X0);
        // Here, we assume Multiplication is another reference model
        x0_ref = new();
        x0_ref.Prepare(32'hC00B_4B4B, divisor);
        x0_ref.Execute();
        Intermediate_X0 = x0_ref.result;

        // Compute Iteration_X0 using Addition_Subtraction
        // In Hardware module: Addition_Subtraction X0(Intermediate_X0,32'h4034_B4B5,1'b0,,Iteration_X0);
        x0_add_ref = new();
        x0_add_ref.Prepare(Intermediate_X0, 32'h4034_B4B5, 1'b0);
        x0_add_ref.Execute();
        Iteration_X0 = x0_add_ref.result;

        // Compute Iteration_X1, Iteration_X2, Iteration_X3 using Iteration
        // Assuming Iteration is a subsystem that performs multiple refinements
        // The Iteration module in hardware uses Iteration_X0, divisor, and generates Iteration_X1
        X1_ref = new();
        X1_ref.Prepare(Iteration_X0, divisor);
        X1_ref.Execute();
        Iteration_X1 = X1_ref.solution;

        X2_ref = new();
        X2_ref.Prepare(Iteration_X1, divisor);
        X2_ref.Execute();
        Iteration_X2 = X2_ref.solution;

        X3_ref = new();
        X3_ref.Prepare(Iteration_X2, divisor);
        X3_ref.Execute();
        Iteration_X3 = X3_ref.solution;

        // Multiply Iteration_X3 with operand_a to get solution
        end_ref = new();
        end_ref.Prepare(Iteration_X3, operand_a);
        end_ref.Execute();
        solution = end_ref.result;

        // Assign result with sign and solution's mantissa
        result = {sign, solution[30:0]};
    endfunction
endclass

class Ref_Floating_Point_to_Integer;
    logic [31:0] a_operand;

    logic [31:0] Integer;

    function void Prepare(logic [31:0] a);
        a_operand = a;
    endfunction

    function void Execute();
        logic [23:0] Integer_Value;

        case (a_operand[30:23])
            8'd127:
                Integer_Value = 23'd0;
            8'd128:
                Integer_Value = {a_operand[22], 22'd0};
            8'd129:
                Integer_Value = {a_operand[22:21], 21'd0};
            8'd130:
                Integer_Value = {a_operand[22:20], 20'd0};
            8'd131:
                Integer_Value = {a_operand[22:19], 19'd0};
            8'd132:
                Integer_Value = {a_operand[22:18], 18'd0};
            8'd133:
                Integer_Value = {a_operand[22:17], 17'd0};
            8'd134:
                Integer_Value = {a_operand[22:16], 16'd0};
            8'd135:
                Integer_Value = {a_operand[22:15], 15'd0};
            8'd136:
                Integer_Value = {a_operand[22:14], 14'd0};
            8'd137:
                Integer_Value = {a_operand[22:13], 13'd0};
            8'd138:
                Integer_Value = {a_operand[22:12], 12'd0};
            8'd139:
                Integer_Value = {a_operand[22:11], 11'd0};
            8'd140:
                Integer_Value = {a_operand[22:10], 10'd0};
            8'd141:
                Integer_Value = {a_operand[22:9], 9'd0};
            8'd142:
                Integer_Value = {a_operand[22:8], 8'd0};
            8'd143:
                Integer_Value = {a_operand[22:7], 7'd0};
            8'd144:
                Integer_Value = {a_operand[22:6], 6'd0};
            8'd145:
                Integer_Value = {a_operand[22:5], 5'd0};
            8'd146:
                Integer_Value = {a_operand[22:4], 4'd0};
            8'd147:
                Integer_Value = {a_operand[22:3], 3'd0};
            8'd148:
                Integer_Value = {a_operand[22:2], 2'd0};
            8'd149:
                Integer_Value = {a_operand[22:1], 1'd0};
            default: begin
                if (a_operand[30:23] >= 8'd150) begin
                    Integer_Value = a_operand[22:0];
                end else if (a_operand[30:23] <= 8'd126) begin
                    Integer_Value = 24'd0;
                end
            end
        endcase

        Integer = {a_operand[31:23], Integer_Value[23:1]};
    endfunction
endclass

class ALU_RefModel;
    virtual function void Operate(
        input [31:0] a_operand,
        input [31:0] b_operand,
        input [3:0]  Operation,
        output [31:0] ALU_Output,
        output       Exception,
        output       Overflow,
        output       Underflow
    );
        Ref_Addition_Subtraction AuI;
        Ref_Multiplication MuI;
        Ref_Division DuI;
        Ref_Floating_Point_to_Integer FuI;

        // Initialize operation outputs to default values
        Exception   = 0;
        Overflow    = 0;
        Underflow   = 0;
        ALU_Output  = 0;

		AuI=new();
		MuI=new();
		DuI=new();
		FuI=new();

        case (Operation)
            4'd10: begin  // Addition/Subtraction
                AuI.Prepare(a_operand, b_operand, 1'b0);  // Addition
                AuI.Execute();
                Exception=AuI.Exception; 
                ALU_Output=AuI.result;
                // Handle subtraction by adding the negation of b_operand
                //AuI.Prepare(a_operand, -b_operand, 1'b0);
                //{Exception, 1'b0, 1'b0, ALU_Output} = AuI.Execute();
            end

            4'd1: begin  // Multiplication
                MuI.Prepare(a_operand, b_operand);
                MuI.Execute();
                Exception=MuI.Exception;
                Overflow=MuI.Overflow;
                Underflow=MuI.Underflow;
                ALU_Output=MuI.result;
            end

            4'd2: begin  // Division
                DuI.Prepare(a_operand, b_operand);
                DuI.Execute();
                Exception=DuI.Exception;
                ALU_Output=DuI.result;
            end

            4'd3: begin  // Subtraction
                AuI.Prepare(a_operand, b_operand, 1'b1);
                AuI.Execute();
                Exception=AuI.Exception; 
                ALU_Output=AuI.result;
            end

            4'd4: begin  // OR
                ALU_Output = a_operand | b_operand;
            end

            4'd5: begin  // AND
                ALU_Output = a_operand & b_operand;
            end

            4'd6: begin  // XOR
                ALU_Output = a_operand ^ b_operand;
            end

            4'd7: begin  // Logical Shift Left
                ALU_Output = a_operand << 1;
            end

            4'd8: begin  // Logical Shift Right
                ALU_Output = a_operand >> 1;
            end

            4'd9: begin  // Floating Point to Integer
                FuI.Prepare(a_operand);
                FuI.Execute();
                ALU_Output = FuI.Integer;
            end

            4'd11: begin  // Complement
                ALU_Output = !a_operand;
            end

            default: begin
                // Handle invalid operations
                Exception = 1;
            end
        endcase
    endfunction
endclass
