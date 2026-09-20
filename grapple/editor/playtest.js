"use strict";

// UI owns the animation clock and input. Physics remains deterministic at 50 Hz.
window.GrapplePlaytest = (() => {
  const dialog = document.querySelector("#playDialog");
  const screen = document.querySelector("#playCanvas");
  const context = screen.getContext("2d");
  const startSelect = document.querySelector("#playStart");
  const images = {};
  for (const name of ["player", "mover", "spikes", "cannon", "cannonball", "thwomp", "checkpoint"]) {
    images[name] = new Image();
    images[name].src = `../bin/assets/${name}.png`;
  }
  const keyDirections = {ArrowUp:"up", ArrowRight:"right", ArrowDown:"down", ArrowLeft:"left",
    w:"up", d:"right", s:"down", a:"left"};
  const pressed = new Set();
  const touch = new Set();
  let game = null, snapshot = null, starts = [], paused = false;
  let request = 0, previous = 0, accumulator = 0;
  let picking = false;

  function controls() {
    const result = {};
    for (const key of pressed) if (keyDirections[key]) result[keyDirections[key]] = true;
    for (const direction of touch) result[direction] = true;
    return result;
  }
  function release() {
    pressed.clear(); touch.clear();
    document.querySelectorAll("[data-direction]").forEach(b => b.classList.remove("held"));
  }
  function setPaused(value) {
    paused = value;
    accumulator = 0; previous = performance.now();
    document.querySelector("#pausePlay").innerHTML = paused ? "Resume <kbd>Space</kbd>" : "Pause <kbd>Space</kbd>";
    document.querySelector("#stepPlay").disabled = !paused;
    updateStats();
  }
  function launchStart(index) {
    game = new AtariPhysics(snapshot, starts[index].position);
    if (starts[index].checkpoint !== undefined) game.checkpoint = starts[index].checkpoint;
    release(); setPaused(false); draw(); screen.focus();
    if (!game.canSpawn(game.player.x, game.player.y)) {
      game.message = "Start overlaps a wall or hazard. Choose another start or edit this area.";
      setPaused(true);
    }
  }
  function open(position) {
    finishStroke();
    picking = false;
    document.querySelector("#playHere").textContent = "▶ Play from here";
    setTool("brush");
    snapshot = mapCells.map(cloneCell);
    starts = [{label:"Level entrance",position:{x:56,y:152}}];
    for (const cell of snapshot.filter(c => c.tile === 11)) starts.push({
      label:`Checkpoint · row ${cell.y}`, checkpoint:cell.index,
      position:{x:cell.x * 16 - 8,y:cell.y * 16 - 1}});
    if (position) starts.push({label:`Picked spot · row ${Math.floor((position.y + 16) / 16)}`,position});
    startSelect.replaceChildren(...starts.map((s,i) => new Option(s.label,String(i))));
    startSelect.value = String(position ? starts.length - 1 : 0);
    if (!dialog.open) dialog.showModal();
    launchStart(Number(startSelect.value));
    cancelAnimationFrame(request); previous = performance.now();
    request = requestAnimationFrame(frame);
  }
  function chooseHere() {
    picking = activeTool !== "test";
    document.querySelector("#playHere").textContent = picking ? "Cancel start selection" : "▶ Play from here";
    setTool(picking ? "test" : "brush");
    setStatus(picking ? "Click a free cell to play from there. Escape cancels." : "Start selection cancelled");
  }
  function pick(cell) {
    const position = {x:cell.x * 16 - 8,y:cell.y * 16 - 2};
    const probe = new AtariPhysics(mapCells, position);
    if (!probe.canSpawn(position.x,position.y)) {
      setStatus("Choose a free cell inside columns 1–10, away from walls and hazards."); return;
    }
    open(position);
  }
  function frame(now) {
    if (!dialog.open) return;
    if (!paused) {
      accumulator += Math.min(200, now - previous);
      while (accumulator >= 20) { game.tick(controls()); accumulator -= 20; }
    }
    previous = now; draw(); updateStats();
    request = requestAnimationFrame(frame);
  }
  function updateStats() {
    if (!game) return;
    const p = game.player;
    document.querySelector("#playState").textContent = paused ? "Paused" : "Running";
    document.querySelector("#playPosition").textContent = `${Math.floor(p.x)}, ${Math.floor(p.y)} · row ${Math.floor((p.y + 16) / 16)}`;
    document.querySelector("#playVelocity").textContent = `${Math.round(p.vx * 50)}, ${Math.round(p.vy * 50)} px/s`;
    document.querySelector("#playDeaths").textContent = String(game.deaths);
    document.querySelector("#playCheckpoint").textContent = game.checkpoint === null ? "Test start" : `Row ${Math.floor(game.checkpoint / 12)}`;
    document.querySelector("#playMovement").textContent = game.inWater ? "Water · half speed" : game.cooldown ? "Hook recovering" : game.hook ? (game.hook.pulling ? "Pulling" : "Hook extending") : "Free movement";
    document.querySelector("#playEvent").textContent = game.message;
  }
  function depthColor(row) {
    const depth = row * 16 - 8;
    let rgb = [0,0,0];
    for (const [y,color] of [[180,[255,255,255]],[400,[227,156,115]],
      [1100,[0,0,255]],[1700,[179,179,179]],[3200,[0,255,0]]]) {
      if (depth > y) {
        const t = Math.min(1,(depth-y)/64);
        rgb = rgb.map((c,i) => Math.round(c*(1-t)+color[i]*t));
      }
    }
    return `rgb(${rgb.join(",")})`;
  }
  function sprite(name,x,y,frame=0,rotation=0,flip=false,bottom=false) {
    if (y < game.camera-24 || y > game.camera+124) return;
    context.save(); context.translate(Math.floor(x),Math.floor(y)-game.camera);
    context.rotate(rotation*Math.PI/2); context.scale(flip ? -1 : 1,1);
    const image = images[name];
    if (image.complete && image.naturalWidth) {
      const columns = Math.max(1,Math.floor(image.naturalWidth/16));
      const size = Math.min(16,image.naturalWidth,image.naturalHeight);
      context.drawImage(image,(frame%columns)*16,Math.floor(frame/columns)*16,size,size,
        -size/2,bottom ? -size : -size/2,size,size);
    } else {
      context.fillStyle = name === "player" ? "#ff3157" : "white";
      context.fillRect(-6,bottom ? -12 : -6,12,12);
    }
    context.restore();
  }
  function draw() {
    if (!game) return;
    const c = context, cam = game.camera;
    c.setTransform(2,0,0,2,0,0); c.imageSmoothingEnabled = false;
    c.fillStyle = "black"; c.fillRect(0,0,160,100);
    c.fillStyle = "rgb(0,119,153)"; c.fillRect(0,984-cam,160,624);
    c.fillStyle = "#ff6a00";
    for (const l of game.lava) if (l.y >= cam-16 && l.y < cam+100) c.fillRect(l.x,l.y-cam,16,16);
    const top = Math.max(0,Math.floor((cam+16)/16));
    for (let row=top; row<240 && row*16-16<cam+100; row++) {
      c.fillStyle = depthColor(row);
      for (let col=1; col<=10; col++) {
        const tile = game.cells[row*12+col].tile;
        if (tile>=1 && tile<=10) c.fillRect(col*16-16,row*16-16-cam,16,16);
      }
    }
    for (const s of game.spikes) sprite("spikes",s.x,s.y,0,s.rot);
    for (const a of game.cannons) sprite("cannon",a.x,a.y,0,a.rot);
    for (const m of game.movers) sprite("mover",m.x,m.y);
    for (const t of game.thwomps) sprite("thwomp",t.x,t.y,[1,2,0][t.state]);
    for (const cp of game.checkpoints) sprite("checkpoint",cp.x,cp.y,cp.id===game.checkpoint ? 1 : 0,cp.rot);
    for (const b of game.balls) sprite("cannonball",b.x,b.y);
    const p = game.player, h = game.hook;
    if (h) {
      c.strokeStyle = "white"; c.lineWidth = 1;
      c.beginPath(); c.moveTo(Math.floor(p.x),Math.floor(p.y)-6-cam);
      c.lineTo(h.x,h.y-cam); c.stroke(); c.fillStyle="white"; c.fillRect(h.x-2,h.y-2-cam,4,4);
    }
    const phase = Math.floor(game.frame/4);
    let heroFrame = phase%4;
    if (h) heroFrame = h.dir%2 ? [17,18][phase%2] : h.dir===0 ? [11,12][phase%2] : [13,14][phase%2];
    else if (p.vy < -.2) heroFrame = [11,12][phase%2];
    else if (p.vy > .4 || game.cooldown) heroFrame = [13,14][phase%2];
    sprite("player",p.x,p.y,heroFrame,0,p.faceLeft,true);
    if (document.querySelector("#playHitboxes").checked) {
      c.lineWidth=.5;
      for (const item of [...game.hazards().map(h=>({...h.bounds,color:"#ff729a"})),
        ...game.checkpoints.map(cp=>({...game.checkpointBox(cp),color:"#78ffb2"})),
        {...game.playerBox(),color:"#00ffff"}]) {
        if (item.y+item.h<cam || item.y>cam+100) continue;
        c.strokeStyle=item.color; c.strokeRect(item.x,item.y-cam,item.w,item.h);
      }
    }
  }

  document.querySelector("#playMap").addEventListener("click",()=>open());
  document.querySelector("#playHere").addEventListener("click",chooseHere);
  document.querySelector("#closePlay").addEventListener("click",()=>dialog.close());
  document.querySelector("#pausePlay").addEventListener("click",()=>setPaused(!paused));
  document.querySelector("#stepPlay").addEventListener("click",()=>{ if (paused) { game.tick(controls()); draw(); updateStats(); } });
  document.querySelector("#resetPlay").addEventListener("click",()=>{game.reset(); game.message="Respawned"; draw(); updateStats();});
  document.querySelector("#restartPlay").addEventListener("click",()=>{game.restart(); draw(); updateStats();});
  document.querySelector("#editAtPlayer").addEventListener("click",()=>{
    const row = Math.floor((game.player.y+16)/16);
    dialog.close(); jumpToRow(Math.max(0,row-3)); setStatus(`Editing near playtest row ${row}`);
  });
  startSelect.addEventListener("change",()=>launchStart(Number(startSelect.value)));
  dialog.addEventListener("close",()=>{release();cancelAnimationFrame(request);document.querySelector("#playMap").focus();});
  window.addEventListener("blur",()=>{release();if(dialog.open)setPaused(true);});
  document.addEventListener("visibilitychange",()=>{if(document.hidden){release();if(dialog.open)setPaused(true);}});
  window.addEventListener("keydown",event=>{
    if (!dialog.open) {
      if (activeTool === "test" && event.key==="Escape") {event.preventDefault();chooseHere();}
      if (event.key.toLowerCase()==="p" && !event.ctrlKey && !event.metaKey && !event.altKey &&
          !["INPUT","SELECT","TEXTAREA"].includes(event.target.tagName) && !document.querySelector("#confirmDialog").open) {
        event.preventDefault(); if(!document.querySelector("#playMap").disabled)open();
      }
      return;
    }
    if (["SELECT","INPUT"].includes(event.target.tagName) && event.key!=="Escape") return;
    if (event.key==="Escape") return; // native dialog close
    const key=event.key.length===1 ? event.key.toLowerCase() : event.key;
    if (keyDirections[key] || [" ","r","."].includes(key)) {
      event.preventDefault(); event.stopImmediatePropagation();
      if(keyDirections[key]) pressed.add(key);
      if(!event.repeat && key===" ")setPaused(!paused);
      if(!event.repeat && key==="r") {game.reset();game.message="Respawned";}
      if(!event.repeat && key==="." && paused){game.tick(controls());draw();updateStats();}
    }
  },true);
  window.addEventListener("keyup",event=>{pressed.delete(event.key.length===1 ? event.key.toLowerCase() : event.key);});
  document.querySelectorAll("[data-direction]").forEach(button=>{
    button.addEventListener("pointerdown",event=>{
      event.preventDefault();button.setPointerCapture(event.pointerId);touch.add(button.dataset.direction);button.classList.add("held");
    });
    for(const type of ["pointerup","pointercancel","lostpointercapture"]) button.addEventListener(type,()=>{
      touch.delete(button.dataset.direction);button.classList.remove("held");
    });
  });
  return {open,pick,chooseHere,get isOpen(){return dialog.open;},get game(){return game;}};
})();
