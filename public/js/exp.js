var canvaswidth = window.innerWidth-30;
var canvasheight = window.innerHeight-30;
var groundlevel = window.innerHeight-155;
var groundjitter = 100;

// function testcolor(athing){
//     var canvas = document.getElementById("ubercanvas");
//     var ctx = canvas.getContext('2d');
//     ctx.clearRect(0,0,canvas.width,canvas.height);
//     abs_holder_div.innerHTML = "";

//     ctx.fillStyle = athing;
//     ctx.fillRect(100,100,300,300)
// }
// function testcolorwalker(level){
//     if(level<0 || level >1)return;

//     testcolor(get_color(level))
//     console.log(level)
//     setTimeout(function(){testcolorwalker(level+.05)},1500)
// }

function get_color(pointval){
    //this is the matplotlib "perceptually uniform sequential colormap: plasma"
    var uniform_colors = [[0.050383, 0.029803, 0.527975],
			  [0.063536, 0.028426, 0.533124],
			  [0.075353, 0.027206, 0.538007],
			  [0.086222, 0.026125, 0.542658],
			  [0.096379, 0.025165, 0.547103],
			  [0.10598, 0.024309, 0.551368],
			  [0.115124, 0.023556, 0.555468],
			  [0.123903, 0.022878, 0.559423],
			  [0.132381, 0.022258, 0.56325],
			  [0.140603, 0.021687, 0.566959],
			  [0.148607, 0.021154, 0.570562],
			  [0.156421, 0.020651, 0.574065],
			  [0.16407, 0.020171, 0.577478],
			  [0.171574, 0.019706, 0.580806],
			  [0.17895, 0.019252, 0.584054],
			  [0.186213, 0.018803, 0.587228],
			  [0.193374, 0.018354, 0.59033],
			  [0.200445, 0.017902, 0.593364],
			  [0.207435, 0.017442, 0.596333],
			  [0.21435, 0.016973, 0.599239],
			  [0.221197, 0.016497, 0.602083],
			  [0.227983, 0.016007, 0.604867],
			  [0.234715, 0.015502, 0.607592],
			  [0.241396, 0.014979, 0.610259],
			  [0.248032, 0.014439, 0.612868],
			  [0.254627, 0.013882, 0.615419],
			  [0.261183, 0.013308, 0.617911],
			  [0.267703, 0.012716, 0.620346],
			  [0.274191, 0.012109, 0.622722],
			  [0.280648, 0.011488, 0.625038],
			  [0.287076, 0.010855, 0.627295],
			  [0.293478, 0.010213, 0.62949],
			  [0.299855, 0.009561, 0.631624],
			  [0.30621, 0.008902, 0.633694],
			  [0.312543, 0.008239, 0.6357],
			  [0.318856, 0.007576, 0.63764],
			  [0.32515, 0.006915, 0.639512],
			  [0.331426, 0.006261, 0.641316],
			  [0.337683, 0.005618, 0.643049],
			  [0.343925, 0.004991, 0.64471],
			  [0.35015, 0.004382, 0.646298],
			  [0.356359, 0.003798, 0.64781],
			  [0.362553, 0.003243, 0.649245],
			  [0.368733, 0.002724, 0.650601],
			  [0.374897, 0.002245, 0.651876],
			  [0.381047, 0.001814, 0.653068],
			  [0.387183, 0.001434, 0.654177],
			  [0.393304, 0.001114, 0.655199],
			  [0.399411, 0.000859, 0.656133],
			  [0.405503, 0.000678, 0.656977],
			  [0.41158, 0.000577, 0.65773],
			  [0.417642, 0.000564, 0.65839],
			  [0.423689, 0.000646, 0.658956],
			  [0.429719, 0.000831, 0.659425],
			  [0.435734, 0.001127, 0.659797],
			  [0.441732, 0.00154, 0.660069],
			  [0.447714, 0.00208, 0.66024],
			  [0.453677, 0.002755, 0.66031],
			  [0.459623, 0.003574, 0.660277],
			  [0.46555, 0.004545, 0.660139],
			  [0.471457, 0.005678, 0.659897],
			  [0.477344, 0.00698, 0.659549],
			  [0.48321, 0.00846, 0.659095],
			  [0.489055, 0.010127, 0.658534],
			  [0.494877, 0.01199, 0.657865],
			  [0.500678, 0.014055, 0.657088],
			  [0.506454, 0.016333, 0.656202],
			  [0.512206, 0.018833, 0.655209],
			  [0.517933, 0.021563, 0.654109],
			  [0.523633, 0.024532, 0.652901],
			  [0.529306, 0.027747, 0.651586],
			  [0.534952, 0.031217, 0.650165],
			  [0.54057, 0.03495, 0.64864],
			  [0.546157, 0.038954, 0.64701],
			  [0.551715, 0.043136, 0.645277],
			  [0.557243, 0.047331, 0.643443],
			  [0.562738, 0.051545, 0.641509],
			  [0.568201, 0.055778, 0.639477],
			  [0.573632, 0.060028, 0.637349],
			  [0.579029, 0.064296, 0.635126],
			  [0.584391, 0.068579, 0.632812],
			  [0.589719, 0.072878, 0.630408],
			  [0.595011, 0.07719, 0.627917],
			  [0.600266, 0.081516, 0.625342],
			  [0.605485, 0.085854, 0.622686],
			  [0.610667, 0.090204, 0.619951],
			  [0.615812, 0.094564, 0.61714],
			  [0.620919, 0.098934, 0.614257],
			  [0.625987, 0.103312, 0.611305],
			  [0.631017, 0.107699, 0.608287],
			  [0.636008, 0.112092, 0.605205],
			  [0.640959, 0.116492, 0.602065],
			  [0.645872, 0.120898, 0.598867],
			  [0.650746, 0.125309, 0.595617],
			  [0.65558, 0.129725, 0.592317],
			  [0.660374, 0.134144, 0.588971],
			  [0.665129, 0.138566, 0.585582],
			  [0.669845, 0.142992, 0.582154],
			  [0.674522, 0.147419, 0.578688],
			  [0.67916, 0.151848, 0.575189],
			  [0.683758, 0.156278, 0.57166],
			  [0.688318, 0.160709, 0.568103],
			  [0.69284, 0.165141, 0.564522],
			  [0.697324, 0.169573, 0.560919],
			  [0.701769, 0.174005, 0.557296],
			  [0.706178, 0.178437, 0.553657],
			  [0.710549, 0.182868, 0.550004],
			  [0.714883, 0.187299, 0.546338],
			  [0.719181, 0.191729, 0.542663],
			  [0.723444, 0.196158, 0.538981],
			  [0.72767, 0.200586, 0.535293],
			  [0.731862, 0.205013, 0.531601],
			  [0.736019, 0.209439, 0.527908],
			  [0.740143, 0.213864, 0.524216],
			  [0.744232, 0.218288, 0.520524],
			  [0.748289, 0.222711, 0.516834],
			  [0.752312, 0.227133, 0.513149],
			  [0.756304, 0.231555, 0.509468],
			  [0.760264, 0.235976, 0.505794],
			  [0.764193, 0.240396, 0.502126],
			  [0.76809, 0.244817, 0.498465],
			  [0.771958, 0.249237, 0.494813],
			  [0.775796, 0.253658, 0.491171],
			  [0.779604, 0.258078, 0.487539],
			  [0.783383, 0.2625, 0.483918],
			  [0.787133, 0.266922, 0.480307],
			  [0.790855, 0.271345, 0.476706],
			  [0.794549, 0.27577, 0.473117],
			  [0.798216, 0.280197, 0.469538],
			  [0.801855, 0.284626, 0.465971],
			  [0.805467, 0.289057, 0.462415],
			  [0.809052, 0.293491, 0.45887],
			  [0.812612, 0.297928, 0.455338],
			  [0.816144, 0.302368, 0.451816],
			  [0.819651, 0.306812, 0.448306],
			  [0.823132, 0.311261, 0.444806],
			  [0.826588, 0.315714, 0.441316],
			  [0.830018, 0.320172, 0.437836],
			  [0.833422, 0.324635, 0.434366],
			  [0.836801, 0.329105, 0.430905],
			  [0.840155, 0.33358, 0.427455],
			  [0.843484, 0.338062, 0.424013],
			  [0.846788, 0.342551, 0.420579],
			  [0.850066, 0.347048, 0.417153],
			  [0.853319, 0.351553, 0.413734],
			  [0.856547, 0.356066, 0.410322],
			  [0.85975, 0.360588, 0.406917],
			  [0.862927, 0.365119, 0.403519],
			  [0.866078, 0.36966, 0.400126],
			  [0.869203, 0.374212, 0.396738],
			  [0.872303, 0.378774, 0.393355],
			  [0.875376, 0.383347, 0.389976],
			  [0.878423, 0.387932, 0.3866],
			  [0.881443, 0.392529, 0.383229],
			  [0.884436, 0.397139, 0.37986],
			  [0.887402, 0.401762, 0.376494],
			  [0.89034, 0.406398, 0.37313],
			  [0.89325, 0.411048, 0.369768],
			  [0.896131, 0.415712, 0.366407],
			  [0.898984, 0.420392, 0.363047],
			  [0.901807, 0.425087, 0.359688],
			  [0.904601, 0.429797, 0.356329],
			  [0.907365, 0.434524, 0.35297],
			  [0.910098, 0.439268, 0.34961],
			  [0.9128, 0.444029, 0.346251],
			  [0.915471, 0.448807, 0.34289],
			  [0.918109, 0.453603, 0.339529],
			  [0.920714, 0.458417, 0.336166],
			  [0.923287, 0.463251, 0.332801],
			  [0.925825, 0.468103, 0.329435],
			  [0.928329, 0.472975, 0.326067],
			  [0.930798, 0.477867, 0.322697],
			  [0.933232, 0.48278, 0.319325],
			  [0.93563, 0.487712, 0.315952],
			  [0.93799, 0.492667, 0.312575],
			  [0.940313, 0.497642, 0.309197],
			  [0.942598, 0.502639, 0.305816],
			  [0.944844, 0.507658, 0.302433],
			  [0.947051, 0.512699, 0.299049],
			  [0.949217, 0.517763, 0.295662],
			  [0.951344, 0.52285, 0.292275],
			  [0.953428, 0.52796, 0.288883],
			  [0.95547, 0.533093, 0.28549],
			  [0.957469, 0.53825, 0.282096],
			  [0.959424, 0.543431, 0.278701],
			  [0.961336, 0.548636, 0.275305],
			  [0.963203, 0.553865, 0.271909],
			  [0.965024, 0.559118, 0.268513],
			  [0.966798, 0.564396, 0.265118],
			  [0.968526, 0.5697, 0.261721],
			  [0.970205, 0.575028, 0.258325],
			  [0.971835, 0.580382, 0.254931],
			  [0.973416, 0.585761, 0.25154],
			  [0.974947, 0.591165, 0.248151],
			  [0.976428, 0.596595, 0.244767],
			  [0.977856, 0.602051, 0.241387],
			  [0.979233, 0.607532, 0.238013],
			  [0.980556, 0.613039, 0.234646],
			  [0.981826, 0.618572, 0.231287],
			  [0.983041, 0.624131, 0.227937],
			  [0.984199, 0.629718, 0.224595],
			  [0.985301, 0.63533, 0.221265],
			  [0.986345, 0.640969, 0.217948],
			  [0.987332, 0.646633, 0.214648],
			  [0.98826, 0.652325, 0.211364],
			  [0.989128, 0.658043, 0.2081],
			  [0.989935, 0.663787, 0.204859],
			  [0.990681, 0.669558, 0.201642],
			  [0.991365, 0.675355, 0.198453],
			  [0.991985, 0.681179, 0.195295],
			  [0.992541, 0.68703, 0.19217],
			  [0.993032, 0.692907, 0.189084],
			  [0.993456, 0.69881, 0.186041],
			  [0.993814, 0.704741, 0.183043],
			  [0.994103, 0.710698, 0.180097],
			  [0.994324, 0.716681, 0.177208],
			  [0.994474, 0.722691, 0.174381],
			  [0.994553, 0.728728, 0.171622],
			  [0.994561, 0.734791, 0.168938],
			  [0.994495, 0.74088, 0.166335],
			  [0.994355, 0.746995, 0.163821],
			  [0.994141, 0.753137, 0.161404],
			  [0.993851, 0.759304, 0.159092],
			  [0.993482, 0.765499, 0.156891],
			  [0.993033, 0.77172, 0.154808],
			  [0.992505, 0.777967, 0.152855],
			  [0.991897, 0.784239, 0.151042],
			  [0.991209, 0.790537, 0.149377],
			  [0.990439, 0.796859, 0.14787],
			  [0.989587, 0.803205, 0.146529],
			  [0.988648, 0.809579, 0.145357],
			  [0.987621, 0.815978, 0.144363],
			  [0.986509, 0.822401, 0.143557],
			  [0.985314, 0.828846, 0.142945],
			  [0.984031, 0.835315, 0.142528],
			  [0.982653, 0.841812, 0.142303],
			  [0.98119, 0.848329, 0.142279],
			  [0.979644, 0.854866, 0.142453],
			  [0.977995, 0.861432, 0.142808],
			  [0.976265, 0.868016, 0.143351],
			  [0.974443, 0.874622, 0.144061],
			  [0.97253, 0.88125, 0.144923],
			  [0.970533, 0.887896, 0.145919],
			  [0.968443, 0.894564, 0.147014],
			  [0.966271, 0.901249, 0.14818],
			  [0.964021, 0.90795, 0.14937],
			  [0.961681, 0.914672, 0.15052],
			  [0.959276, 0.921407, 0.151566],
			  [0.956808, 0.928152, 0.152409],
			  [0.954287, 0.934908, 0.152921],
			  [0.951726, 0.941671, 0.152925],
			  [0.949151, 0.948435, 0.152178],
			  [0.946602, 0.95519, 0.150328],
			  [0.944152, 0.961916, 0.146861],
			  [0.941896, 0.96859, 0.140956],
			  [0.940015, 0.975158, 0.131326]]

    var index = Math.round(pointval*(uniform_colors.length-1)) //assumes pointval in 0-1: scales from 0 to last legal index (length-1)

    var rgb_vals = uniform_colors[index].map(function(x){return(x * 255)}); //

    var rgb_string = "rgb("+rgb_vals[0]+","+rgb_vals[1]+","+rgb_vals[2]+")";
    return(rgb_string)
    
}//end get color

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
    this.idstring = idstring;
    
    this.flight_value = fuel_value * base_value;

    this.mystats = function(){

	return (this.type)+":"+
	(" fuel "+fuel_value)+
	(" feet "+base_value)+
	(" flight "+this.flight_value);
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
	var fuelcolor = display_type == "height" ? "#4d4d4d" : get_color(this.fuel) //default : variable value
	
	var fuelheight = display_type == "height" ? bh*(1-this.fuel) : 0; //when variable refs the size of the gap, so use 1-value. gap of 0 is filled-body.

	//draw body rect
	ctx.beginPath();
	ctx.moveTo(x , y); 
	ctx.fillStyle = bodycolor;
	ctx.fillRect(x-bw,y-bh,bw*2,bh);

	//body rect is the clickable bit:
	live_clickables.push(function(click_x,click_y){
	    //collision detection function
	    // console.log("X:"+(click_x > x-bw && click_x < x-bw+bw*2))
	    // console.log("Y:"+(click_y > y-bh && click_y < y+bh))
	    console.log("pushing to clickable: "+(fuel_value*base_value));
	    if(click_x > x-bw && click_x < x-bw+bw*2 &&
	       click_y > y-bh && click_y < y+bh)return((fuel_value*base_value));
	    
	    return "miss";//click_x > x-bw && click_x < x-bw+bw*2 && click_y > y-bh && click_y < y+bh;


	})
	
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

function feedback(what_kind){
    //dev
    // console.log(what_kind);
    // return;
    //dev
    
    if(!["correct","wrong"].includes(what_kind)){
	error("bad feedback "+what_kind);
    }

    //    return; //no visuals, no nextTrial(). For dev tests.
    //    live_ans = "reset";
    
    var canvas = document.getElementById("ubercanvas");
    var ctx = canvas.getContext('2d');
    ctx.clearRect(0,0,canvas.width,canvas.height);
    abs_holder_div.innerHTML = "";

    ctx.font = "1.5em Arial";
    ctx.fillStyle = what_kind == "correct" ? "green" : "red";
    ctx.textAlign = "center";
    ctx.fillText(what_kind, canvas.width/2, canvas.height/2);


    window.setTimeout(nextTrial,1500);
    
}

var live_clickables = []; //cleared by nextTrial, populated by rocket.drawMe (Looks like a dangerous pattern! Better way is to...?)
var live_ans = "none"; //set by pair_trial.drawme. Compare clicked ans to this to give feedback.

document.getElementById("ubercanvas").addEventListener('click',function(aclick){
    for(var i=0;i<live_clickables.length;i++){
	var clickresult = live_clickables[i](aclick.offsetX,aclick.offsetY);
	if(clickresult!="miss"){
	    console.log("clickresult is ");
	    console.log(clickresult);
	    feedback(clickresult==live_ans ? "correct" : "wrong") //not true/false because there might be more than 2 types of feedback one day.
	}
    }
})

// function response_listener(buttonid){
//     console.log("listener heard "+buttonid);
//     if(buttonid == trials[trialIndex].answer){
// 	feedback("correct");
// 	return;
//     }else{
// 	feedback("wrong");
// 	return;
//     }
//     error("response listener washout "+buttonid);
// }


var buttonheight = 50; //global param! (ouch)
var buttonwidth = 125;
function button_getter(id,top,left){//for 'this one' choice buttons only. (bad name...)

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

function pair_trial(rocket1, rocket2, text, answer){
    this.rocket1 = rocket1;
    this.rocket2 = rocket2;
    this.text = text;
    this.answer = answer;
    
    this.drawMe = function(){
	var mid_x = document.getElementById("ubercanvas").width / 2;
	var mid_y =  document.getElementById("ubercanvas").height / 2;

	var gapwidth = 125; // gap each side of center, ie half the full gap width. in px.

	live_ans = this.answer;
	this.rocket1.drawMe(mid_x - gapwidth, mid_y);
	this.rocket2.drawMe(mid_x + gapwidth, mid_y);

	var canvas = document.getElementById("ubercanvas");
	var ctx = canvas.getContext('2d');
	ctx.font = "1.5em Arial";
	ctx.fillStyle = "black";
	ctx.textAlign = "center";
	ctx.fillText(this.text, canvas.width/2, 100);

	// abs_holder_div.innerHTML = button_getter(1,
	// 					 (mid_y + buttonheight*1.5),
	// 					 mid_x - gapwidth - (buttonwidth/2-15)
	// 					)+
	//     button_getter(2,
	// 		  (mid_y + buttonheight*1.5),
	// 		  mid_x + gapwidth - (buttonwidth/2-15)
	// 		 );
	
    }

}
function triad_trial(rocket1, rocket2, rocket3){
    this.rocket1 = rocket1;
    this.rocket2 = rocket2;
    this.rocket3 = rocket3;
    
    this.drawMe = function(){
	//Triad answers are always based on distance.
//	console.log(this.rocket1.flight_value);
	// console.log(
	//     (this.rocket1.flight_value > this.rocket2.flight_value && this.rocket1.flight_value > this.rocket3.flight_value) ?
	// 	this.rocket1.idstring : (this.rocket2.flight_value > this.rocket3.flight_value ? this.rocket2.idstring : this.rocket3.idstring)
	// )

	live_ans = Math.max(this.rocket1.flight_value,this.rocket2.flight_value,this.rocket3.flight_value);
	
	//    (this.rocket1.flight_value > this.rocket2.flight_value && this.rocket1.flight_value > this.rocket3.flight_value) ?
	//    this.rocket1.idstring : (this.rocket2.flight_value > this.rocket3.flight_value ? this.rocket2.idstring : this.rocket3.idstring)
	
	var jittersize = 50; //param. Linear format for now? Shift to circular?
	var circlesize = 150;
	
	var rnd_order = shuffle([this.rocket1,this.rocket2,this.rocket3]);
	var canvas = document.getElementById("ubercanvas");

	var mid_x = canvas.width/2;
	var mid_y = canvas.height/2;

	
	//in polar cords, position1 is (d,0)
	//position 2 is (d, 2pi/3)
	//position 3 is (d, 4pi/3)

	// so pos 1 in rect cords is: d*cos(0),d*sin(0) = (d,0)
	// pos 2 is d*cos(2pi/3), d*sin(2pi/3)
	//pos 3 is d*cos(4pi/3), d*sin(4pi/3)
 	var x1 = circlesize*Math.cos(0)+mid_x; var y1 = circlesize*Math.sin(0)+mid_y;
	var x2 = circlesize*Math.cos(Math.PI*2/3)+mid_x; var y2 = circlesize*Math.sin(Math.PI*2/3)+mid_y;
	var x3 = circlesize*Math.cos(Math.PI*4/3)+mid_x; var y3 = circlesize*Math.sin(Math.PI*4/3)+mid_y;
	
	rnd_order[0].drawMe(x1+Math.random()*jittersize, y1+Math.random()*jittersize);
	rnd_order[1].drawMe(x2+Math.random()*jittersize, y2+Math.random()*jittersize);
	rnd_order[2].drawMe(x3+Math.random()*jittersize, y3+Math.random()*jittersize);

	// abs_holder_div.innerHTML = button_getter(1,
	// 					 canvas.height-100,
	// 					 canvas.width/4-buttonwidth/2
	// 					)+
	//     button_getter(2,
	// 		  canvas.height-100,
	// 		  canvas.width/2-buttonwidth/2
	// 		 )+
	//     button_getter(3,
	// 		  canvas.height-100,
	// 		  canvas.width*(3/4)-buttonwidth/2
	// 		 )
    }

}
//trial objects should all have drawMe functions. Chuck 'em all in an array, walk through with nextTrial calling drawMe on each.
function splashScreen(text){
    this.text = text;
    
    this.drawMe = function(){
	var canvas = document.getElementById("ubercanvas");
	var ctx = canvas.getContext('2d');
	//	ctx.clearRect(0,0,canvas.width,canvas.height);

	ctx.font = "3em Arial";
	ctx.fillStyle = "black";
	ctx.textAlign = "center";
	ctx.fillText(this.text, canvas.width/2, canvas.height/2);

	abs_holder_div.innerHTML = "<img id='splash' src='/img/continuerocket.png' "+
	    "onmouseenter=\"this.src='"+"img/continuerocket_green.png"+"'\""+
	    "onmouseleave=\"this.src='"+"img/continuerocket.png"+"'\""+
	    "onclick=\"nextTrial()\""+
	    "style='"+
	    "height:"+100+"px; "+
	    "width:"+300+"px; "+
	    "position:fixed; "+
	    "top:"+(canvas.height/2+100)+"px; "+
	    "left:"+(canvas.width/2-150)+"px; "+
	    "'>";
    }
    
}

function nextTrial(){
    trialIndex++;
    live_clickables = [];
    var canvas = document.getElementById("ubercanvas");
    var ctx = canvas.getContext('2d');
    ctx.clearRect(0,0,canvas.width,canvas.height);
    abs_holder_div.innerHTML = "";
    
    if(trialIndex < trials.length){
	trials[trialIndex].drawMe();
    }else{
	$.post("/finish",function(data){window.location.replace(data)});
    }
}



//stim builder:
function push_a_pair_trial(targ_feature,targ_difference,fueltype1, fueltype2){
    //targ_feature in ["fuel", "base"]
    //targ_difference in 0-1
    //fueltype in ["color","height"]
    
    var lower_value = Math.random()*(1-targ_difference)
    var upper_value = lower_value+targ_difference

    var rockets = [];

    if(targ_feature == "fuel"){
	rockets.push(new makeRocket(lower_value,Math.random(),fueltype1,"trial"+trialIndex+"_rocket1"));
	rockets.push(new makeRocket(upper_value,Math.random(),fueltype2,"trial"+trialIndex+"_rocket2"));
    }
    if(targ_feature == "base"){
	rockets.push(new makeRocket(Math.random(),lower_value,fueltype1,"trial"+trialIndex+"_rocket1"));
	rockets.push(new makeRocket(Math.random(),upper_value,fueltype2,"trial"+trialIndex+"_rocket2"));
    }

    if(targ_feature == "distance"){//you might also want to titrate the difficulty of these?
	rockets.push(new makeRocket(Math.random(),Math.random(),fueltype1,"trial"+trialIndex+"_rocket1"));
	rockets.push(new makeRocket(Math.random(),Math.random(),fueltype2,"trial"+trialIndex+"_rocket1"));
    }
    
    if(!["fuel","base","distance"].includes(targ_feature)){
	error("bad push a pair "+targ_feature+":"+targ_difference+":"+use_barfuel_r1+":"+use_barfuel_r2);
    }

    shuffle(rockets)
    
    var ans;
    if(targ_feature=="fuel"){
	ans = rockets[0].fuel > rockets[1].fuel ? rockets[0].flight_value : rockets[1].flight_value;
    }
    if(targ_feature =="base"){
	ans = rockets[0].base > rockets[1].base ? rockets[0].flight_value : rockets[1].flight_value;
    }    
    if(targ_feature =="distance"){
	ans = rockets[0].base*rockets[0].fuel > rockets[1].base*rockets[1].fuel ? rockets[0].flight_value : rockets[1].flight_value;
    }
    
    var mytrial = new pair_trial(rockets[0],
				 rockets[1],
				 "Which rocket has the best "+targ_feature+"?", ans);
    trials.push(mytrial);
}


//MAIN
var trialIndex = -1; //increment-first order in nextTrial() means trials[trialIndex] refers to the current trial.
var trials = []; //still collect an array of all trials even when generating on the fly, because accessing trials[trialIndex] is so handy. (bad pattern?)

//Splashscreen collection:

//  trials.push(new splashScreen("Which rocket has the best base?"))
//  trials.push(new splashScreen("Which rocket has the best fuel?"))
//  trials.push(new splashScreen("Which rocket will fly furthest?"))
//  trials.push(new splashScreen("Which rocket will fly furthest?"))

//grid style walkthrough
function getTarg(){
    var feature1 = Math.random()*.2+.2 //Magic numbers:  .2 is a margin to put all decoys in, .4 is far enough from .5 to build a sensible targ/comp pair.
    var feature2 = 1 - feature1 //doesn't need to be 1-f1 but this makes for nice targ-comp pairs.
    return shuffle([feature1, feature2]);
}
function getComp(atarg){ //just flips features
    return [atarg[1], atarg[0]]
}
function getDominatedDecoy(atarg, xgap, ygap){
    return [atarg[0]-xgap,atarg[1]-ygap]    
}
function getCompromiseDecoy(atarg){
    var targvalue = atarg[0]*atarg[1]
    var x = (atarg[0]+atarg[1])/2 //comp.x is targ.y, so this means midpoint between comp.x and targ.x
    var y = targvalue/x;
    return [x,y]
}

var comparisontypes = [
    ["color","color","color"],
    ["height","color","color"],
    ["color","height","color"],
    ["height","height","color"],
    ["color","color","height"],
    ["height","color","height"],
    ["color", "height","height"],
    ["height","height","height"]
]
var maxgap = .2;
var hm_gapsteps = 5;
var diststeps = []; for(var i=0;i<hm_gapsteps;i++){diststeps.push( (maxgap / hm_gapsteps)*(i+1))}
//ok, so here's the (provisional) deal: for each comparisontype, a dominated decoy at each diststep, a compromise, and a rnd for attn/performance.
//later: beef the reps x2 or x3?

var stimcounter = 0;
for(var comp_i = 0; comp_i < comparisontypes.length; comp_i++){
    stimcounter++;//count from 1
    
    //attraction/similarity stim
    for(var diststeps_i = 0; diststeps_i<diststeps.length;diststeps_i++){
	var targ = getTarg();
	var comp = getComp(targ);
	var decoy = getDominatedDecoy(targ, diststeps[diststeps_i], diststeps[diststeps_i])

	
	trials.push(new triad_trial(new makeRocket(targ[0],targ[1],comparisontypes[comp_i][0],"stim_"+stimcounter+"targ"+comparisontypes[comp_i][0]),
				    new makeRocket(comp[0],comp[1],comparisontypes[comp_i][1],"stim_"+stimcounter+"comp"+comparisontypes[comp_i][1]),
				    new makeRocket(decoy[0],decoy[1],comparisontypes[comp_i][2],"stim_"+stimcounter+"decoy"+comparisontypes[comp_i][2])
				   )
		   );stimcounter++;

	
    }//end for each diststep

    //compromise stim
    var targ = getTarg();
    var comp = getComp(targ);
    var decoy = getCompromiseDecoy(targ);
    trials.push(new triad_trial(new makeRocket(targ[0],targ[1],comparisontypes[comp_i][0],"stim_"+stimcounter+"targ"+comparisontypes[comp_i][0]),
				new makeRocket(comp[0],comp[1],comparisontypes[comp_i][1],"stim_"+stimcounter+"comp"+comparisontypes[comp_i][1]),
				new makeRocket(decoy[0],decoy[1],comparisontypes[comp_i][2],"stim_"+stimcounter+"decoy"+comparisontypes[comp_i][2])
			       )
	       );stimcounter++;

    //random stim
    trials.push(new triad_trial(new makeRocket(Math.random(),Math.random(),comparisontypes[comp_i][0],"stim_"+stimcounter+"rnd"+comparisontypes[comp_i][0]),
				new makeRocket(Math.random(),Math.random(),comparisontypes[comp_i][1],"stim_"+stimcounter+"rnd2"+comparisontypes[comp_i][1]),
				new makeRocket(Math.random(),Math.random(),comparisontypes[comp_i][2],"stim_"+stimcounter+"rnd3"+comparisontypes[comp_i][2])
			       )
	       );stimcounter++;
}




//trials.push(new splashScreen("Which rocket has the best base?"))
//  trials.push(new splashScreen("Which rocket has the best fuel?"))
//  trials.push(new splashScreen("Which rocket will fly furthest?"))
//  trials.push(new splashScreen("Which rocket will fly furthest?"))



//MINI DEMO SEQUENCE
//  trials.push(new splashScreen("Which rocket has the best base?"))

//  push_a_pair_trial("base",0.2,"height", "height")
//  push_a_pair_trial("base",0.2,"color", "color")
//  push_a_pair_trial("base",0.2,"color", "height")
//  push_a_pair_trial("base",0.2,"height", "color")

//  trials.push(new splashScreen("Which rocket has the best fuel?"))

// push_a_pair_trial("fuel",0.2,"height", "height")
// push_a_pair_trial("fuel",0.2,"color", "color")
// push_a_pair_trial("fuel",0.2,"color", "height")
// push_a_pair_trial("fuel",0.2,"height", "color")

// trials.push(new splashScreen("Which rocket will fly furthest?"))

// push_a_pair_trial("distance",0.2,"height", "height")
// push_a_pair_trial("distance",0.2,"color", "color")
// push_a_pair_trial("distance",0.2,"color", "height")
// push_a_pair_trial("distance",0.2,"height", "color")

// trials.push(new splashScreen("Which rocket will fly furthest?"));

// trials.push(new triad_trial(new makeRocket(Math.random(),Math.random(),"height","bar_demo1"),
// 			    new makeRocket(Math.random(),Math.random(),"height","bar_demo2"),
// 			    new makeRocket(Math.random(),Math.random(),"height","bar_demo3"))
// 	   );

// trials.push(new triad_trial(new makeRocket(Math.random(),Math.random(),"height","bar_demo1"),
// 			    new makeRocket(Math.random(),Math.random(),"color","bar_demo2"),
// 			    new makeRocket(Math.random(),Math.random(),"height","bar_demo3"))
// 	   );

// trials.push(new triad_trial(new makeRocket(Math.random(),Math.random(),"color","bar_demo1"),
// 			    new makeRocket(Math.random(),Math.random(),"color","bar_demo2"),
// 			    new makeRocket(Math.random(),Math.random(),"color","bar_demo3"))
// 	   );


nextTrial();
