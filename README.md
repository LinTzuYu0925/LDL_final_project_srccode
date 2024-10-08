# Final Project - Coffee Brewer

- Student ID : ***109062225***
- Name : ***Tzu-Yu Lin***

## 設計概念： 
利用兩個步進馬達，一個做橫桿的移動，一個做圓盤的轉動，達到手沖咖啡時由內到外的轉動。再
利用一個抽水馬達將水抽出。其中，利用課堂所學之螢幕作為操作者介面，鍵盤為輸入訊號。我們
的咖啡機可選擇三種不同的主流沖泡方式及五個最適當的粉水比。
![image](/LDL_final_project_srccode/Pictures/成品照.png)

## 實作過程
1. State Diagram：主要分成 IDLE、選擇沖煮方式、設定粉水比、沖煮四個主要state。
![image](/LDL_final_project_srccode/Pictures/state_diagrame.png)
```verilog
always @(*) begin
    if (state == 2'b00) begin
        if (en)
            next_state = 2'b01;
        else
            next_state = 2'b00;
    end else if (state == 2'b01) begin
        if (en)
            next_state = 2'b10;
        else if (back)
            next_state = 2'b00;
        else
            next_state = 2'b01;
    end else if (state == 2'b10) begin
        if (en)
            next_state = 2'b11;
        else if (back)
            next_state = 2'b01;
        else
            next_state = 2'b10;
    end else begin
        if (finish)
            next_state = 2'b00;
        else
            next_state = 2'b11;
    end
end
```

2. Brewing 時的 state diagram
因為不同的沖煮方式有不同的步驟，所以要走的state diagram也當然不同。（這裡的code太長，我覺得放了也沒多大意義就先跳過）
![image](/LDL_final_project_srccode/Pictures/pouring_state_diagrame.png)

3. Block diagram
![image](/LDL_final_project_srccode/Pictures/block_diagrame.png)
Block diagram 如上，最主要的就是state_FSM及pouring_state_FSM兩個在控制我們的機組，並且是由keyboard端輸入，VGA端輸出到螢幕。

4. Mode FSM
這個FSM是在mode choosestate時，根據keyboard的input來判斷要記錄起來哪個mode。接著，再傳給後面的module使用。
```verilog
module mode_FSM (
...
);
    // mode = 0, 1, 2
    reg [1:0] mode_out, nextmode;
    always @ (posedge clk_16 or posedge rst) begin
        if (rst) mode_out <= 2'b00;
        else mode_out <= next_mode;
    end
    always @(*) begin
            if (left && mode_out > 2'b00 && en) next_mode = mode_out - 1;
            else if (right && mode_out < 2'b10 && en) next_mode <= mode_out + 1;
            else next_mode = mode_out;
    end
    assign mode = mode_out;
    
endmodule;
```

5. Water FSM
這個FSM則是在記錄粉水比，其中，我們有設定比例需位於1：12到1：15（最適當比例）之間。
```verilog
module water_FSM(
...
);
    reg[3:0] ratio_out, next_ratio;
    always @(posedge clk_16 or posedge rst) begin
        if (rst) ratio_out <= 4'd15;
        else ratio_out <= next_ratio;
    end

    always @(*) begin
        if (left && ratio_out > 4'd12 && en) next_ratio = ratio_out - 1;
        else if (right && ratio_out < 4'd15 && en) next_ratio = ratio_out + 1;
        else next_ratio = ratio_out;
    end

    assign ratio = ratio_out;
    
endmodule;
```

6. motor control
所有的馬達都由這個module控制，根據input中的direction、steps去做出pos的FSM，進而判斷要輸出的stepperpins為多少。
```verilog
module motor_control (
    input clk_16,
    input rst,
    input en,
    input [11:0] steps;
    input dir,

    output equal,
    output reg [3:0] stepper_pins
);
    reg [13:0] pos, next_pos;
    assign equal = (pos[13:3] >= steps);
    always @ (posedge clk_16 or posedge rst) begin
        if (rst) pos <= 14'd0;
        else pos <= next_pos;
    end
    always @ (*) begin
        if ((pos[13:3] >= steps) && en) next_pos = pos;
        else next_pos = pos + 1;
    end

    always @ (*)
        case (pos[2:0])
            0 : stepper_pins <= dir ? 4'b1000 : 4'b1001;
            1 : stepper_pins <= dir ? 4'b1100 : 4'b0001;
            2 : stepper_pins <= dir ? 4'b0100 : 4'b0011;
            3 : stepper_pins <= dir ? 4'b0110 : 4'b0010;
            4 : stepper_pins <= dir ? 4'b0010 : 4'b0110;
            5 : stepper_pins <= dir ? 4'b0011 : 4'b0100;
            6 : stepper_pins <= dir ? 4'b0001 : 4'b1100;
            7 : stepper_pins <= dir ? 4'b1001 : 4'b1000;
        endcase
endmodule;
```

7. 轉動平面馬達
這顆馬達主要負責將有貼著雷蛇貼紙的紙片轉動。我們利用竹筷夾住馬達的軸。此外，在上下兩層的圓周增加紙壁增加轉動時的固定度。
![image](/LDL_final_project_srccode/Pictures/plate_motor.png)
```verilog
module plate_motor_ctrl (
    input clk,
    input rst,
    input [2:0] pouring_state,

    output [3:0] plate_stepper_pins
);
    wire en = (pouring_state == `POUR || pouring_state == `ONE_SPOT);
    motor_control plat_motor (.clk_16(clk16), .en(en), .rst(rst), .steps(12'd0), .dir(1'b0), .stepper_pins(plate_stepper_pins));
endmodule
```
Code 部分，一樣用motor_control這個module控制，其中的input en是在pour、one spot state 時才需轉動。
```verilog
assign water_pump = (pouring_state == `POUR || pouring_state == `ONE_SPOT);
```

8. 抽水馬達
首先，因為抽水馬達沒有訊號接收的功能，因此我們將它額外多接在一個繼電器上，讓它能依照我們想要的時機時在運作。這個馬達一樣是在pour、one spot state時才需轉動。
![image](/LDL_final_project_srccode/Pictures/water_pump.png)

9. 橫桿馬達
這顆馬達是最難做的，主要是因為要用steps計算我們想要的距離，且同時要做好時間的控制，而且每個state都有不同的移動方式。
首先，先做一個counter的FSM來做計時的部分，接著再根據不同的pouring state來assign不同的steps和direction。最後，再將所有數據一樣接到motor_control module來當input運作。
橫桿馬達實作Code如下
```verilog
module crane_motor_ctrl (
    input clk_23,
    input clk_16,
    input rst,
    input [2:0] pouring_state,

    output equal,
    output [3:0] crane_stepper_pins
);
    reg [11:0] steps;
    reg dir;
    motor_control cran_motor (.clk_16(clk_16), .en(0), .rst(rst || pouring_state == `IDLE));
    
    reg [11:0] counter, counter_next;
    always @ (posedge clk_23) begin
        if (pouring_state != `POUR)
            counter <= 12'd0;
        else
            counter <= counter_next;
    end
    always @ (*) begin
        counter_next = counter + 12'd1;
    end
endmodule
```

10. VGA control
首先，先在vga top module裡根據不同的state要取的不同memory address。接著再根據不同的state 去negation pixel。

將不同state時的memory address在top module裡instantiate。大部分都是利用坐標去判斷Coe 檔現在該讀進去number為多少。Coe中的number是先將圖片畫好，轉成多個coe檔，最後整合為一個coe檔。

## 遇到的困難
1. 步進馬達能接收的電壓是5到12V，但我們遇到5V轉不動，12V會過熱燒壞的窘境。因此後來
我們去多購了一個12V轉9V的變壓器才解決此問題。 
2. 馬達帶動的齒輪和軌道上的齒輪無法完全密合，導致計算上沒問題但實際跑起來卻常出問題。 
3. 抽水馬達一通電便開始運作，如同前面所提。因此我們才多連接一個繼電器達到訊號管理。 
4. 平面轉盤會因承受重量漸漸增加而摩擦力進而太大的卡住，因此我們在機體裡增墊了一個紙杯架高馬達，在同時不破壞平衡的情況下減少其摩擦力。
![image](/LDL_final_project_srccode/Pictures/Screenshot%202024-10-08%20161113.png)
