var canvaswidth = window.innerWidth-30;
var canvasheight = window.innerHeight-30;
var groundlevel = window.innerHeight-155;
var groundjitter = 100;

var triad_x_positions = [window.innerWidth/4, window.innerWidth/2, window.innerWidth*(3/4)];


function shuffle(a) { //via https://stackoverflow.com/questions/6274339/how-can-i-shuffle-an-array
    var j, x, i;
    for (i = a.length - 1; i > 0; i--) {
        j = Math.floor(Math.random() * (i + 1));
        x = a[i];
        a[i] = a[j];
        a[j] = x;
    }
    return a;
}

document.getElementById("uberdiv").innerHTML = " <canvas id=\"ubercanvas\" width=\""+canvaswidth+"\" height=\""+canvasheight+"\" ></canvas>"

function makeRocket(fuel_value, base_value, display_type,idstring){
    //arg validity asserts. Probably there's a better pattern for this?
    if(fuel_value <0 || fuel_value > 1)error("rocket fuel not in 0-1:"+fuel_value+"_"+base_value+"_"+display_type+"_"+idstring);
    if(base_value <0 || base_value > 1)error("rocket base not in 0-1:"+fuel_value+"_"+base_value+"_"+display_type+"_"+idstring);
    var legaldisplay = ["color","height"];
    if(!legaldisplay.includes(display_type))error("rocket display not recognized:"+fuel_value+"_"+base_value+"_"+display_type+"_"+idstring);

    
    this.fuel = fuel_value;
    this.base = base_value;
    this.type = display_type;

    this.flight_value = fuel_value * base_value;

    this.mystats = function(){
	console.log(this.type)
	console.log("fuel "+fuel_value);
	console.log("feet "+base_value);
	console.log("flight "+this.flight_value);
    }

    this.drawMe = function(x, y){
	var canvas = document.getElementById('ubercanvas');
	var ctx = canvas.getContext('2d');


	var stimsize = 2.5; //Multiply all drawing distances by this.
	
	var bw = 10*stimsize; //bodywidth (halved, center-to-edge dist)
	var bh = 20*stimsize; //bodyheight
	var hw = 5*stimsize; //hatwidth (overhang bit only)
	var hh = bh*(2/3); //hatheight (simsize already factored into bh)
	var lh = bh*(3/4); //leg height
	var maxbase = bw*2.5*stimsize; //base width is a variable feature: base_value * maxbase (base value in 0-1)
	var legwidth = 4*stimsize; //line thickness
	var fuelmargin = hw/2; //gap between fuel tank and rocket body. (stimsize factored in to hw)
	
	var hatcolor = 	"#E00000";
	var bodycolor = "#000000"; //unchanging, background bit, not fuel bar variable.

	var colorleftpadder = function(astring){
	    if(astring.length==1){
		return("0"+astring);
	    }else{
		return(astring);
	    }
	    
	    
	}
	var fuelcolor = display_type == "height" ? "#005500" : "#0000"+colorleftpadder(Math.floor(255*fuel_value).toString(16));
	
	var fuelheight = display_type == "height" ? bh*fuel_value : 0;
	
	//draw body rect
	ctx.beginPath();
	ctx.moveTo(x , y); 
	ctx.fillStyle = bodycolor;
	ctx.fillRect(x-bw,y-bh,bw*2,bh);

	//draw hat (triangle)
	ctx.beginPath();
	ctx.fillStyle = hatcolor;
	ctx.moveTo(x-bw,y-bh);
	ctx.lineTo(x-bw-hw, y-bh);
	ctx.lineTo(x, y-bh-hh);
	ctx.lineTo(x+bw+hw, y-bh);
	ctx.lineTo(x+bw, y-bh);
	ctx.fill();

	
	//draw legs
	ctx.beginPath();
	ctx.moveTo(x-0.5*bw, y-hw/4); //the -hw/4 pulls leg joint point up behind body (with ref to stimsize baked in)
	ctx.lineWidth = legwidth;
	ctx.lineTo(x-0.5*this.base*maxbase, y+lh);
	ctx.moveTo(x+0.5*bw,y-hw/4);
	ctx.lineTo(x+0.5*this.base*maxbase, y+lh);
	ctx.stroke();

	//draw fuel tank
	ctx.fillStyle = fuelcolor;
	ctx.fillRect(x-bw+fuelmargin/2,
		     y-(bh-fuelheight),
		     bw*2-fuelmargin,
		     bh-fuelheight);
	
	// ctx.fillRect(x-bw+fuelmargin/2, //x
	// 	     y-bh+fuelheight, //y
	// 	     bw*2-fuelmargin, //width
	// 	     fuelheight); //height
	
    }//end drawme
    
}

function response_listener(buttonid){
    console.log("listener heard "+buttonid);
}

function pair_trial(rocket1, rocket2){
    this.rocket1 = rocket1;
    this.rocket2 = rocket2;

    this.drawMe = function(){
	var mid_x = document.getElementById("ubercanvas").width / 2;
	var mid_y =  document.getElementById("ubercanvas").height / 2;

	var gapwidth = 125; // gap each side of center, ie half the full gap width. in px.
	var buttonheight = 50;
	var buttonwidth = 125;

	
	this.rocket1.drawMe(mid_x - gapwidth, mid_y);
	this.rocket2.drawMe(mid_x + gapwidth, mid_y);


	// document.write("<button id='immab' style='position:absolute; top:"+(mid_y+150)+"px; left:"+(mid_x-buttongap-buttongap/2)+"px'>This one</button>")
	// document.write("<button style='position:absolute; top:"+(mid_y+150)+"px; left:"+(mid_x+buttongap-buttongap/2)+"px'>This one</button>")

	// document.write("<img src='img/thisone_button.png' height='"+buttonheight+"' width='"+buttonwidth+"' "+
	// 	       "style='"+
	// 	       "position:fixed; "+
	// 	       "top:"+(mid_y + buttonheight + 50)+" "+
	// 	       "left:"+(mid_x - gapwidth - (buttonwidth/2))+" "+
	// 	       "'>");// (') end style (>) end img


	function button_getter(id,top,left){
	    return("<img id='imgbutton"+id+"' src='img/thisone_button.png' "+
		   "onmouseenter=\"this.src='"+"img/thisone_button_green.png"+"'\""+
		   "onmouseleave=\"this.src='"+"img/thisone_button.png"+"'\""+
		   "onclick=\"response_listener('"+id+"')\""+
		   "style='"+
		   "height:"+buttonheight+"px; "+
		   "width:"+buttonwidth+"px; "+
		   "position:fixed; "+
		   "top:"+top+"px; "+
		   "left:"+left+"px; "+
		   "'>")
	}
	abs_holder_div.innerHTML = button_getter(1,
						 (mid_y + buttonheight*1.5),
						 mid_x - gapwidth - (buttonwidth/2-15)
						)+
	    button_getter(2,
			  (mid_y + buttonheight*1.5),
			  mid_x + gapwidth - (buttonwidth/2-15)
			 );
		
	
	console.log("YAY");
    }

}

//MAIN

var bar_demo = new makeRocket(Math.random(),Math.random(),"height","bar_demo");
var color_demo = new makeRocket(Math.random(),Math.random(),"color","color_demo");

var atrial = new pair_trial(bar_demo, color_demo);

atrial.drawMe();

// var demostimbucket = [];
// for(var i=0;i<3;i++){
//     demostimbucket.push(new makeRocket(Math.random(),Math.random(),"height","bar_demo"));
//     demostimbucket.push(new makeRocket(Math.random(),Math.random(),"color","bar_demo"));    
// }

// //Math.random() < .5 ? bar_demo.drawMe(100,100) : color_demo.drawMe(250,100);
// shuffle(demostimbucket);

//  demostimbucket[0].drawMe(triad_x_positions[0],groundlevel-Math.random()*groundjitter)
//  demostimbucket[1].drawMe(triad_x_positions[1],groundlevel-Math.random()*groundjitter)
//  demostimbucket[2].drawMe(triad_x_positions[2],groundlevel-Math.random()*groundjitter)

// for(var i=0;i<3;i++){
//     console.log(i)
//     demostimbucket[i].mystats();
// }
