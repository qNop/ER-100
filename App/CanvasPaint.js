.import QtQuick 2.5 as Canvs

function paintflatweld(style,can){
   var  ctx=can.getContext("2d");
  ctx.clearRect(0,0,100, 80);
  ctx.strokeStyle ="black";
  ctx.fillStyle="blue";
  ctx.antialiasing=false;
  ctx.lineWidth=1.5;
   switch(style){
        case 0:
            ctx.beginPath();
            ctx.moveTo(10,10);
            ctx.lineTo(20,10);
            ctx.lineTo(20,70);
            ctx.lineTo(10,70);
            ctx.closePath();
//     ctx.fill();
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(20,50);
            ctx.lineTo(43,50);
            ctx.lineTo(43,58);
            ctx.lineTo(20,58);
            ctx.closePath();
   //  ctx.fill();
            ctx.stroke();
             ctx.beginPath();
             ctx.moveTo(43,28);
             ctx.lineTo(80,28);
             ctx.lineTo(80,50);
             ctx.lineTo(30,50);
             ctx.closePath();
             //  ctx.fill();
             ctx.stroke();

          //  ctx.beginPath();
        //    ctx.arc(14,35,27,(Math.PI/4),(Math.PI/12),false);
        //    ctx.stroke();
            break;
    }
}
