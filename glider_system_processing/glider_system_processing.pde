import java.util.Iterator;

ArrayList<TapeCell> tape_cells = new ArrayList<TapeCell>();
ArrayList<RuleCell> rule_cells = new ArrayList<RuleCell>();

int WIDTH = 1000;
int HEIGHT = 800;
int TAPE_LENGTH = 40;
int CELL_STEP = 10;
// macroscopic
int CELL_SIZE = 3;
int TAPE_START_AT = 40;
// microscopic
/*
int CELL_SIZE = 1;
int TAPE_START_AT = 100;
*/

// +1 operation on 2
/*
String INITIAL_STATE = "010001000010001000100010";
String[] RULE_STRINGS = {"", "1000100000010001", "00010001", "", "", "", "", ""};
*/

// Cook (2004)
String INITIAL_STATE = "1";
String[] RULE_STRINGS = {"111", "0"};

String string;

class Glider{
    float x, speed;
    color colour;
    boolean isActive;
    char symbol;

    Glider(){
        isActive = true;
    }

    void update(){
        if(isActive)
            x += speed;
    }

    void display(){
        if(isActive){
            fill(colour);
            rect(x, 0, CELL_SIZE, CELL_SIZE);
        }
    }
}

class TapeCell extends Glider{
    HashMap<Glider, Boolean> collided_with;

    TapeCell(char isymbol){
        x = width - CELL_SIZE * TAPE_START_AT - CELL_SIZE * tape_cells.size() * CELL_STEP;
        speed = (isymbol == ' ') ? 0.05 : 0;
        colour = color(126, 126, 126);
        symbol = isymbol;
        this.update_symbol(isymbol);
        collided_with = new HashMap<Glider, Boolean>();
    }

    void update_symbol(char isymbol){
        symbol = isymbol;
        switch(symbol){
        case 'A':
            colour = color(60, 179, 113);
            speed = 0.07;
            break;
        case 'R':
            colour = color(255, 0, 255);
            speed = 0.09;
            break;
        case '1':
            colour = color(0, 0, 0);
            speed = 0;
            break;
        case '0':
            colour = color(200, 200, 200);
            speed = 0;
            break;
        }
    }

    void update(){
        if(!isActive) return;
        for(RuleCell cell: rule_cells){
            if(!cell.isActive) continue;
            float d = abs(this.x - cell.x);
            if(d <= CELL_SIZE && collided_with.get(cell) == null){
                collided_with.put(cell, true);
                if(symbol == ' '){
                    cell.isActive = false;
                    update_symbol(cell.symbol);
                    fill(0, 0, 0);
                    text(cell.symbol, x, 0);
                    //string += cell.symbol;
                }
                else if(symbol == '0' || symbol == '1'){
                    if(cell.symbol == 'L'){
                        cell.isActive = false;
                        if(symbol == '0') update_symbol('R');
                        if(symbol == '1') update_symbol('A');
                        //string = string.substring(1);
                        //println(string);
                    }
                }
                else if(symbol == 'R' || symbol == 'A'){
                    if(cell.symbol == 'L'){
                        this.isActive = false;
                    }
                    else{
                        if(this.symbol == 'R') cell.isActive = false;
                        if(this.symbol == 'A') ;
                    }
                }
            }
        }
        super.update();
    }
}

class RuleCell extends Glider{
    RuleCell(char isymbol){
        x = WIDTH-CELL_SIZE;
        speed = -1;
        if(isymbol == '1'){
            colour = color(255, 0, 0);
        }
        if(isymbol == '0'){
            colour = color(0, 0, 255);
        }
        if(isymbol == 'L'){
            colour = color(0, 255, 0);
        }
        symbol = isymbol;
    }
}

class Rulebook{
    float pos;
    int index;
    ArrayList<Character> rules;

    Rulebook(ArrayList<Rule> irules){
        pos = 0;
        index = 0;
        rules = new ArrayList<Character>();
        // flatten
        for(Rule rule: irules){
            for(char symbol: rule.cells){
                rules.add(symbol);
            }
        }
    }

    RuleCell next(){
        char symbol = rules.get(index++);
        index = index % rules.size();
        return new RuleCell(symbol);
    }
}

class Rule{
    ArrayList<Character> cells;

    Rule(String s){
        cells = new ArrayList<Character>();
        cells.add('L');
        for(char symbol: s.toCharArray()){
            cells.add(symbol);
        }
    }
}

Rulebook rulebook;

void setup(){
    size(WIDTH, HEIGHT);
    background(255);
    noStroke();
    textSize(16);

    ArrayList<Rule> rules = new ArrayList<Rule>();
    for(String s: RULE_STRINGS){
        rules.add(new Rule(s));
    }

    rulebook = new Rulebook(rules);
    for(char c: INITIAL_STATE.toCharArray()){
        tape_cells.add(new TapeCell(c));
    }
    string = " " + INITIAL_STATE;
    for(int i=0; i < TAPE_LENGTH; ++i){
        tape_cells.add(new TapeCell(' '));
    }
}

void draw(){
    // 1-dimentional view
    /*
    fill(255);
    rect(0, 50, width, height);
    translate(0, 50);
    */

    // 2-dimentional view
    translate(0, frameCount*0.1);

    for (Iterator<TapeCell> it=tape_cells.iterator(); it.hasNext(); ){
        if (!it.next().isActive) it.remove();
    }

    for(TapeCell cell: tape_cells){
        cell.update();
        cell.display();
    }
    for(RuleCell cell: rule_cells){
        cell.update();
        cell.display();
    }

    for (Iterator<TapeCell> it=tape_cells.iterator(); it.hasNext(); ){
        if(!it.next().isActive) it.remove();
    }
    for (Iterator<RuleCell> it=rule_cells.iterator(); it.hasNext(); ){
        if(!it.next().isActive) it.remove();
    }

    if(frameCount % 60 == 0){
        rule_cells.add(rulebook.next());
    }
}

boolean paused = false;

void mouseClicked(){
    if(paused)
        loop();
    else
        noLoop();
    paused = !paused;
}
