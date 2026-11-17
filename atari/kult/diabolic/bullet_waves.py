"""Measure existing enemy motions and report their full eight-actor bounds."""

def measure(project,sine):
    sources=[]
    for wave,row in enumerate(project['waves'][0]):
        if not project['encounters'][0][wave] and row[1] not in [v[1] for v in sources]:sources.append((wave,row[1]))
        if len(sources)==3:break
    for motion in range(32):
        if len(sources)==3:break
        if motion not in [v[1] for v in sources]:sources.append((None,motion))
    result=[]
    for wave,motion in sources:
        m=project['motions'][motion];phase=[0]*4;frames=[]
        for t in range(256):
            points=[]
            for enemy in range(8):
                p=[(phase[j]+enemy*m[j+4])&255 for j in range(4)]
                points.append(((sine[p[2]]+sine[p[3]])&127,(sine[p[0]]+sine[p[1]])&127))
            frames.append(points);phase=[(phase[j]+m[j])&255 for j in range(4)]
        bounds=[min(p[a] for frame in frames for p in frame) for a in (0,1)]+[max(p[a] for frame in frames for p in frame) for a in (0,1)]
        # Keep the source curve's bends, but limit lateral acceleration. The
        # stream advances left every update instead of orbiting near the boss.
        curve=[];offset=0;lo,hi=bounds[1],bounds[3]
        for age in range(64):
            y=frames[age//2][0][1]
            target=int((y-lo)*36/max(1,hi-lo)+0.5)-18
            offset+=max(-1,min(1,target-offset))
            curve.append(offset+32)
        result.append(dict(wave=wave,motion=motion,bounds=bounds,curve=curve))
    return result
