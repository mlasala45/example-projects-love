return [[<style>body {
  background-color: #4B2B12;
  height: 100%;
  width: 100%;
}

div {
  box-sizing: border-box;
}

#monkey {
  position: absolute;
  width: 200px;
  height: 170px;
  border: 1px solid #4B2B12;
  left: calc(50% - 100px);
  background-color: white;
  border-radius: 4px;
  box-shadow:0px 0px 15px 10px rgba(0,0,0,0.2);
  top:calc(50% - 85px);
}

#hair1{
  position:absolute;
  background-color:transparent;
  border:0px solid transparent;
  border-radius:50%;
  border-right:5px solid #7D502F;
  width:40px;
  height:40px;
  left:65px;
  top:10px;
  transform:rotate(-50deg);
}

#hair2{
  position:absolute;
  background-color:transparent;
  border:0px solid transparent;
  border-radius:50%;
  border-right:5px solid #7D502F;
  width:40px;
  height:50px;
  left:70px;
  top:12px;
  transform:rotate(-60deg);
}

#hair3{
  position:absolute;
  background-color:transparent;
  border:0px solid transparent;
  border-radius:50%;
  border-right:5px solid #7D502F;
  width:40px;
  height:30px;
  left:65px;
  top:5px;
  transform:rotate(-20deg);
}

#ear-left {
  position: absolute;
  background-color: RGB(223, 188, 150);
  width: 45px;
  height: 45px;
  border-radius: 50%;
  top: 55px;
  left: 20px;
  box-shadow: -2px -2px 4px 0px rgba(0, 0, 0, 0.2);
  border: 5px solid RGB(125, 80, 47);
}

#ear-right {
  position: absolute;
  background-color: RGB(223, 188, 150);
  width: 45px;
  height: 45px;
  border-radius: 50%;
  top: 55px;
  left: 135px;
  box-shadow: 2px -2px 4px 0px rgba(0, 0, 0, 0.2);
  border: 5px solid RGB(125, 80, 47);
}

#face {
  position: absolute;
  width: 120px;
  height: 120px;
  background-color: #7D502F;
  border-radius: 50%;
  left: calc(50% - 60px);
  top: 20px;
  box-shadow: 0px 0px 6px 0px rgba(0, 0, 0, 0.3);
}

#eye-wrap-left {
  position: absolute;
  background-color: RGB(223, 188, 150);
  width: 65px;
  height: 55px;
  border-radius: 50%;
  top: 40px;
  left: 5px;
  transform: rotate(50deg);
  box-shadow: -2px -2px 4px 0px rgba(0, 0, 0, 0.2);
}

#eye-wrap-right {
  position: absolute;
  background-color: RGB(223, 188, 150);
  width: 65px;
  height: 55px;
  border-radius: 50%;
  top: 40px;
  left: 50px;
  transform: rotate(-50deg);
  box-shadow: 2px 2px 4px 0px rgba(0, 0, 0, 0.2);
}

#eye-wrap-left > div {
  position: absolute;
  width: 12px;
  height: 12px;
  background-color: #7D502F;
  border-radius: 50%;
  top: 22px;
  left: 25px;
  box-shadow:2px 2px 3px 0px rgba(0,0,0,0.3) inset;
}

#eye-wrap-right > div {
  position: absolute;
  width: 12px;
  height: 12px;
  background-color: #7D502F;
  border-radius: 50%;
  top: 18px;
  left: 25px;
  box-shadow:-2px 2px 3px 0px rgba(0,0,0,0.3) inset;
}

#mouth {
  position: absolute;
  height: 65px;
  width: 120px;
  border-radius: 50%;
  background-color: RGB(223, 188, 150);
  top: 70px;
  left: calc(50% - 60px);
  box-shadow: -2px -2px 4px 0px rgba(0, 0, 0, 0.2);
}

#line {
  position: absolute;
  height: 65px;
  width: 120px;
  border-radius: 50%;
  background-color: transaprent;
  border: 1px solid transparent;
  border-bottom: 2px solid #7D502F;
  top: -12px;
  left: calc(50% - 60px);
  
}

#nose-left {
  width: 3px;
  height: 9px;
  border-radius: 50%;
  position: absolute;
  background-color: #7D502F;
  transform: rotate(-50deg);
  top: 10px;
  left: 52px;
  box-shadow:1px 1px 1px 1px rgba(0,0,0,0.4) inset;
}

#nose-right {
  width: 3px;
  height: 9px;
  border-radius: 50%;
  position: absolute;
  background-color: #7D502F;
  transform: rotate(50deg);
  top: 10px;
  left: 62px;
  box-shadow:1px 1px 1px 1px rgba(0,0,0,0.4) inset;
}</style><div id="monkey">
  <div id="hair1"></div>
  <div id="hair2"></div>
  <div id="hair3"></div>
  <div id="ear-left"></div>
  <div id="ear-right"></div>
  <div id="face">
    <div id="eye-wrap-left">
      <div></div>
    </div>
    <div id="eye-wrap-right">
      <div></div>
    </div>
    <div id="mouth">
      <div id="line"></div>
      <div id="nose-left"></div>
      <div id="nose-right"></div>
    </div>
  </div>
</div>]]