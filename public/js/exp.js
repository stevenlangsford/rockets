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


var bar_demo = new makeRocket(Math.random(),Math.random(),"height","bar_demo");
var color_demo = new makeRocket(Math.random(),Math.random(),"color","color_demo");

var demostimbucket = [];
for(var i=0;i<3;i++){
    demostimbucket.push(new makeRocket(Math.random(),Math.random(),"height","bar_demo"));
    demostimbucket.push(new makeRocket(Math.random(),Math.random(),"color","bar_demo"));    
}

//Math.random() < .5 ? bar_demo.drawMe(100,100) : color_demo.drawMe(250,100);
shuffle(demostimbucket);

 demostimbucket[0].drawMe(triad_x_positions[0],groundlevel-Math.random()*groundjitter)
 demostimbucket[1].drawMe(triad_x_positions[1],groundlevel-Math.random()*groundjitter)
 demostimbucket[2].drawMe(triad_x_positions[2],groundlevel-Math.random()*groundjitter)

// for(var i=0; i<3; i++){
//     console.log(i)
//     demostimbucket[i].mystats();
//     demostimbucket[i].drawMe((triad_x_positions[i],groundlevel-Math.random()*groundjitter))
// }

for(var i=0;i<3;i++){
    console.log(i)
    demostimbucket[i].mystats();
}


// //Generic sequence-of-trials
// //If that's all you want, all you need to edit is the makeTrial object and the responseListener. Give maketrial an appropriate constructor that accept the key trial properties, a drawMe function, and something that will hit responseListener.
// //then put a list of trial-property-setter entries in 'stim' and you're golden.

// var trials = [];
// var trialindex = 0;

// function responseListener(aresponse){//global so it'll be just sitting here available for the trial objects to use. So, it must accept whatever they're passing.
// //    console.log("responseListener heard: "+aresponse); //diag
//     trials[trialindex].response = aresponse;
//     trials[trialindex].responseTime= Date.now();
    
//     $.post('/response',{myresponse:JSON.stringify(trials[trialindex])},function(success){
//     	console.log(success);//For now server returns the string "success" for success, otherwise error message.
//     });
    
//     //can put this inside the success callback, if the next trial depends on some server-side info.
//     trialindex++; //increment index here at the last possible minute before drawing the next trial, so trials[trialindex] always refers to the current trial.
//     nextTrial();
// }

// function nextTrial(){
//     if(trialindex<trials.length){
// 	trials[trialindex].drawMe("uberdiv");
//     }else{
// 	$.post("/finish",function(data){window.location.replace(data)});
//     }
// }

// // a trial object should have a drawMe function and a bunch of attributes.
// //the data-getting process in 'dashboard.ejs' & getData routes creates a csv with a col for every attribute, using 'Object.keys' to list all the properties of the object. Assumes a pattern where everything interesting is saved to the trial object, then that is JSONified and saved as a response.
// //Note functions are dropped by JSON.
// //Also note this means you have to be consistent with the things that are added to each trial before they are saved, maybe init with NA values in the constructor.
// function makeTrial(questiontext){
//     this.ppntID = localStorage.getItem("ppntID");
//     this.questiontext = questiontext;
//     this.drawMe = function(targdiv){
// 	this.drawTime = Date.now();
// 	var responses = "<button onclick='responseListener(\"yes\")'>Yes</button><button onclick='responseListener(\"no\")'>No</button>";
// 	document.getElementById(targdiv).innerHTML=
// 	    "<div class='trialdiv'><p>"+this.questiontext+"</br>"+responses+"</p></div>";
//     }
// }



// function shuffle(a) { //via https://stackoverflow.com/questions/6274339/how-can-i-shuffle-an-array
//     var j, x, i;
//     for (i = a.length - 1; i > 0; i--) {
//         j = Math.floor(Math.random() * (i + 1));
//         x = a[i];
//         a[i] = a[j];
//         a[j] = x;
//     }
//     return a;
// }
// //****************************************************************************************************
// //Stimuli
// var stim = shuffle(["Does this question have a correct answer?","What is the correct answer to this question?"]);
// trials = stim.map(function(x){return new makeTrial(x)});

// nextTrial();
