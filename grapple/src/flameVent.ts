/* A nozzle in the rock that fires on a fixed cycle.
 *
 * Every other hazard in the caves is deadly the whole time it is on screen, so
 * the only answer to one is a route around it. The vent instead sells a safe
 * window: it rests, it sparks as a warning, it burns, and the player who reads
 * the tell crosses the gap it is guarding. The warning state is what makes the
 * hazard fair, so it is never skipped, however short it gets.
 *
 * The tile's rotation aims it, so a vent works on a ceiling or a wall. */
class FlameVent extends Sprite {
    private readonly DORMANT_TIME = 1.5;
    private readonly WARN_TIME = 0.5;
    private readonly BURN_TIME = 1.1;

    constructor(x: number, y: number, angle: number) {
        super({
            x: x, y: y,
            angle: angle,
            animations: [
                Animations.fromTextureList({ name: 'dormant', texturePrefix: 'flamevent', textures: [0], frameRate: 1 }),
                // The warning flickers between the bare housing and a lick of
                // flame; the burn cycles the two tall frames so the jet never
                // sits still.
                Animations.fromTextureList({ name: 'warn', texturePrefix: 'flamevent', textures: [0, 1], frameRate: 8, count: -1 }),
                Animations.fromTextureList({ name: 'burn', texturePrefix: 'flamevent', textures: [3, 2], frameRate: 12, count: -1 }),
            ],
            defaultAnimation: 'dormant',
            layer: 'entities',
            physicsGroup: 'hazards',
            // On the flame, not on the housing: the housing is the part that is
            // safe to stand next to, and the player must be able to.
            bounds: FlameVent.jetBounds(angle),
            colliding: false,
            tags: ['deadly'],
        });

        this.stateMachine.addState('dormant', {
            callback: () => {
                this.playAnimation('dormant');
                this.colliding = false;
            },
            script: S.wait(this.DORMANT_TIME),
            transitions: [{ toState: 'warn' }]
        });

        this.stateMachine.addState('warn', {
            callback: () => this.playAnimation('warn'),
            script: S.wait(this.WARN_TIME),
            transitions: [{ toState: 'burn' }]
        });

        this.stateMachine.addState('burn', {
            callback: () => {
                this.playAnimation('burn');
                this.colliding = true;
            },
            script: S.wait(this.BURN_TIME),
            transitions: [{ toState: 'dormant' }]
        });

        // Vents placed in a row would otherwise fire in lockstep, which turns a
        // corridor of them into one wide gate instead of a rhythm. Waiting out
        // a random slice of the cycle before the first one starts scatters them
        // without giving each vent a period of its own.
        this.stateMachine.addState('stagger', {
            callback: () => {
                this.playAnimation('dormant');
                this.colliding = false;
            },
            script: S.wait(Random.float(this.DORMANT_TIME + this.WARN_TIME + this.BURN_TIME)),
            transitions: [{ toState: 'warn' }]
        });

        this.setState('stagger');
    }
}

namespace FlameVent {
    /* The jet leaves the housing along the tile's up axis, whichever way the
     * tile was turned. Computed here rather than in the constructor body
     * because the bounds have to exist before the sprite does. */
    export function jetBounds(angle: number) {
        let jet = Vector2.UP.rotated(angle);
        return new CircleBounds(jet.x * 3, jet.y * 3, 5);
    }
}
